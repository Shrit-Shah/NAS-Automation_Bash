#!/bin/bash

usr_name=$1
server_bak_dir=$2
client_ip=$3

which yum &>> /dev/null
if [ $? -eq 0 ]
then
    yum list --installed nfs-utils &>> /dev/null
    if [ $? -ne 0 ]   # Not equal to zero
    then
        yum install nfs-utils -y # NAS software installation
    fi
        systemctl enable --now nfs-server # Starting the NFS service

fi

which apt &>> /dev/null     # Raspbian
if [ $? -eq 0 ]
then
    apt list --installed nfs-kernel-server 2>> /dev/null | grep nfs-kernel-server &>> /dev/null
    if [ $? -ne 0 ]
    then
        apt install nfs-kernel-server -y
    fi
        systemctl enable --now nfs-server # Starting the NFS service
    
fi

mkdir /home/${usr_name}/Desktop/${server_bak_dir}  # Create server backup folder
chmod 777 /home/${usr_name}/Desktop/${server_bak_dir}

echo "/home/${usr_name}/Desktop/${server_bak_dir} *(rw,no_root_squash)" | cat > /etc/exports

systemctl restart nfs-server # Restarting NAS Server


exit