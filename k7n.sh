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
        # Create supernode systemd service
        ssh root@${ip} "echo -e '[Unit]\nDescription=Starting n2n supernode\n\n[Service]\nExecStart=/usr/sbin/supernode -l 7777\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/supernode.service"
        ssh root@${ip} "systemctl daemon-reload"
        ssh root@${ip} "systemctl enable supernode.service"
        ssh root@${ip} "systemctl start supernode.service"
    fi
    # Create systemd service to connect to supernode
    echo "IP: $ip"
    echo "Back home"
    i=$((i + 1));
done