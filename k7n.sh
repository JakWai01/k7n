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
        ssh root@${ip} << EOF
            curl -L -o /tmp/apt-ntop-stable.deb https://packages.ntop.org/apt-stable/buster/all/apt-ntop-stable.deb
            apt install -y /tmp/apt-ntop-stable.deb
            apt update
            apt install -y n2n 
            supernode -l 7777 &
            edge -A3 -c name -k password -a 192.168.100.1 -f -l ${ip}:7777 &

            curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.100.1 --flannel-iface=edge0" sh -
            cat /var/lib/rancher/k3s/server/node-token > token.txt
EOF
    else
        echo "IP-$i: $ip";
        ssh root@${ip} << EOF
            curl -L -o /tmp/apt-ntop-stable.deb https://packages.ntop.org/apt-stable/buster/all/apt-ntop-stable.deb
            apt install -y /tmp/apt-ntop-stable.deb
            apt update
            apt install -y n2n
            edge -A3 -c code-and-chill -k cacpass -a 192.168.100.${i} -f -l ${supernode_ip}:7777 &

            curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --token=${token} --node-ip=192.168.100.${i} --server=https://192.168.100.1:6443 --flannel-iface=edge0" sh -
EOF
    fi
    i=$((i + 1));
done