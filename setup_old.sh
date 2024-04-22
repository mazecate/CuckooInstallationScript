# sudo su cuckoo
# virtualenv ~/cuckoo
# . ~/cuckoo/bin/activate

# cuckoo rooter --sudo --group cuckoo || cuckoo rooter --sudo
# cuckoo
# cuckoo web --host 127.0.0.1 --port 8082
# Ubuntu 18.x.x 8xxx basic ram, 4 GPU
# https://hatching.io/blog/cuckoo-sandbox-setup/

#!/bin/bash

# Update package lists
sudo apt-get update

# Install dependencies
sudo apt-get install -y python python-pip python-dev libffi-dev libssl-dev
sudo apt-get install -y python-virtualenv python-setuptools
sudo apt-get install -y libjpeg-dev zlib1g-dev swig

# Create a new user for Cuckoo without password
sudo adduser --disabled-password --gecos "" cuckoo

# Set permission
sudo groupadd pcap
sudo usermod -a -G pcap cuckoo
sudo chgrp pcap /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

# Get window7 iso
wget https://cuckoo.sh/win7ultimate.iso --no-check-certificate
sudo mkdir /mnt/win7
sudo mount -o ro,loop win7ultimate.iso /mnt/win7

# Add repository keys
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

# Adding the VirtualBox repository:
sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"

# Virtual 5.2 (must install this version otherwise will be have error)
sudo apt-get update
sudo apt-get install -y virtualbox-5.2
sudo usermod -a -G vboxusers cuckoo

# Virtual 6.0 
# sudo apt-get update
# sudo apt-get install -y virtualbox-6.0
# sudo usermod -a -G vboxusers cuckoo

# VMCloak and Cuckoo required packages:
sudo apt-get -y install build-essential libssl-dev libffi-dev python-dev genisoimage
sudo apt-get -y install zlib1g-dev libjpeg-dev
sudo apt-get -y install python-pip python-virtualenv python-setuptools swig

# Change user cuckoo
sudo su cuckoo
virtualenv ~/cuckoo
. ~/cuckoo/bin/activate

# Install vmcloak
pip install -U cuckoo vmcloak

# Create a network
vmcloak-vboxnet0

# vmcloak init virtual machine
vmcloak init --verbose --win7x64 win7x64base --cpus 2 --ramsize 2048

# below is not test

# # Install Cuckoo in a virtual environment
# virtualenv venv
# . venv/bin/activate
# pip install -U pip setuptools
# pip install -U cuckoo

# # Install tcpdump
# sudo apt-get install -y tcpdump apparmor-utils
# sudo aa-disable /usr/sbin/tcpdump

# # Allow the cuckoo user to capture packets without root privileges
# sudo groupadd pcap
# sudo usermod -a -G pcap cuckoo
# sudo chgrp pcap /usr/sbin/tcpdump
# sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

# # Install VirtualBox and its extension pack
# sudo apt-get install -y virtualbox virtualbox-ext-pack

# # Add the cuckoo user to the vboxusers group
# sudo usermod -a -G vboxusers cuckoo

# # Install and configure uWSGI and nginx for the Cuckoo web interface
# sudo apt-get install -y uwsgi uwsgi-plugin-python nginx