#add output to SMB
#add recursive to dirsearch


#Copyright 2020, 4UT0M4T0N
#This program is free software: you can redistribute it and/or modify it under the terms of version 2 of the GNU General Public License as published by the Free Software Foundation.  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.  For a copy of the GNU General Public License, see <https://www.gnu.org/licenses/>.

#!/bin/bash

NONE='\e[00m'
RED='\e[01;31m'
GREEN='\e[01;32m'
YELLOW='\e[01;33m'
PURPLE='\e[01;35m'
CYAN='\e[01;36m'
WHITE='\e[01;37m'
GRAY='\e[01;90m'
BOLD='\e[1m'
UNDERLINE='\e[4m'
lb="\n*********************************************************************\n"

change=1
nmap=2
dir_http=3
dir_https=4
smb=5
nikto=6
smtp=7
snmp=8
add=9
delete=10
help=11
coffee=12
close=13
declare -a custom_commands

BANNER="${YELLOW}
          _                                        
  \      | |                              _         
 _____   | | _____     ____ _____  ____ _| |_ _____ 
(____ |  | |(____ |   / ___|____ |/ ___|_   _) ___ |
/ ___ |  | |/ ___ |  ( (___/ ___ | |     | |_| ____|
\ ____|   \_)_____|   \____)_____|_|      \__)_____)
${GRAY}Author: 4UT0M4T0N${NONE}\n\n"


                                                                                                                                                                                                          
help() {
	echo -e "${GREEN}\n$lb\nA la carte v0.1\nAuthor: 4UT0M4T0N, Copyright 2020\nComments or suggestions? Find me on Twitter (@4UT0M4T0N) or Discord (#1276).  Trolls > /dev/null\n\nThis tool helps automate repetitive initial enumeration steps.  Some of the most common functions are included as default options, but you can also add your own custom commands which will be saved across sessions.\n\nUSAGE\n./alacarte.sh [target][:port] [command]\n\nTARGET\nIPv4 address (can include sub-dirs)\n\nCOMMAND\nnmap - Quick TCP, Quick UDP (requires sudo), Full TCP, and Vuln scans\ndir_http - Runs dirsearch, dirb, and gobuster against HTTP\ndir_https - Runs dirsearch, dirb, and gobuster against HTTPS\nsmb - Runs enum4linux, nbtscan, nmap enum/vuln scans, and smbclient\nnikto - well...nikto\nsmtp - requires SMTP enumeration Python script and username list\nsnmp - Runs OneSixtyOne, snmp-check, and snmpwalk\n\nEXAMPLES\n./alacarte.sh\n./alacarte.sh 192.168.1.5 -- sets target IP\n./alacarte.sh 192.168.1.5/supersecretfolder -- sets target IP (including sub-directory)\n./alacarte.sh 192.168.1.5:443 -- sets target IP and port\n./alacarte.sh 192.168.1.5 nmap -- sets target IP and kicks off nmap\n./alacarte.sh 192.168.1.5:443 nmap -- sets IP, port, and kicks of command\n$lb${NONE}"
menu

}

