#!/bin/bash
#
# Script Name: k7n.sh
#
# Author: Jakob Waibel
# Date : 2020-03-06
#
# Description: Remote setup k3s and n2n (Kubernetes behind a VPN) automatically and from remote 
#
# Run Information: This script needs to be run once to setup your whole kubernetes cluster with k3s and n2n. You can run this script on any machine to install your cluster remotely.
#
token = "token"
supernode_ip;
i=1
for ip in "$@"
do  
    if (($i == 1))
    then 
        echo "Supernode: $ip"
        echo "IP-$i: $ip";
        supernode_ip = $ip
        ssh root@${ip}
    else
        echo "IP-$1: $ip";
    fi
    echo "Back home"
    i=$((i + 1));
done