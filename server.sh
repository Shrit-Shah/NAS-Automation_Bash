#!/bin/bash

usr_name=$1
server_bak_dir=$2
client_ip=$3

rpm -q nfs-utils >> /dev/null
if [ $? -eq 1 ]
then
    yum install nfs-utils  # NAS software installation
    systemctl enable --now nfs-server # Starting the NFS service
fi
mkdir /home/${usr_name}/${server_bak_dir}  # Create backup folder

echo "$server_bak_dir $client_ip (rw,no_root_squash)" | cat >> /etc/exports


exit 0