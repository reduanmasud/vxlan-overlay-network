#!/bin/bash

# Set the color variable
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

ip a | grep "DOWN"
# Current VirtualVox has some issue with setting ip from GUI.
# So, I you want to add ip manually  you can do that here pass y

echo -e -n "${yellow}Do you want to add static Ip to network interface interface (y/n) : ${clear}"
read static_ip_y

if [[ "$static_ip_y" == "y" ]]; then

echo -e -n "${yellow} Select Device: (0: eth0, 1:enp0s3 2:enp0s8 3: Type) ${clear}"
read -r select_dev

if [[ "$select_dev" == "0" ]]; then
device="eth0"
fi

if [[ "$select_dev" == "1" ]]; then
device="enp0s3"
fi

if [[ "$select_dev" == "2" ]]; then
device="enp0s8"
fi

if [[ "$select_dev" == "3" ]]; then
echo -e -n "${yellow} Device Name: ${clear}"
read -r device
fi

echo -e -n "${yello}Type your IP with CIDR (ip/CIDR) : ${clear}"
read static_ip

# sudo ip addr add 192.168.0.9/21 dev eth0
# sudo ip link set eth0 up

sudo ip addr add $static_ip dev $device
sudo ip link set $device up

fi

# If you already setted up other VM too you can try an ping check
echo -e "${yellow}If you already setted up other VM Type that VM's ip to check connection. ${clear}"
echo -e -n "Want a ping check ? ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
echo -e -n "IPAddress ${green}(ip)${clear} : "
read -r ip_addr
ping $ip_addr -c 3
fi


echo -e "${green} [ 1 ] ${clear} ${yellow}Updating apt ${clear}"
sudo apt update

echo -e "${yellow}Installing net tools ${clear}"
sudo apt install -y net-tools

echo -e "${green} [ 2 ] ${clear} ${yellow}Installing Docker.io ... ... ...${clear}"
sudo apt install -y docker.io


echo -e "${green} [ 3 ] ${clear} ${yellow}Create Docker Subnet ${clear}"
echo -e -n "Enter Subnet IP address with CIDR ${green}(Ex. 172.18.0.0/16)${clear} : "
read -r docker_subnet_ip
echo -n "Docker Subnet key: " > save.txt

# sudo docker network create --subnet 172.18.0.0/16 vxlan-net
sudo docker network create --subnet $docker_subnet_ip vxlan-net >> subnet_key.txt

cat subnet_key.txt >> save.txt
echo "" >> save.txt

echo -e -n "Do you want to check the list of network list ${green}(y/n)${clear} : "
read -r check_list
if [[ "$check_list" == "y" ]]; then
sudo docker network ls
fi

echo -e -n "Do you want to check ip interface list ${green}(y/n)${clear} : "
read -r check_ip_list
if [[ "$check_ip_list" == "y" ]]; then
sudo ip a
fi

# check any ip from same subnet
echo -e -n "Enter any ip from subnet to check ? ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
echo -e -n "IP Address ${green}(ip)${clear} : "
read -r ip_addr
ping $ip_addr -c 5
fi

echo -e "${green} [ 4 ] ${clear} ${yellow}Create and run docker container ...${clear}"

echo -e "${yellow} Stopping all previous active containers ... ${clear}"
docker stop $(docker ps -a -q)
echo -e "${green}Done${clear}"

echo -e -n "Enter IP address for docker container ${green}(ip)${clear} : "
read -r docker_inside_ip
echo -n "Docker Container ID: @" >> save.txt
sudo docker run -d --net vxlan-net --ip $docker_inside_ip ubuntu sleep 3000 > container_id.txt
cat container_id.txt >> save.txt

echo -n "Container ID Actual: " >> save.txt
echo ${container_id:0:12} >> save.txt


container_id=$( cat container_id.txt ) 
# rm container_id.txt
echo -e "${green}Your Docker Container ID: ${clear}${yellow}$container_id${clear}"

echo -e -n "Do you want to check Container list ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
sudo docker ps
fi

