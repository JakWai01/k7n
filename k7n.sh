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

i=1
for ip in "$@"
do  
    if (($i == 1))
    then 
        ## whole process for first ip
        echo "Supernode: $ip"
        echo "IP-$i: $ip";
        ssh root@${ip} "mkdir hello"
        echo "Hello World!"
    else
        ## whole process for every other ip
        echo "IP-$i: $ip";    
    fi
    i=$((i + 1));
done