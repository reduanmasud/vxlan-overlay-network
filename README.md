# Multi-container Host networking demo using Vxlan overlay network at virtual box
## Diagram
![Diagram](https://github.com/reduanmasud/vxlan-overlay-network/blob/main/vxlan-docker-overlay-network.png)

## The Scenerio
Here, I have two virtual hosts. VM-1 and VM-2. Our goal is to facilitate communication between two containers.

## Overview of what we are going to do

1. Create two VMs.
2. Configure both VM's interfaces so that both are in same subnet
3. Install the necessary tools on those VMs.
4. Create subnet in each VM using docker network utility: ``A bridge also created by the process`for each VM make the subnet same.`
5. Run docker container on newly created docker bridge and subnet
6. Install some necessary tools inside the docker container
7. Now we need to create a VXLAN tunnel to facilitate communication with each other.
8.   ```sudo ip link add vxlan-demo type vxlan id 100 remote 10.0.1.41 dstport 4789 dev eth0```
9. Connect the Bride with vxlan
10. Now do a ping check

## Creating  two VMs
Install VirtualBox and create two VMs in that virtual box. In my case, I am using `ubuntu-server 18.0` Now We need to add extra interface adapter to our VMs

1. We need to create a network. To do that, go to **Settings > Network > Host Only Network** Now click **Create**
2. You will find something like `vboxnet0, vboxnet1 ...`

## Assign IP address from the same subnet to newly created VMs
1. Start both VMs and check there `ip a` status
```sh
# Check all interfaces that are down. Where we can assign ip address
ip a | grep DOWN
```
You will see like this:
```sh
enp0s8: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
# ^^^^
# this is the name of our interface, it can be **eth0**, **eno1** or anything else
```
2. Assign IP

**Host 01**
```sh
sudo ip addr add 192.68.56.2/21 dev enp0s8
sudo ip link set enp0s8 up
```
**Host 02**
```sh
sudo ip addr add 192.68.56.3/21 dev enp0s8
sudo ip link set enp0s8 up
```
Now you can check agaig using `ip a` is every thing is ok.

## Install Necessery tools
**Both VMs**
```sh
sudo apt update
sudo apt install -y net-tools docker.io
```

## Create subnet using `docker network` utility tools
```sh

sudo docker network create --subnet 172.18.0.0/16 vxlan-net

```
`
**docker:** This is the main command-line interface for interacting with Docker, a popular containerization platform used for creating and managing containers.

**network create:** This subcommand is used to create a new Docker network. Docker networks allow containers to communicate with each other and with external networks.

**--subnet 172.18.0.0/16:** This flag specifies the subnet range for the Docker network. In this case, it is set to "172.18.0.0/16", which means that the network will use IP addresses from the range 172.18.0.0 to 172.18.255.255. It's worth noting that this range is quite large and can accommodate a large number of IP addresses.

**vxlan-net:** This is the name of the network being created. You can choose any name you like, and it will be used as an identifier for the network within the Docker environment.
`

