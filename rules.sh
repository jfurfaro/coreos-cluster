#!/bin/bash

# etcdctl member list | awk '{print $4}' | grep -Po '(\d+\.\d+\.\d+\.\d+)' | xargs sudo ./rules.sh

RULES="*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -i docker0 -j ACCEPT\n"

for IP in "$@"
do
    RULES="$RULES-A INPUT -i eth1 -s $IP -j ACCEPT\n"
done

RULES="$RULES-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT
COMMIT\n"

FILE="/var/lib/iptables/rules-save"
touch "$FILE"
echo -e "$RULES" > "$FILE"

chmod 644 "$FILE"
