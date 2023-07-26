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

**Both VMs**
```sh
# create docker bridge network
sudo docker network create --subnet 172.18.0.0/16 vxlan-net

ba345a328b21ed1e93492a8ecs9asc5f5426e42adf52ef7a92394fe0192715as

sudo docker network ls

NETWORK ID     NAME        DRIVER    SCOPE
5426e42adf52   bridge      bridge    local
d1f9b80443c4   host        host      local
922f1ff12422   none        null      local
ba345a328b21   vxlan-net   bridge    local
# ^^^^^^^^^^
# This is our Bridge ID.
```
`
**docker:** This is the main command-line interface for interacting with Docker, a popular containerization platform used for creating and managing containers.

**network create:** This subcommand is used to create a new Docker network. Docker networks allow containers to communicate with each other and with external networks.

**--subnet 172.18.0.0/16:** This flag specifies the subnet range for the Docker network. In this case, it is set to "172.18.0.0/16", which means that the network will use IP addresses from the range 172.18.0.0 to 172.18.255.255. It's worth noting that this range is quite large and can accommodate a large number of IP addresses.

**vxlan-net:** This is the name of the network being created. You can choose any name you like, and it will be used as an identifier for the network within the Docker environment.
`

## Run docker container on top of newly created docker bridge network and try to ping docker bridge

**Host 01**
```sh
# running ubuntu container with "sleep 3000" and a static ip
sudo docker run -d --net vxlan-net --ip 172.18.0.11 ubuntu sleep 3000

5a81c4b8502e0b5e8369f211e65e6fdabf611d01353cb4dc3ff646166ce18e26

# check the container running or not
sudo docker ps

CONTAINER ID   IMAGE     COMMAND        CREATED         STATUS         PORTS     NAMES
5a81c4b8502e   ubuntu    "sleep 3000"   7 seconds ago   Up 6 seconds             interesting_turing

# check the IPAddress to make sure that the ip assigned properly
sudo docker inspect 5a81c4b8502e | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.18.0.11",

# ping the docker bridge ip to see whether the traffic can pass
ping 172.18.0.1 -c 2
PING 172.18.0.1 (172.18.0.1) 56(84) bytes of data.
64 bytes from 172.18.0.1: icmp_seq=1 ttl=64 time=0.047 ms
64 bytes from 172.18.0.1: icmp_seq=2 ttl=64 time=0.044 ms

--- 172.18.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1010ms
rtt min/avg/max/mdev = 0.044/0.045/0.047/0.001 ms
```

**Host 02**
```sh
# running ubuntu container with "sleep 3000" and a static ip
sudo docker run -d --net vxlan-net --ip 172.18.0.12 ubuntu sleep 3000

7b9235acea340b5e8369f211e65e6fdabf611d01353cb4dc3ff646166ce18e26

# check the container running or not
sudo docker ps

CONTAINER ID   IMAGE     COMMAND        CREATED         STATUS         PORTS     NAMES
7b9235acea34   ubuntu    "sleep 3000"   7 seconds ago   Up 6 seconds             funny_mac

# check the IPAddress to make sure that the ip assigned properly
sudo docker inspect 7b9235acea34 | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.18.0.11",

# ping the docker bridge ip to see whether the traffic can pass
ping 172.18.0.1 -c 2
PING 172.18.0.1 (172.18.0.1) 56(84) bytes of data.
64 bytes from 172.18.0.1: icmp_seq=1 ttl=64 time=0.047 ms
64 bytes from 172.18.0.1: icmp_seq=2 ttl=64 time=0.044 ms

--- 172.18.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1010ms
rtt min/avg/max/mdev = 0.044/0.045/0.047/0.001 ms
```


