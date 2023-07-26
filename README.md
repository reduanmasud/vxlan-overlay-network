# Multi-container Host networking demo using Vxlan overlay network at virtual box
## Diagram
![Diagram](https://github.com/reduanmasud/vxlan-overlay-network/blob/main/vxlan-docker-overlay-network.png)

## The Scenerio
Here, I have two virtual hosts. VM-1 and VM-2. Our goal is to facilitate communication between two containers.

## Overview of what we are going to do

1. Create two VMs.
2. Configure both VM's interface so that both are in same subnet
3. Install necessery tools to those VMs.
4. Create subnet in each VM using docker network utility ``A bridge also created by the process`for each VM make the subnet same.`
5. Run docker container on newly created docker bridge and subnet
6. Install some necessery tools inside the docker container
7. Now we need to create VXLAN tunnel to facilate comunication each other.
8.   ```sudo ip link add vxlan-demo type vxlan id 100 remote 10.0.1.41 dstport 4789 dev eth0```
9. Connect the Bride with vxlan
10. Now do a ping check

## Creating  two VMs
Install VirtualBox and create two VMs in that virtual box. In my case I am using `ubuntu-server 18.0` Now We need to add extra interface adapter to our VMs

1. We need to create Network. To do that go to **Settings > Netwrok > Host Only Network** Now click **Create**
2. You will find somethig like `vboxnet0, vboxnet1 ...`

## Assign IP address of same subnet to newly created VMs
1. Start The Both VMs
```sh
# Check all interface that are down.
ip a | grep DOWN
```

