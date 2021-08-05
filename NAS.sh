#!/bin/bash

$client_ip = $(hostname -I | awk {'print $1}') # Client Private IP-address
$client_ip = $(dig +short myip.opendns.com @resolver1.opendns.com) # Client Public IP-address

read server_ip  # Geting Server IP-address from user

ssh -i 
# Server Side (OS which is going to store the data)

yum install nfs-utils  # NAS software installation
systemctl enable --now nfs-server # Starting the NFS service

mkdir $server_bak_dir  # Create backup folder

cat $server_bak_dir $client_ip (rw,no_root_squash) >> /etc/exports

# Client Side (This OS)

mkdir $client_dir

mount $server_ip:$server_bak_dir $client_dir

