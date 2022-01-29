#!/bin/bash

which figlet &>> /dev/null
if [ $? -ne 0 ]
then 
    sudo yum install figlet -y
fi
#--------------------ASCII Font Values---------------
NC="\e[0m" #Reset/No Color modifications
#Font Colour with BOLD
R="\e[1;31m" #RED
G="\e[1;32m" #Green
Y="\e[1;33m" #Yellow/Brown
B="\e[1;34m" #Blue
C="\e[1;36m" #Cyan
W="\e[1;37m" #White/Gray
#Background colour
BR="\e[0;1;41m" #RED
BG="\e[0;1;42m" #Green
BY="\e[0;1;43m" #Yellow/Brown
BC="\e[0;1;46m" #Cyan
BW="\e[0;1;47m" #White/Gray

blink="\e[5m" #Blinking Text
#---------------------------------------------------------------

clear
echo -e "$W"; figlet -t Smart Backup; echo -e "$NC"
echo -e "\t\t\e[31;1m:::::: \e[0;7mBy: Shrit Shah & Yashvi Soni${NC} \e[31;1m::::::${NC}"

new_setup()
{
    echo -e "\v${B}[${W}?${B}] Where do you want to setup your storage server? \n\n\t${C}[${W}1${C}] ${Y} Another system on the same LAN. \n\t${C}[${W}2${C}] ${Y} In a cloud virtual machine.${NC}\n\n"
    printf "${C}[${W}+${C}] Select your option: ${NC}"
    read server_location

    if [ $server_location -eq 1 ]
    then
        client_ip=$(hostname -I | awk {'print $1}') # Client Private IP-address
        printf "${C}[${W}+${C}] Enter Private ip-address of the server system: ${NC}" 
        read server_ip
        
        # IP validation - REGEX: ((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}

        echo -e "\n${C}[${W}*${C}] Establishing connection to $server_ip ... \n${NC}"

        ping -c 3 $server_ip &>> /dev/null
        if [ $? -eq 0 ]
        then 
            echo -e "${G}[${W}^${G}] ${BG}Connection Successful${NC}${NC}\n"

            printf "${C}[${W}+${C}] Enter Server username: ${NC}" 
            read usr_name
            scp server.sh  ${usr_name}@${server_ip}:/tmp/ &>> /dev/null
            if [ $? -eq 0 ]
            then
                echo -e "\n${G}[${W}^${G}] ${BG}SSH connection Successful${NC}\n"
                
                printf "${C}[${W}+${C}] Name of backup folder on the Server: ${NC}" 
                read server_bak_dir
                cmd=$(echo sudo -S -p "Enter\ sudo\ password\ of\ server-side: " bash /tmp/server.sh ${usr_name} ${server_bak_dir} ${client_ip})
                echo -e "\n Configuring NAS server on $server_ip...\n"
                ssh ${usr_name}@${server_ip} $cmd
                if [ $? -eq 0 ]
                then   
                    echo -e "\n${G}[${W}^${G}] ${BG}Server configuration Successful${NC}\n"
                    printf "${C}[${W}+${C}] Name of backup folder here on the Client: ${NC}" 
                    read client_dir
                    mkdir -p ${HOME}/Desktop/${client_dir} &>> /dev/null
                    
                    sudo mount  ${server_ip}:/home/${usr_name}/Desktop/${server_bak_dir}  ${HOME}/Desktop/${client_dir} #Mounting directories
                    if [ $? -eq 0 ]
                    then    
                        echo -e "\n Finalizing Setup...\t[This may take a minute]\n"
                        cp Thank_You.txt ${HOME}/Desktop/${client_dir}/
                        echo -e "\v\t${G}[${W}^${G}] ${BG}Setup Successful${NC}\n"
                        end
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
        printf "${C}[${W}+${C}] Enter Public ip-address of the server system: ${NC}" 
        read server_ip
        
        # IP validation - REGEX: ((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}

        echo -e "\n Establishing connection to $server_ip ... \n"

        ping -c 3 $server_ip &>> /dev/null
        if [ $? -eq 0 ]
        then 
            echo -e "${G}[${W}^${G}] ${BG}Connection Successful${NC}\n"

            printf "${C}[${W}+${C}] Enter Server username: ${NC}" 
            read usr_name
            printf "${C}[${W}+${C}] Enter location of Cloud-VM's Key file: ${NC}" 
            read key_file
            scp -i $key_file server.sh  ${usr_name}@${server_ip}:/tmp/ &>> /dev/null
            if [ $? -eq 0 ]
            then
                echo -e "\n${G}[${W}^${G}] ${BG}SSH connection Successful${NC}\n"
                
                printf "${C}[${W}+${C}] Name of backup folder on the Server: ${NC}" 
                read server_bak_dir
                cmd=$(echo sudo bash /tmp/server.sh ${usr_name} ${server_bak_dir} ${client_ip})
                echo -e "\n Configuring NAS server on $server_ip ...\n"
                ssh -i $key_file ${usr_name}@${server_ip} $cmd
                if [ $? -eq 0 ]
                then   
                    echo -e "\n${G}[${W}^${G}] ${BG}Server configuration Successful${NC}\n"
                    printf "${C}[${W}+${C}] Name of backup folder here on the Client: ${NC}"
                    read client_dir
                    mkdir -p ${HOME}/Desktop/${client_dir} &>> /dev/null
                    
                    sudo mount  ${server_ip}:/home/${usr_name}/Desktop/${server_bak_dir}  ${HOME}/Desktop/${client_dir} #Mounting directories
                    if [ $? -eq 0 ]
                    then    
                        echo -e "\n Finalizing Setup...\t[This may take a minute]\n"
                        cp Thank_You.txt ${HOME}/Desktop/${client_dir}/
                        echo -e "\v\t${G}[${W}^${G}] ${BG}Setup Successful${NC}\n"
                        end
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
    printf "${C}[${W}+${C}] Enter the Client-side folder location: ${NC}" 
    read client_dir
    sudo umount $client_dir
    sudo rmdir $client_dir
    if [ $? -eq 0 ]
    then
        echo -e "\n ${G}[${W}^${G}] ${BG}Client-side uninstallation Successful${NC}"
    fi

    echo -e "\v ${BR}NOTE: Only the NAS configurations are removed. The backup data on the server drive is not deleted.${NC}"
    end
}

end()
{
    clear
    exit 0 &>> /dev/null
}

while [ 0 ]
do
    #echo "-----------------------------------------------------------------------------"
    echo -e "\v\v\t${C}[${W}1${C}] ${Y}Setup new storage \n\t${C}[${W}2${C}] ${Y}Uninstall NAS configuration \n\t${C}[${W}0${C}] ${Y}Exit${NC}\n" #Main Menu

    printf "${C}[${W}+${C}] Select your option: ${NC}" 
    read menu_opt

    case $menu_opt in 
        1) 
            new_setup
            ;;
        2)  
            uninstall
            ;;
        0) 
            echo "Exiting..."
            end
            break
            ;;
        *)
            echo "Select valid option from the menu"
            ;;
    esac
done

end