ip_check() {
	if [[ $targetIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
		return 1
	else
		return 0
	fi
}


call_option() {
	
	while true
	do 
		ip_check
		if [ $? == 1 ] || [ $choice == 1 ] || [ $choice == 9 ] || [ $choice == 10 ] || [ $choice == 11 ] || [ $choice == 12 ] || [ $choice == 13 ]; then
			break
		else
			while true
			do
				read -p "Enter target[:port]: " targetIP
				ip_check
				if [ $? == 1 ]; then
					break
				else
					echo "Bad IP address. Try again: "
				fi
			done
		fi
	done
	case $choice in
		#change target
		$change)
			while true
			do
				read -p "Enter target[:port]: " targetIP
				ip_check
				if [ $? == 0 ]; then
					read -p "Bad IP Address.  Try again: " targetIP
				else	
					break
				fi
			done
			echo
			;;


		#nmap
		$nmap|"nmap")
			mkdir ./Recon/nmap 2>/dev/null
			echo -e "${GREEN}${BOLD}===== Running Quick Nmap TCP CONNECT scan ======${NONE}"
			cmd="nmap -sT -Pn --top-ports 100 -T4 --reason -v -oN ./Recon/nmap/nmap-quick_$targetIP.results $targetIP"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			
			echo -e "${GREEN}${BOLD}===== Running Nmap UDP scan ======${NONE}"
			cmd="nmap -sU -Pn --top-ports 100 -T4 -v -oN ./Recon/nmap/nmap-quick-udp_$targetIP.results $targetIP"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			
			echo -e "${GREEN}${BOLD}===== Running Full Nmap TCP CONNECT scan ======${NONE}"
			cmd="nmap -sT -Pn -A -p- -T4 -v -oN ./Recon/nmap/nmap-full_$targetIP.results $targetIP"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			
			echo -e "${GREEN}${BOLD}===== Running Full Nmap vuln scan ======${NONE}"
			cmd="nmap -sT -Pn -A --script vuln -p- -T4 -v -oN ./Recon/nmap/nmap-vulns_$targetIP.results $targetIP"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			;;
				
		#dir enum
		$dir_http|"dir_http")
			mkdir ./Recon/http_dir 2>/dev/null
			echo -e "${GREEN}${BOLD}===== Running dirsearch =====${NONE}\n"
			cmd="python3 $(locate -b "dirsearch.py" | head -n 1) -R 3 -u http://$targetIP -e php,txt,html,asp --simple-report ./Recon/http_dir/http-dirsearch_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
		
			echo -e "${GREEN}${BOLD}===== Running Gobuster =====${NONE}\n"
			cmd="gobuster dir -u http://$targetIP -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o ./Recon/http_dir/http-gobuster_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			
			echo -e "${GREEN}${BOLD}===== Running Dirb =====${NONE}\n"
			cmd="dirb http://$targetIP /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -w -o ./Recon/http_dir/http-dirb_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			;;
		
		#HTTPS
		$dir_https|"dir_https")
			echo -e "${GREEN}${BOLD}===== Running dirsearch =====${NONE}\n"
			cmd="python3 $(find / -name "dirsearch.py" -type f 2>/dev/null -print -quit) -u https://$targetIP -e php,txt,html,asp --simple-report ./Recon/https-dirsearch_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
		
			echo -e "${GREEN}${BOLD}===== Running Gobuster =====${NONE}\n"
			cmd="gobuster dir -u https://$targetIP -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o ./Recon/https-gobuster_$targetIP.results"
		

			echo -e "${GREEN}${BOLD}===== Running Dirb =====${NONE}\n"
			cmd="dirb https://$targetIP /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -w -o ./Recon/https-dirb_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			;;
		
		#SMB
		$smb|"smb")
			mkdir ./Recon/SMB 2>/dev/null
			out="./Recon/SMB/enum4linux_$targetIP.results"
                        echo -e "${GREEN}${BOLD}===== Running enum4linux =====${NONE}\n"
			cmd="enum4linux -a $targetIP > ./Recon/SMB/enum4linux_$targetIP.results"
                        echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			printf '\n'

                        echo -e "${GREEN}${BOLD}===== Running nbtscan =====${NONE}\n"
			cmd="nbtscan -r $targetIP > ./Recon/SMB/nbtscan_$targetIP.results"
                        echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			printf '\n'

                        echo -e "${GREEN}${BOLD}===== Running nmap smb-os-discovery =====${NONE}\n"
                        cmd="nmap -Pn -v -p 139,445 --script=smb-os-discovery $targetIP -oN ./Recon/SMB/nmap-smb-os-discovery_$targetIP.results"
                        echo -e "${RED}${BOLD}$cmd\n${NONE}"
                        $cmd
                        printf '\n'
			
			echo -e "${GREEN}${BOLD}===== Running nmap smb-protocols =====${NONE}\n"
                        cmd="nmap -Pn -v -p139,445 --script=smb-protocols $targetIP -oN ./Recon/SMB/nmap-smb-protocols_$targetIP.results"
                        echo -e "${RED}${BOLD}$cmd\n${NONE}"
                        $cmd
                        printf '\n'


                        echo -e "${GREEN}${BOLD}===== Running nmap smb vuln scripts =====${NONE}\n"
                        cmd="nmap -Pn -v -p 139,445 --script=smb-vuln* $targetIP -oN ./Recon/SMB/nmap-smb-vulns_$targetIP.results"
                        echo -e "${RED}${BOLD}$cmd\n${NONE}"
                        $cmd
                        printf '\n'

			echo -e "${GREEN}${BOLD}===== Running nmap SMB scripts =====${NONE}\n"
			cmd="nmap -Pn -p 139,445 --script=smb-enum* $targetIP -oN ./Recon/SMB/nmap-smb-enum_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			printf '\n'

			echo -e "${GREEN}${BOLD}===== Enumerating host with smbmap =====\n${NONE}"
			cmd="smbmap -H $targetIP > ./Recon/SMB/smbmap_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			
			echo -e "${GREEN}${BOLD}===== Listing shares with smbclient =====${NONE}\n"
			cmd="smbclient -L //$targetIP > ./Recon/SMB/smbclient-list_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd\n${NONE}"
			$cmd
			echo ""
			
			echo -e "${GREEN}${BOLD}===== Testing for anonymous login =====${NONE}\n"
			cmd="smbclient -L //$targetIP -U\"%\""
			echo -e "${RED}${BOLD}$cmd${NONE}\n" 
			$cmd
			;; 
		#Nikto
		$nikto|"nikto")
			mkdir ./Recon/Nikto 2>/dev/null
			touch ./Recon/Nikto/http-nikto_$targetIP.results
			echo -e "${GREEN}${BOLD}===== Running Nikto query =====${NONE}\n"
			cmd="nikto -host $targetIP -port 80 -maxtime=60s -C all -Format txt -output ./Recon/Nikto/http-nikto_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""
			
			touch ./Recon/Nikto/https-nikto_$targetIP.results
			cmd="nikto -host $targetIP -port 443 -maxtime=60s -C all -Format txt -output ./Recon/Nikto/https-nikto_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd${NONE}"
			$cmd
			;;	
	
		#SMTP
		$smtp|"smtp")	
			echo -n "Filename containing usernames: "
			read file
			echo -e "${GREEN}${BOLD}===== Enumerating SMTP =====${NONE}\n"
			cmd="python smtp_enum.py $targetIP $file > smtp_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""
			;;	

		#SNMP
		$snmp|"snmp")
			mkdir ./Recon/SNMP 2>/dev/null	
			echo -e "${GREEN}${BOLD}===== Onesixtyone =====${NONE}\n"
			touch "Recon/snmp_communities"
			echo "public" > Recon/snmp_communities
			echo "private" >> Recon/snmp_communities
			echo "manager" >> Recon/snmp_communities
			cmd='onesixtyone -c Recon/snmp_communities '$targetIP''
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""		
	
			echo -e "${GREEN}${BOLD}===== snmp-check =====${NONE}\n"
			touch "Recon/snmp_check_results"
			cmd="snmp-check $targetIP -c Public"
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""

			echo -e "${GREEN}${BOLD}===== snmpwalk users =====${NONE}\n"
			touch "Recon/snmpwalk_results_users"
			cmd="snmpwalk -c public -v1 $targetIP 1.3.6.1.4.1.77.1.2.25 > ./Recon/SNMP/snmpwalk-users_$targetIP.results"       	
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""

			echo -e "${GREEN}${BOLD}===== snmpwalk running processes =====${NONE}\n"
			touch "Recon/snmpwalk_results_processes"
			cmd="snmpwalk -c public -v1 $targetIP 1.3.6.1.2.1.25.4.2.1.2 > ./Recon/SNMP/snmpwalk-processes_$targetIP.results"       	
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""

			echo -e "${GREEN}${BOLD}===== snmpwalk installed software =====${NONE}\n"
			touch "Recon/snmpwalk_results_processes"
			cmd="snmpwalk -c public -v1 $targetIP 1.3.6.1.2.1.25.6.3.1.2 > ./Recon/SNMP/snmpwalk-software_$targetIP.results"       	
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""

			echo -e "${GREEN}${BOLD}===== snmpwalk all=====${NONE}\n"
			touch "Recon/snmpwalk_all_results"
			cmd="snmpwalk -c public -v1 -t 10 $targetIP > snmpwalk-all_$targetIP.results"
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""
			;;		
		
		$add|"add")
			read -p "Type the command to add. Use 'target' as an IP placeholder (i.e ping target): " new_command
			#len=${#list[@]}
			echo "$new_command" >> "$custom_file"
			if [ $loaded -eq 1 ]; then
				list+=( "$new_command" )
			fi
			;;
		$delete|"delete")
			if [ -s alacarte.txt ]; then
				read -p "Enter the command number you'd like to delete: " num
			else
				echo -e "Error: There are no custom commands saved.\n"
				menu
			fi	
			if [ $num -lt 14 ] || [ $num -gt ${#list[@]} ] || ! [[ $num =~ ^[0-9]+ ]]; then
				echo "Invalid selection.  Please try again."
		      		call_option
			else		
				i=$((num-1))
				cmd=${list[$i]}
				echo -ne "Are you sure you want to delete ${RED}$cmd${NONE} [y/N]?"
			       	read a	
				if [ "$a" == "y" ] || [ "$a" == "Y" ]; then
					echo Deleting $cmd
					#unset list[$i]
					list=( "${list[@]:0:$i}" "${list[@]:$num}" )

					#remove from alacarte.txt
					sed -e s/"$cmd"//g -i alacarte.txt
					sed '/^$/d' -i alacarte.txt
				fi 
			fi
			;;

		$help)
			help
			;;
		$coffee)
			echo -e "${YELLOW}${BOLD}Coffee, pwn, repeat.${NONE}\n"
			;;
		$close|"exit")
			echo -e "${YELLOW}${BOLD}Thanks for playing.${NONE}\n"
			exit 0
			;;
			
		*)
			echo -e "${GREEN}${BOLD}===== Running Custom Command  =====${NONE}\n"
			cmd="${list[(($choice-1))]}"
			cmd="${cmd//target/$targetIP}"
			echo -e "${RED}${BOLD}$cmd${NONE}\n"
			$cmd
			echo ""
			;;
	esac
	echo	
}


