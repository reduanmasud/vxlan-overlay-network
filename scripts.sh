#!/bin/bash

# Set the color variable
green='\033[0;32m'
# Clear the color after that
clear='\033[0m'


echo -e "${green} [1 ] ${clear} Updating apt"
sudo apt update

echo -e "${green} [2 ] ${clear} Installing Docker.io ... ... ..."
sudo apt install -y docker.io
