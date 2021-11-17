#!/bin/bash

clear
which figlet &>> /dev/null
if [ $? -eq 0 ]
then 
    figlet NAS Automation 
    echo -e " \t\t\t  By:\tShrit Shah"
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
        read -p "Enter Private ip-address of the server system: " server_ip
        
        # IP validation - REGEX: ((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}

        echo -e "\n Establishing connection to $server_ip ... \n"

        ping -c 3 $server_ip &>> /dev/null
        if [ $? -eq 0 ]
        then 
            echo -e "Connection Successful\n"

            read -p "Enter Server username: " usr_name
            scp server.sh  ${usr_name}@${server_ip}:/tmp/ &>> /dev/null
            if [ $? -eq 0 ]
            then
                echo -e "\nSSH connection successful\n"
                
                read -p "Name of backup folder on the Server: " server_bak_dir
                cmd=$(echo sudo -S -p "Enter\ sudo\ password\ of\ server-side: " bash /tmp/server.sh ${usr_name} ${server_bak_dir} ${client_ip})
                echo -e "\n Configuring NAS server on $server_ip ...\n"
                ssh ${usr_name}@${server_ip} $cmd
                if [ $? -eq 0 ]
                then   
                    echo -e "\nServer configuration successful\n"
                    read -p "Name of backup folder here on the Client: " client_dir
                    mkdir -p ${HOME}/Desktop/${client_dir} &>> /dev/null
                    
                    sudo mount  ${server_ip}:/home/${usr_name}/Desktop/${server_bak_dir}  ${HOME}/Desktop/${client_dir} #Mounting directories
                    if [ $? -eq 0 ]
                    then    
                        echo -e "\n Finalizing Setup...\t[This may take a minute]\n"
                        cp Thank_You.txt ${HOME}/Desktop/${client_dir}/
                        echo -e "\v\tSetup Successful\n"
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
        client_ip=$(dig +short myip.opendns.com @resolver1.opendns.com) # Client Public IP-address
        read -p "Enter Public ip-address of the server system: " server_ip
        
        # IP validation - REGEX: ((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}

        echo -e "\n Establishing connection to $server_ip ... \n"

        ping -c 3 $server_ip &>> /dev/null
        if [ $? -eq 0 ]
        then 
            echo -e "Connection Successful\n"

            read -p "Enter Server username: " usr_name
            read -p "Enter location of Cloud-VM's Key file: " key_file
            scp -i $key_file server.sh  ${usr_name}@${server_ip}:/tmp/ &>> /dev/null
            if [ $? -eq 0 ]
            then
                echo -e "\nSSH connection successful\n"
                
                read -p "Name of backup folder on the Server: " server_bak_dir
                cmd=$(echo sudo bash /tmp/server.sh ${usr_name} ${server_bak_dir} ${client_ip})
                echo -e "\n Configuring NAS server on $server_ip ...\n"
                ssh -i $key_file ${usr_name}@${server_ip} $cmd
                if [ $? -eq 0 ]
                then   
                    echo -e "\nServer configuration successful\n"
                    read -p "Name of backup folder here on the Client: " client_dir
                    mkdir -p ${HOME}/Desktop/${client_dir} &>> /dev/null
                    
                    sudo mount  ${server_ip}:/home/${usr_name}/Desktop/${server_bak_dir}  ${HOME}/Desktop/${client_dir} #Mounting directories
                    if [ $? -eq 0 ]
                    then    
                        echo -e "\n Finalizing Setup...\t[This may take a minute]\n"
                        cp Thank_You.txt ${HOME}/Desktop/${client_dir}/
                        echo -e "\v\tSetup Successful\n"
                        exit
                    fi
                else
                    echo "Server configuration failed"
                fi
            else
                echo -e "SSH connection failed\nPlease run the below commands manually on the Server system & run this script again."
                echo -e "\v\tsudo yum -y install openssh \n\tsudo systemctl enable --now sshd"
            fi
        else
            echo "Connection Failed"
        fi

    
    else
        echo -e "\vInvalid Input"
    fi


}

uninstall()
{
    read -p "Enter the Client-side folder location: " client_dir
    sudo umount $client_dir
    sudo rmdir $client_dir
    if [ $? -eq 0 ]
    then
        echo -e "\n Client-side uninstallation successful"
    fi

    echo -e "\v NOTE: Only the NAS configurations are removed. The backup data on the server drive is not deleted."
    exit
}

while [ 0 ]
do
    echo "-----------------------------------------------------------------------------"
    echo -e "\v\t1) Setup new storage \n\t2) Uninstall NAS configuration \n\t00) Exit" #Main Menu

    read -p "--> " menu_opt

    case $menu_opt in 
        1) 
            new_setup
            ;;
        2)  
            uninstall
            ;;
        00) 
            echo "Exiting"
            exit 0 &>> /dev/null
            break
            ;;
        *)
            echo "Select valid option from the menu"
            ;;
    esac
done

exit 0 &>> /dev/null