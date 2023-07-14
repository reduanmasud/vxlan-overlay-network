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

echo -e -n "${yellow}Do you want to add static Ip to NAT interface (y/n) : ${clear}"
read static_ip_y

if [[ "$static_ip_y" == "y" ]]; then

echo -e -n "${yello}Type your IP with CIDR (ip/CIDR) : ${clear}"
read static_ip
sudo ifconfig enp0s3 $static_ip

fi

echo -e "${green} [1 ] ${clear} Updating apt"
sudo apt update

echo -e "${green} [2 ] ${clear} Installing Docker.io ... ... ..."
sudo apt install -y docker.io


echo -e "${green} [3 ] ${clear} Creating subnet using docker network ... ... ..."
echo -e -n "Enter IP address with CIDR ${green}(ip/cidr)${clear} : "
read -r docker_subnet_ip
echo -n "Docker Subnet key: " >> save.txt
sudo docker network create --subnet $docker_subnet_ip vxlan-net >> save.txt

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

echo -e "${green} [4 ] ${clear} Create and run docker container ..."
echo -e -n "Enter IP address ${green}(ip)${clear} : "
read -r docker_inside_ip
echo -n "Docker Container ID: @" >> save.txt
sudo docker run -d --net vxlan-net --ip $docker_inside_ip ubuntu sleep 3000 >> save.txt

container_id=$( cat save.txt | grep -E "\@(.*)") 

echo -e -n "Do you want to check Container list ${green}(y/n)${clear} : "
read -r yes_no
if [[ "$yes_no" == "y" ]]; then
sudo docker ps
fi

echo -e -n "Do you want to check the IP address of Container ${green}(y/n)${clear} : "
read -r yes_no2
if [[ "$yes_no2" == "y"]]; then
sudo docker inspect $container_id | grep -E "(\"IPAddress\"..)[[:digit:]]{1,3}.[[:digit:]]{1,3}.[[:digit:]]{1,3}.[[:digit:]]{1,3}\""
fi