echo -e -n "Do you want to check the IP address of Container ${green}(y/n)${clear} : "
read -r yes_no2
if [[ "$yes_no2" == "y" ]]; then
sudo docker inspect ${container_id:0:12} | grep -E "(\"IPAddress\")"
fi


echo -e -n "Press ${yellow}Enter${clear} to continue ..."
read -r garrbage

echo -e "${green} [ 5 ] ${clear} ${yellow}Ping test ${docker_inside_ip} ${clear}"
ping $docker_inside_ip -c 5

echo -e "${yellow} Container id ${container_id:0:12} ${clear}"
echo -e "${yellow} Updating... ${clear}"
sudo docker exec ${container_id:0:12} apt-get update
echo -e "${yellow} Installing net-tools... ${clear}"
sudo docker exec ${container_id:0:12} apt-get install -y net-tools
echo -e "${yellow} Installing iputils-ping... ${clear}"
sudo docker exec ${container_id:0:12} apt-get install -y iputils-ping

# sudo docker exec -it ${container_id:0:12} bash
echo -e -n "Press ${yellow}Enter${clear} to clear the screen and continue ..."
read -r garrbage

echo -e -n "Do you want to check Bridge list ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
brctl show
fi

echo -e "${green} [ 6 ] ${clear} ${yellow}Setup vxlan ======================== ${clear}"
echo -e -n "${yellow} Enter vxlan name: ${clear}"
read -r vxlan_name
echo -e -n "${yellow} Enter a id for vxlan: ${clear}"
read -r vxlan_id
echo -e -n "${yellow} Enter ip of other VM interface: ${clear}"
read -r host2_ip

echo -e -n "${yellow} Select Device: (0: eth0, 1:enp0s3 2:enp0s8 3: Type) ${clear}"
read -r select_dev

if [[ "$select_dev" == "0" ]]; then
device="eth0"
fi

if [[ "$select_dev" == "1" ]]; then
device="enp0s3"
fi

if [[ "$select_dev" == "2" ]]; then
device="enp0s8"
fi

if [[ "$select_dev" == "3" ]]; then
echo -e -n "${yellow} Device Name: ${clear}"
read -r device
fi

echo -e "${yellow} Creating vxlan...${clear}"
# sudo ip link add vxlan-demo type vxlan id 100 remote 10.0.1.4 dstport 4789 dev eth0
sudo ip link add $vxlan_name type vxlan id $vxlan_id remote $host2_ip dstport 4789 dev $device
echo -e "${yellow} Created ... ${clear}"

echo -e "${yellow} Checking vxlan interface created ... ${clear}"
ip a | grep "vxlan"

echo -e "${green} [ 7 ] ${clear} ${yellow} make Interface UP ${clear}"
# sudo ip link set vxlan-demo up
sudo ip link set $vxlan_name up


echo -e -n "Want a ping check ? ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
echo -e -n "IPAddress ${green}(ip)${clear} : "
read -r ip_addr
ping $ip_addr -c 5
fi


#Get Bridge id
ip a | grep -E -o -m 1 "br-(\w+)" > bridge_id.txt
bridge_id=$(cat bridge_id.txt)

echo -e "${green} [ 8 ] ${clear} ${yellow} Attaching newly created vxlan to bridge ${clear}"
echo -e "${green}Bridge ID:${clear} ${yellow} $bridge_id ${clear}"

echo -e -n "Is Bridge ID is ok ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "n" ]]; then
echo -e -n "Enter Bridge id ${green}(br-...)${clear} : "
read -r bridge_id
fi
# sudo brctl addif br-c485be328b34 vxlan-demo
sudo brctl addif $bridge_id $vxlan_name


echo -e "${green} [ 9 ] ${clear} ${yellow} Checking Route Table ${clear}"
route -n

echo -e -n "Want a ping check ? ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
echo -e -n "IPAddress ${green}(ip)${clear} : "
read -r ip_addr
ping $ip_addr -c 5
fi
clear
echo -e -n "Do you want enter to the container ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
sudo docker exec -it ${container_id:0:12} bash
fi