#!/bin/bash

clear
which figlet &>> /dev/null
if [ $? -eq 0 ]
then 
    figlet NAS Automation 
    echo -e "   By:\t\tShrit Shah\tHarshil Shah\tNisarg Khacharia"
else
    echo -e "\v\v \t\t\t\t NAS AUTOMATION \n"
fi


new_setup()
{
    echo -e "\vWhere do you want to setup your storage server? \n\n\t1) Another system on the same LAN. \n\t2) In a cloud virtual machine."
    read -p "--> " server_location

    if [ $server_location -eq 1 ]
    then
        client_ip=$(hostname -I | awk {'print $1}') # Client Private IP-address
        read -p "Enter private ip-address of the server system: " server_ip
        
        # IP validation - REGEX: ((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}

        echo -e "\nEstablishing connection to $server_ip ... \n"

        ping -c 3 $server_ip &>> /dev/null
        if [ $? -eq 0 ]
        then 
            echo "Connection Successful"

            read -p "Enter Server username: " usr_name
            scp server.sh  ${usr_name}@${server_ip}:/tmp/ &>> /dev/null
            if [ $? -eq 0 ]
            then
                echo "SSH connection successful"
                
                read -p "Name of backup folder on the server: " server_bak_dir
                cmd=$(echo sudo -S -p "Enter\ sudo\ password\ of\ server-side: " bash /tmp/server.sh ${usr_name} ${server_bak_dir} ${client_ip})
                echo "Configuring NAS server on $server_ip ..."
                ssh ${usr_name}@${server_ip} $cmd
                if [ $? -eq 0 ]
                then   
                    echo -e "\nServer configuration successful\n"
                    read -p "Name of backup folder here on the CLIENT: " client_dir
                    mkdir ${HOME}/Desktop/${client_dir}
                    
                    sudo mount  ${server_ip}:/home/${usr_name}/Desktop/${server_bak_dir}  ${HOME}/Desktop/${client_dir} #Mounting directories
                    if [ $? -eq 0 ]
                    then    
                        echo -e "\v\tSetup Successful"
                        exit
                    fi
                else
                    echo "Server configuration failed"
                fi
            else
                echo -e "SSH connection failed\nPlease run the below commands manually on the server system & run this script again."
                echo -e "\v\tsudo yum -y install openssh \n\tsudo systemctl enable --now sshd"
            fi
        else
            echo "Connection Failed"
        fi

    elif [ $server_location -eq 2 ]
    then
        echo "Coming Soon!!"
        #$client_ip=$(dig +short myip.opendns.com @resolver1.opendns.com) # Client Public IP-address
    
    else
        echo -e "\vInvalid Input"
    fi


}

modify_setup()
{
    echo "Coming Soon!!"
}

uninstall()
{
    echo "Coming Soon!!"
}

while [ 0 ]
do
    echo "-----------------------------------------------------------------------------"
    echo -e "\v\t1) Setup new storage \n\t2) Modify existing configuration \n\t3) Remove all NAS connections \n\t00) Exit" #Main Menu

    read -p "--> " menu_opt

    case $menu_opt in 
        1) 
            new_setup
            ;;
        2) 
            modify_setup
            ;;
        3) 
            uninstall
            ;;
        00) 
            echo "Exiting"
            break
            ;;
        *)
            echo "Select valid option from the menu"
            ;;
    esac
done

exit 0 &>> /dev/null