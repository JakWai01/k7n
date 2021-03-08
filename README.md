# k7n
A bash tool to setup k3s and n2n (Kubernetes behind a VPN) automatically. The name k7n results of the original two technologies concatenated (k3sn2n) and summed up in k8s manor.

## Motivation
Creating a working Kubernetes cluster can be a big challenge for beginners. It is way harder though, to create a Kubernetes cluster behind a VPN, so also your nodes behind asymmetrical NAT can participate in your cluster (like my old laptop). This project aims to setup a Kubernetes cluster behind a VPN automatically for you using [k3s](https://github.com/k3s-io/k3s) and [n2n](https://github.com/ntop/n2n). Adding a VPN to your infrastructure also provides security like explained [here](https://www.intruder.io/blog/how-to-secure-the-kubernetes-api-behind-a-vpn).

## Features
By just providing the IP's of your servers k7n will ssh into each of them and perform the full installation of the mentioned tools.

### Supported Distributions
| Distribution  | Status        | 
| ------------- |:-------------:|
| <img src="https://github.com/vorillaz/devicons/blob/master/!SVG/debian.svg" width="25">     | ✅ |


## Installation
Clone the repository:  

```shell
git clone git@github.com:JakWai01/k7n.git
```  

Change your current directory to the k7n repository e.g.:  

```shell
cd ~/Documents/repos/k7n
```

## Usage
For example, to setup a cluster on 2 servers use the script like this:

```shell
bash ./k7n.sh $IP_ADDRESS_1 $IPADDRESS_2
```  

The first IP entered will be the supernode as well as a normal node. All subsequent entered IP's will be additional nodes in your Cluster.  
In this case `$IP_ADDRESS_1` would be the supernode as well as a normal node and `$IPADDRESS_2` would just be another node.
You can add as many node IP's as you want to the command. The first IP (`$IPADDRESS_1`) will be the manager of your cluster.
All subsequent IP's are additional workers.

## Contribute
Feel free to contribute. A [code of conduct](https://github.com/JakWai01/k7n/blob/main/CODE_OF_CONDUCT.md) can be found inside the repository.

## License

k7n (c) 2021 Jakob Waibel

SPDX-License-Identifier: AGPL-3.0
