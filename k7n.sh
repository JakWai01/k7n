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

# Loop through all arguments provided and check if one of the possible options was provided
for option in "$@"; do

    # Show help page and usage information
    if [ $option == "-h" ] || [ $option == "--help" ]; then

        echo "
k7n is a tool to setup k3s and n2n on your infrastructure.

Global Flags:
    [-h]elp         Display this page.
    [-c]onfig       Show the kubeconfig at the end of the setup so it can be copied to configure e.g. k9s or similar tools.

Usage: 
    e.g. './k7n.sh <ip_1> <ip_2>'
    The first IP entered will be the supernode as well as a normal node. All subsequent entered IP's will be additional nodes in your Cluster.
    In this case <ip_1> would be the supernode as well as a normal node and <ip_2> would just be another node.
    You can add as many node IP's as you want to the command. The first IP (<ip_1>) will be the manager of your cluster.
    All subsequent IP's are additional workers.

For more information, visit https://github.com/JakWai01/k7n.
"
        exit

    fi

    show_config=false

    # Show kubeconfig at the end of the setup
    if [ $option == "-c" ] || [ $option == '--config' ]; then

        show_config=true

    fi

done

i=1

# Loop through all provided IP's and setup the cluster
for ip in "$@"; do

    # Don't install if the current IP is the option '-c'
    if [ $ip != "-c" ]; then

        # Install n2n on all machines
        ssh root@${ip} "curl -L -o /tmp/apt-ntop-stable.deb https://packages.ntop.org/apt-stable/buster/all/apt-ntop-stable.deb"
        ssh root@${ip} "apt install -y /tmp/apt-ntop-stable.deb"
        ssh root@${ip} "apt update"
        ssh root@${ip} "apt install -y n2n"

        # True for supernode only
        if (($i == 1)); then

            supernode=$ip
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

        # True for supernode (Kubernetes manager) only
        if (($i == 1)); then

            # Install k3s on supernode
            ssh root@${ip} "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server --node-ip=${ip} --flannel-iface=edge0' sh -"

            # Get cluster token
            token=$(ssh root@${ip} cat /var/lib/rancher/k3s/server/node-token)
            echo $token

        else

            # Install k3s on non-supernode nodes with the token aquired from the supernode
            ssh root@${ip} "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='agent --token=${token} --node-ip=${ip} --server=https://$supernode:6443 --flannel-iface=edge0' sh -"

        fi

        i=$((i + 1))

    fi

done

# Show config at the end if the option was specified
if [[ "$show_config" = true ]]; then

    echo "$(ssh root@${supernode} "cat /etc/rancher/k3s/k3s.yaml")"

fi
