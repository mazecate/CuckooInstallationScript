#!/usr/bin/env bash

# Reference
# https://beginninghacking.net/2022/11/16/how-to-setup-your-own-malware-analysis-box-cuckoo-sandbox/

# Step - Step 1 - Update Ubuntu box
sudo apt-get update

# Step 2 - Install required packages and apt repositories
sudo apt-get -y install python python-pip python-dev libffi-dev libssl-dev
sudo apt-get -y install python-virtualenv python-setuptools
sudo apt-get -y install libjpeg-dev zlib1g-dev swig

# Step 3 - Install MongoDB
sudo apt-get -y install mongodb

# Step 4 - Install PostgreSQL
sudo apt-get -y install postgresql libpq-dev

# Step 5 - Install VirtualBox
sudo apt-get -y install virtualbox

# Step 6 - Install tcpdump AppArmor
sudo apt-get -y install tcpdump apparmor-utils
sudo aa-disable /usr/sbin/tcpdump

# Step 7 - Add a new group and add a user so you don’t have to run as root
sudo adduser --disabled-password --gecos "" jonaldtest
sudo groupadd pcap
sudo usermod -a -G pcap jonaldtest
sudo chgrp pcap /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

# Step 8 - Verify the last command
getcap /usr/sbin/tcpdump

# Step 9 - Install M2Crypto (ubuntu 18 cannot install, reference https://stackoverflow.com/questions/3107036/how-do-i-install-m2crypto-on-ubuntu)
sudo apt-get -y install python-dev
sudo apt-get -y install python-m2crypto
sudo pip install m2crypto

# Step 10 - Add the account you created in step 7 to vboxusers group
sudo usermod -a -G vboxusers jonaldtest

# Step 11 - Create a virtual environment by using a script and 
# Step 11 - Save the script as cuckoo-setup-virtualenv.sh
sh cuckoo-setup-virtualenv.sh

# Step 12 - Change the permission of the script:
sudo chmod +x cuckoo-setup-virtualenv.sh

# Step 13 - Run the script using your current logged-in user and not the one you created in step 7
# sudo -u jonald ./cuckoo-setup-virtualenv.sh
sudo -u $(whoami) ./cuckoo-setup-virtualenv.sh

# maybe cannot run after step 14 by the program
exit

# Step 14 - Update your current shell environment
source ~/.bashrc

# Step 15 - Create a virtual environment
mkvirtualenv -p python2.7 sandbox

# Step 16 - Setup and install cuckoo while you are inside your newly created virtual env (sandbox)
pip install -U pip setuptools
pip install -U cuckoo

# Step 17 - Create a directory to mount Windows 7 iso (open a new terminal)
sudo mkdir /mnt/win7
sudo chown jonaldtest:jonaldtest /mnt/win7
sudo mount -o ro,loop win7ultimate.iso /mnt/win7

# Step 18 - Install packages again just to make sure that there are no missing packages
sudo apt-get -y install build-essential libssl-dev libffi-dev python-dev genisoimage
sudo apt-get -y install zlib1g-dev libjpeg-dev
sudo apt-get -y install python-pip python-virtualenv python-setuptools swig

# Step 19 - Install vmcloak and run it (inside the virtual environment)
pip install -U vmcloak
vmcloak

# Step 20 - Create a HOST-ONLY network adapter using vmcloak
vmcloak-vboxnet0

# Step 21 - Setup Windows VM
vmcloak init --verbose --win7x64 win7x64base --cpus 2 --ramsize 2048

# Step 22 - Clone the Windows VM
vmcloak clone win7x64base win7x64cuckoo

# Step 23 - Install some basic software packages
# vmcloak install win7x64cuckoo adobepdf pillow java flash vcredist vcredist.version=2015u3 wallpaper ie11 office office.version=2013 office.isopath=/home/jonald/Office_2013_Plus.iso office.serialkey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

# Step 24 - Create the Windows VMs
vmcloak snapshot --count 4 win7x64cuckoo 192.168.56.101

# Step 25 - View the list of VMs
vmcloak list vms

# Step 26 - Create the cuckoo directory where all config files get saved (still inside the virtual environment)
cuckoo init

# Step 27 - Update cuckoo to the latest signature
cd .cuckoo/conf
cuckoo community --force

# Step 28 - Open .cuckoo/conf/virtualbox.conf and change the MODE to GUI
# nano virtualbox.conf
# Step - Change mode to gui and save
# mode = gui

# Step 29 - Add the 4 VMs we created to the conf file
while read -r vm ip; do cuckoo machine --add $vm $ip; done < <(vmcloak list vms)

# Step 30 - Open virtualbox.conf again, remove cuckoo1 under machines, delete everything after controlports and stop when you see the first IP address that matches the IP under
# machines = cuckoo1, 192.168.56.1011, 192.168.56.1012, 192.168.56.1013, 192.168.56.1014

# Step 31 - Check your network adapter for the next setup steps
ip a

# Step 32 - Run the following commands inside of the virtual environment
# sudo sysctl -w net.ipv4.conf.vboxnet0.forwarding=1
# sudo sysctl -w net.ipv4.conf.ens33.forwarding=1
# sudo iptables -t nat -A POSTROUTING -o ens33 -s 192.168.56.0/24 -j MASQUERADE
# sudo iptables -P FORWARD DROP
# sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
# sudo iptables -A FORWARD -s 192.168.56.0/24 -j ACCEPT

# Step 33 - OPTIONAL: Install terminator
sudo apt-get install terminator

# Step 34- Open Terminator and split it to four windows
# Step 36 - Enter the virtual environment in all terminals
workon sandbox

# Step 36 - In one window, type:
# cuckoo rooter --sudo --group jonald
cuckoo rooter --sudo --group $(whoami)

# Step 37 - Change the routing information. Open routing.conf and change the internet entry to your network adapter (ens33):
# ip a
# internet = ens33 => internet = ????

# Step 38 - Change the reporting information. Open reporting.conf and change the MongoDB entry to yes:
# gedit reporting.conf
# enabled = no => enabled = yes

# Step 39 - Do not touch the first window with command “cuckoo rooter –sudo –group jonald”. Go to another terminal and start cuckoo:
# cuckoo

# Step 40 - In a third terminal, start the cuckoo web server
# cuckoo web --host 127.0.0.1 --port 8080

# Step 41 - Access the cuckoo web interface via browser
# Open http://127.0.0.1:8080 in the browser
