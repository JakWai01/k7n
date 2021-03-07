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
    # Install n2n 
    ssh root@${ip} "curl -L -o /tmp/apt-ntop-stable.deb https://packages.ntop.org/apt-stable/buster/all/apt-ntop-stable.deb"
    ssh root@${ip} "apt install -y /tmp/apt-ntop-stable.deb"  
    ssh root@${ip} "apt update"
    ssh root@${ip} "apt install -y n2n"
    if (($i == 1))
    then 
        echo "Supernode: $ip"
        # Create systemd service: supernode.service
        ssh root@${ip} "echo -e '[Unit]\nDescription=Starting n2n supernode\n\n[Service]\nExecStart=/usr/sbin/supernode -l 7777\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/supernode.service"
        ssh root@${ip} "systemctl daemon-reload"
        ssh root@${ip} "systemctl enable supernode.service"
        ssh root@${ip} "systemctl start supernode.service"
    fi
    echo "IP: $ip" 
    # Create systemd service: vpn.service
    ssh root@${ip} "echo -e '[Unit]\nDescription=Connecting to supernode\n\n[Service]\nExecStart=/usr/sbin/edge -A3 -c name -k name -a 192.168.100.${i} -f -l ${ip}:7777\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/vpn.service"
    ssh root@${ip} "systemctl daemon-reload"
    ssh root@${ip} "systemctl enable vpn.service"
    ssh root@${ip} "systemctl start vpn.service"
    # token=$(ssh root@${ip} "echo 'Hallo Welt'")
    # echo $token
    echo "Back home"
    if (($i == 1))
    then 
        ssh root@${ip} "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server --node-ip=${ip} --flannel-iface=edge0' sh -"
        token=$(ssh root@${ip} cat /var/lib/rancher/k3s/server/node-token)
        echo $token
    fi 
    i=$((i + 1));
done