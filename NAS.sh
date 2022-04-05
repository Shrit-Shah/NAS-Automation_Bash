#!/bin/bash

which yum &>> /dev/null
if [ $? -eq 0 ]
then
    which figlet &>> /dev/null
    if [ $? -ne 0 ]
    then 
        sudo yum install figlet -y &>> /dev/null
    fi
fi

which apt &>> /dev/null
if [ $? -eq 0 ]
then
    which figlet &>> /dev/null
    if [ $? -ne 0 ]
    then 
        sudo apt install figlet -y &>> /dev/null
    fi
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

    if [ $server_location -eq 1 ] 2>> /dev/null
    then
        client_ip=$(hostname -I | awk {'print $1}') # Client Private IP-address
        printf "${C}[${W}+${C}] Enter Private ip-address of the server system: ${NC}" 
        read server_ip

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
                
                printf "${C}[${W}+${C}] Name & absolute path of backup folder on the Server: ${NC}" 
                read server_bak_dir
                cmd=$(echo sudo -S -p "Enter\ sudo\ password\ of\ server-side: " bash /tmp/server.sh ${usr_name} ${server_bak_dir} ${client_ip})
                echo -e "\n${C}[${W}*${C}] Configuring NAS server on $server_ip...${NC}\n"
                ssh ${usr_name}@${server_ip} $cmd
                if [ $? -eq 0 ]
                then   
                    echo -e "\n${G}[${W}^${G}] ${BG}Server configuration Successful${NC}\n"
                    printf "${C}[${W}+${C}] Name & absolute path of backup folder here on the Client: ${NC}" 
                    read client_dir
                    mkdir -p ${client_dir} &>> /dev/null
                    
                    sudo mount  ${server_ip}:${server_bak_dir}  ${client_dir} #Mounting directories
                    (sudo crontab -l; echo "@reboot mount  ${server_ip}:${server_bak_dir}  ${client_dir}") | sort -u | sudo crontab -
                    if [ $? -eq 0 ]
                    then    
                        echo -e "\n${C}[${W}*${C}] Finalizing Setup...${NC}\t[This may take a minute]\n"
                        cp Thank_You.txt ${client_dir}/
                        echo -e "\n${G}[${W}^${G}] ${BG}Server<-->Client linking Successful${NC}\n"

                        backup_scheduling $client_dir 
                        rm -f cron_file &>> /dev/null
                        
                        echo -e "\n${G}[${W}^${G}] ${BG}Setup Successful${NC}\n"
                        end
                    fi
                else
                    echo -e "${R}[${W}!${R}] ${BR}${blink}Server configuration Failed${NC}"
                fi
            else
                echo -e "${R}[${W}!${R}] ${BR}${blink}SSH connection Failed${NC}"
                echo -e "Please run the below commands manually on the server system & run this script again."
                echo -e "\v\tsudo yum -y install openssh \n\tsudo systemctl enable --now sshd"
            fi
        else
            echo -e "${R}[${W}!${R}] ${BR}${blink}Connection Failed${NC}"
        fi

    elif [ $server_location -eq 2 ] 2>> /dev/null
    then
        client_ip=$(dig +short myip.opendns.com @resolver1.opendns.com) # Client Public IP-address
        printf "${C}[${W}+${C}] Enter Public ip-address of the server system: ${NC}" 
        read server_ip
        
        # IP validation - REGEX: ((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}

        echo -e "\n${C}[${W}*${C}] Establishing connection to $server_ip ... ${NC}\n"

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
                
                printf "${C}[${W}+${C}] Name & absolute path of backup folder on the Server: ${NC}" 
                read server_bak_dir
                cmd=$(echo sudo bash /tmp/server.sh ${usr_name} ${server_bak_dir} ${client_ip})
                echo -e "\n${C}[${W}*${C}] Configuring NAS server on $server_ip ...${NC}\n"
                ssh -i $key_file ${usr_name}@${server_ip} $cmd
                if [ $? -eq 0 ]
                then   
                    echo -e "\n${G}[${W}^${G}] ${BG}Server configuration Successful${NC}\n"
                    printf "${C}[${W}+${C}] Name & absolute path of backup folder here on the Client: ${NC}"
                    read client_dir
                    mkdir -p ${client_dir} &>> /dev/null
                    
                    sudo mount  ${server_ip}:${server_bak_dir} ${client_dir} #Mounting directories
                    (sudo crontab -l; echo "@reboot mount  ${server_ip}:${server_bak_dir}  ${client_dir}") | sort -u | sudo crontab -
                    if [ $? -eq 0 ]
                    then    
                        echo -e "\n${C}[${W}*${C}] Finalizing Setup...${NC}\t[This may take a minute]\n"
                        cp Thank_You.txt ${client_dir}/
                        echo -e "${G}[${W}^${G}] ${BG}Server<-->Client linking Successful${NC}\n"

                        backup_scheduling $client_dir 
                        rm -f cron_file &>> /dev/null

                        echo -e "\n${G}[${W}^${G}] ${BG}Setup Successful${NC}\n"
                        end
                    fi
                else
                    echo -e "${R}[${W}!${R}] ${BR}${blink}Server configuration Failed${NC}"
                fi
            else
                echo -e "${R}[${W}!${R}] ${BR}${blink}SSH connection Failed${NC}"
                echo -e "${C}[${W}*${C}]Please run the below commands manually on the Server system & run this script again.${NC}"
                echo -e "\v\tsudo yum -y install openssh \n\tsudo systemctl enable --now sshd"
            fi
        else
            echo -e "${R}[${W}!${R}] ${BR}${blink}Connection Failed${NC}"
        fi

    
    else
        echo -e "${R}[${W}!${R}] ${BR}${blink}Select valid option from the menu${NC}"
    fi


}

