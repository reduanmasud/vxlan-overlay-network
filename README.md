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
3. Go to each VMs **Settings > Network > Adapter 2:** Now Set, **Attatched to:** `Host Only Network` And **Name:** `vboxnet0`

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

**VM Host 01**
```sh
sudo ip addr add 192.68.56.2/21 dev enp0s8
sudo ip link set enp0s8 up
```
**VM Host 02**
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

**VM Host 01**
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

# ping the docker bridge ip to see whether traffic can pass
ping 172.18.0.1 -c 2
PING 172.18.0.1 (172.18.0.1) 56(84) bytes of data.
64 bytes from 172.18.0.1: icmp_seq=1 ttl=64 time=0.047 ms
64 bytes from 172.18.0.1: icmp_seq=2 ttl=64 time=0.044 ms

--- 172.18.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1010ms
rtt min/avg/max/mdev = 0.044/0.045/0.047/0.001 ms
```

**VM Host 02**
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

# ping the docker bridge ip to see whether traffic can pass
ping 172.18.0.1 -c 2
PING 172.18.0.1 (172.18.0.1) 56(84) bytes of data.
64 bytes from 172.18.0.1: icmp_seq=1 ttl=64 time=0.047 ms
64 bytes from 172.18.0.1: icmp_seq=2 ttl=64 time=0.044 ms

--- 172.18.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1010ms
rtt min/avg/max/mdev = 0.044/0.045/0.047/0.001 ms
```

## Install some necessery tools to docker container

**Both VMs**
```sh
# updating docker container and installing the necessary tools
sudo docker exec 7b9235acea34 apt-get update
sudo docker exec 7b9235acea34 apt-get install -y net-tools iputils-ping
#                ^^^^^^^^^^^^
#                use your docker container ID, this should be different in different VMs docker container.
#                Instead of Container ID you can use NAME also such as in my case interesting_turing, funny_mac

```

## Create vxlan
Do you remember we have created a bridge earlier? Now we need that Bridge ID again. 

Forgot that!? No problem. We can check that 

**VM Host 01**
```sh
# Checking our bridges
brctl show

bridge name	            bridge id		STP enabled	            interfaces
br-ba345a328b21	            8000.0242f2770dab	no	                        veth725a704
docker0	                        8000.02429f18ffdf	no

# Create the vxlan 
sudo ip link add vxlan-demo type vxlan id 100 remote 192.68.56.3 dstport 4789 dev enp0s8

# make the interface up
sudo ip link set vxlan-demo up

# Now add the docker Bridge with the vxlan
sudo brctl addif br-ba345a328b21 vxlan-demo

```

**VM Host 02**
```sh
# Checking our bridges
brctl show

bridge name	            bridge id		STP enabled	            interfaces
br-aa311a328b66	            8000.0242f2770dab	no	                        veth725a704
docker0	                        8000.02429f18ffdf	no

# Create the vxlan 
sudo ip link add vxlan-demo type vxlan id 100 remote 192.68.56.3 dstport 4789 dev enp0s8

# make the interface up
sudo ip link set vxlan-demo up

# Now add the docker Bridge with the vxlan
sudo brctl addif br-aa311a328b66 vxlan-demo

```

**Explanation** : `sudo ip link add vxlan-demo type vxlan id 100 remote 192.68.56.3 dstport 4789 dev enp0s8`

**ip:** "ip" is a command-line utility in Linux used for network configuration. It can be used to view and modify network interfaces, routes, and other networking parameters.

**link add vxlan-demo:** This part of the command instructs the "ip" utility to create a new network link with the name "vxlan-demo." A network link is an interface that can be used to send and receive data over the network.

**type vxlan:** Here, we specify the type of network link we want to create, which is a VXLAN interface.

**id 100:** This option sets the VXLAN Network Identifier (VNI) to 100. The VNI is used to segment traffic within the VXLAN network, allowing multiple isolated virtual networks to coexist on the same physical network infrastructure.

**remote 192.68.56.3:** This option specifies the IP address of the remote endpoint for the VXLAN tunnel. The VXLAN packets will be encapsulated and sent to this remote IP address.

**dstport 4789:** VXLAN uses UDP (User Datagram Protocol) for encapsulation, and this option sets the destination port to 4789. VXLAN packets will be sent to this port number on the remote endpoint.

**dev enp0s8:** The "dev" option specifies the physical network interface that will be used to send and receive VXLAN traffic. In this case, the VXLAN interface will use "enp0s8" as its underlying physical interface.

## Our entire configuration is complete. Now we can test it with a ping test.

**VM Host 01**
```sh
# Ping test host 1's docker container to host 2's container
sudo docker exec 5a81c4b8502e ping 172.18.0.12 -c 2

PING 172.18.0.12 (172.18.0.12) 56(84) bytes of data.
64 bytes from 172.18.0.12: icmp_seq=1 ttl=64 time=0.601 ms
64 bytes from 172.18.0.12: icmp_seq=2 ttl=64 time=0.601 ms

--- 172.18.0.12 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1018ms
rtt min/avg/max/mdev = 0.601/0.601/0.601/0.000 ms

```

**VM Host 02**
```sh
# Ping test host 2's docker container to host 1's container
sudo docker exec 7b9235acea34 ping 172.18.0.11 -c 2

PING 172.18.0.12 (172.18.0.12) 56(84) bytes of data.
64 bytes from 172.18.0.12: icmp_seq=1 ttl=64 time=0.601 ms
64 bytes from 172.18.0.12: icmp_seq=2 ttl=64 time=0.601 ms

--- 172.18.0.12 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1018ms
rtt min/avg/max/mdev = 0.601/0.601/0.601/0.000 ms

```

## Our ping test successful so our connection is working 🎉
