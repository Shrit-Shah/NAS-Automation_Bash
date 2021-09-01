#!/bin/bash

usr_name=$1
server_bak_dir=$2
client_ip=$3

rpm -q nfs-utils >> /dev/null
if [ $? -eq 1 ]
then
    sudo yum -y install nfs-utils  # NAS software installation
    systemctl enable --now nfs-server # Starting the NFS service
fi
mkdir /home/${usr_name}/${server_bak_dir}  # Create backup folder
chmod 777 /home/${usr_name}/${server_bak_dir}

echo "/home/${usr_name}/${server_bak_dir} *(rw,no_root_squash)" | cat >> /etc/exports

systemctl restart nfs-server

exit 0