backup_scheduling()
{
client_dir=$1
while [ 0 ]
do 
    printf "\v${B}[${W}?${B}] Do you want to backup directories automatically? [Yes/No]:${NC}"
    read menu_opt
    case $menu_opt in
        Yes|Y|y|yes|YES)
            file_location=(); i=0
            echo -e "\n${C}[${W}*${C}]Enter absolute path of the Files/Directories you want to backup.${NC}\n"
            while [ 0 ]
            do 		
                printf "${C}[${W}+${C}] Location $((i+1)): ${NC}"
                read file
		        if [ -z $file ]
		        then
			        break
		        fi
		        file_location[$i]=$file
		        ((i++))
            done
            echo -e "${C}[${W}*${C}]These files/directories will backup automatically.\n${NC}"
            for i in ${!file_location[@]}; do
	            echo -e "\t ${G}$((i+1)):${NC} ${file_location[$i]}"
            done
            while [ 0 ]
            do 
                echo -e "\v${B}[${W}?${B}] How often do you want to backup the above items?\n\n\t${C}[${W}1${C}] ${Y}At every Minute \n\t${C}[${W}2${C}] ${Y}Hourly\n\t${C}[${W}3${C}] ${Y}Daily\n\t${C}[${W}4${C}] ${Y}Weekly\n\t${C}[${W}5${C}] ${Y}Monthly\n\t${C}[${W}6${C}] ${Y}Yearly ${NC}\n\n"
                printf "${C}[${W}+${C}] Select your option: ${NC}"
                read cron_time_opt
                case $cron_time_opt in
                    1)
                        cron_time='*/1 * * * *'
                        break
                        ;;
                    2)
                        cron_time='@hourly'
                        break
                        ;;
                    3)
                        cron_time='@daily'
                        break
                        ;;
                    4)
                        cron_time='@weekly'
                        break
                        ;;
                    5)
                        cron_time='@monthly'
                        break
                        ;;
                    6)
                        cron_time='@yearly'
                        break
                        ;;
                    *)
                        echo -e "${R}[${W}!${R}] ${BR}${blink}Select valid option from the menu${NC}"
                        ;;
                esac
            done
            if [ -e cron_file ]
            then
                rm cron_file &>> /dev/null
                touch cron_file
            else
                touch cron_file
            fi
            for i in ${!file_location[@]}; 
            do
                echo -e "$cron_time cp -rf ${file_location[$i]} $client_dir" >> "cron_file"
            done

            crontab -l > /tmp/crontab_new  2>> /dev/null
            cat < cron_file >> /tmp/crontab_new  2>> /dev/null
            crontab /tmp/crontab_new  
            
            echo -e "\n${G}[${W}^${G}] ${BG}Backup Scheduled${NC}\n"
            break 
            ;;
        No|N|n|no|NO)
            echo -e "\n${C}[${W}*${C}]You will have to backup files manually by copy pasting into the $client_dir directory.${NC}"
            break
            ;;
        *)
            echo -e "${R}[${W}!${R}] ${BR}${blink}Enter 'Yes' or 'No'${NC}"
            ;;
    esac
done     
}

uninstall()
{
    printf "${C}[${W}+${C}] Enter the Client-side folder location: ${NC}" 
    read client_dir
    sudo umount $client_dir  2>> /dev/null

    crontab -l | grep -v "${client_dir}"  > /tmp/crontab_new
    crontab /tmp/crontab_new

    sleep 2

    sudo rmdir $client_dir  2>> /dev/null
    if [ $? -eq 0 ]
    then
        echo -e "\n${G}[${W}^${G}] ${BG}Client-side uninstallation Successful${NC}"
        echo -e "\n${R}NOTE: Only the NAS configurations are removed. The backup data on the server drive is not deleted.${NC}"
    else
        echo -e "\n${R}[${W}!${R}] ${BR}${blink}Uninstallation Failed${NC}"
    fi
}

end()
{
    printf "\n${C}[${W}*${C}] ${W}Press ENTER key to continue...${NC}\n\n"; read
    clear
    exit 0 &>> /dev/null
}

while [ 0 ]
do
    echo -e "\v-----------------------------------------------------------------------------"
    echo -e "\v\t${C}[${W}1${C}] ${Y}Setup new storage \n\t${C}[${W}2${C}] ${Y}Uninstall NAS configuration \n\t${C}[${W}0${C}] ${Y}Exit${NC}\n" #Main Menu

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
            echo -e "${C}[${W}*${C}] ${R}Exiting...${NC}"
            end
            break
            ;;
        *)
            echo -e "${R}[${W}!${R}] ${BR}${blink}Select valid option from the menu${NC}"
            ;;
    esac
done

end
