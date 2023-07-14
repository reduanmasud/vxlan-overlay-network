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


echo -e "${green} [1 ] ${clear} Updating apt"
sudo apt update

echo -e "${green} [2 ] ${clear} Installing Docker.io ... ... ..."
sudo apt install -y docker.io


echo -e "${green} [3 ] ${clear} Creating subnet using docker network ... ... ..."
echo -e -n "${red} Enter IP address with CIDR (ip/cidr) : ${clear}"
read -r docker_subnet_ip
echo -n "Docker Subnet key: " >> save.txt
sudo docker network create --subnet $docker_subnet_ip vxlan-net >> save.txt
