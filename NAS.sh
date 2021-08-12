#!/bin/bash

#$client_ip=$(hostname -I | awk {'print $1}') # Client Private IP-address
#$client_ip=$(dig +short myip.opendns.com @resolver1.opendns.com) # Client Public IP-address

#read server_ip  # Geting Server IP-address from user

#ssh -i 
# Server Side (OS which is going to store the data)

#yum install nfs-utils  # NAS software installation
#systemctl enable --now nfs-server # Starting the NFS service

#mkdir $server_bak_dir  # Create backup folder

#cat $server_bak_dir $client_ip (rw,no_root_squash) >> /etc/exports

# Client Side (This OS)

#mkdir $client_dir

#mount $server_ip:$server_bak_dir $client_dir

new_setup()
{
    echo -e "\vWhere do you want to setup your storage server? \n\n\t1) Another system on the same LAN. \n\t2) In a cloud virtual machine."
    read -p "--> " server_location

    if [ $server_location -eq 1 ]
    then
        client_ip=$(hostname -I | awk {'print $1}') # Client Private IP-address
        read -p "Enter private ip-address of the server system: " server_ip
        
        # IP validation - REGEX

        echo -e "Establishing connection to $server_ip ... \n"
        ping -c 5 $server_ip >> /dev/null
        if [ $? ]
        then 
            echo "Connection Successful"
        else
            echo "Connection Failed"
        fi
        
    fi
}

while [ 0 ]
do
    echo -e "\v1) Setup new storage \n2) Modify existing configuration \n00) Exit" #Main Menu

    read -p "--> " menu_opt

    case $menu_opt in 
        1) 
            new_setup
            ;;
        2) echo "Menu 2"
            ;;
        00) echo "Exit opt"
            break
            ;;
        *)
            echo "Select valid option from the menu"
            ;;
    esac

done

exit 0