list=("Change target" "nmap" "Directory enumeration (HTTP)" "Directory enumeration (HTTPS)" "SMB enumeration" "Nikto scan" "SMTP user scan" "SNMP enumeration" "Add a custom command" "Delete a custom command" "Help" "Out of ideas..." "Exit")

menu () {
	echo -e "\n\n"
	ip_check
	if [ $? == 1 ]; then
		echo -e "Current target: ${RED}$targetIP${NONE}"
	else
		echo -e "Current target: ${RED}Not set${NONE}"
	fi
	echo -e "\n${UNDERLINE}DEFAULT COMMANDS${NONE}"
	for i in {0..12};
	do
		echo \($(($i+1))\) ${list[$i]}
	done

	if [[ $loaded -eq 0 && -s "$custom_file" ]]; then
		loaded=1
		readarray -t tmp < $custom_file
		list+=("${tmp[@]}")
	fi

		echo -e "\n${UNDERLINE}CUSTOM COMMANDS${NONE}"
	if [ -s alacarte.txt ]; then
		len=${#list[@]}
		for j in $(seq 13 $((len-1)));
		do
			echo \($(($j+1))\) ${list[$j]}	       
		done
	else
		echo "None"
	fi
	
	echo -ne "\n${GREEN}Select a # to run: ${NONE}"
	read choice
	echo

	while true
	do
		local l=${#list[@]}
		if [[ $choice =~ ^[0-9]+$ ]] && [[ $choice -le ${#list[@]} ]]; then
			break
		else
			read -p "Invalid selection.  Try again: " choice
		fi
	done
	call_option
        menu	
}

echo -e "$BANNER"
mkdir Recon 2>/dev/null
loaded=0 #flag for command file load
custom_file="./alacarte.txt"
[ ! -f "$custom_file" ] && echo -e "${RED}${BOLD}Creating alacarte.txt to save custom commands.${NONE}" && touch alacarte.txt

if [[ "$*" == "-h" ]]; then
	help
elif [ -z $1 ]; then
	read -p 'Enter target[:port] or -h for help: ' targetIP
	if [ "$targetIP" == "-h" ]; then
		help
	else
		ip_check
		if [ $? == 1 ]; then
			printf 'Target has been set as %s\n\n' $targetIP
		else
			echo -e "Invalid target.\n"
			targetIP=null
		fi
		menu
	fi
elif [ "$#" -eq 1 ]; then
	targetIP=$1
	printf 'Target has been set as %s\n\n' $targetIP
	menu
elif [ "$#" -eq 2 ]; then
	targetIP=$1
	choice=$2
	printf 'Target has been set as %s\n\n' $targetIP
	call_option
else
	help
fi		


