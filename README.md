# A la carte

I originally started this tool while studying for the OSCP exam as a quick way to automate some of the routine enumeration commands.  I had used tools like AutoRecon, but found that the fully automated shotgun approach wasn't always what I was looking for, especially in a learning environment.  I wanted more insight into what I was running and more control over what was actually being run, so I created a basic menu-driven enumeration framework that freed me from having to memorize and retype each command while also allowing me to pick what I wanted to run each time, like ordering your dishes a la carte!   

## Guide
The simplicity of the tool makes it extremely easy to run.  The primary script is contained in alacarte.sh and the additional smtp-enum.py and users.txt files are only required for executing the SMTP module.
```  
user@kali:~$ ./alacarte.sh
          _                                         
  \      | |                              _         
 _____   | | _____     ____ _____  ____ _| |_ _____ 
(____ |  | |(____ |   / ___|____ |/ ___|_   _) ___ |
/ ___ |  | |/ ___ |  ( (___/ ___ | |     | |_| ____|
\ ____|   \_)_____|   \____)_____|_|      \__)_____)
Author: 4UT0M4T0N
                                                   
                                                   
Enter target[:port] or -h for help: -h
                                          
A la carte v0.1
Author: 4UT0M4T0N, Copyright 2020
Comments or suggestions? Find me on Twitter (@4UT0M4T0N) or Discord (#1276).  Trolls > /dev/null

This tool helps automate repetive initial enumeration steps.  Some of the most common functions are included as default options, but you can also add your own custom commands which will be saved across ses
sions.

USAGE
./recon.sh [target][:port] [command]

TARGET
IPv4 address (can include sub-dirs)

COMMAND
nmap - Quick, Full, and Vuln scans
dir_http - Runs dirsearch, dirb, and gobuster against HTTP
dir_https - Runs dirsearch, dirb, and gobuster against HTTPS
smb - Runs enum4linux, nbtscan, nmap enum/vuln scans, and smbclient
nikto - well...nikto
smtp - requires SMTP enumeration Python script and username list
snmp - Runs OneSixtyOne, snmp-check, and snmpwalk

EXAMPLES
./recon.sh
./recon.sh 192.168.1.5 -- sets target IP
./recon.sh 192.168.1.5/supersecretfolder -- sets target IP (including sub-directory)
./recon.sh 192.168.1.5:443 -- sets target IP and port
./recon.sh 192.168.1.5 nmap -- sets target IP and kicks off nmap
./recon.sh 192.168.1.5:443 nmap -- sets IP, port, and kicks of command
```
## Main Menu
This is the primary area of the program and the point from which all of the enumeration commands are launched.
```
Current target: Not set

DEFAULT COMMANDS
(1) Change target
(2) nmap
(3) Directory enumeration (HTTP)
(4) Directory enumeration (HTTPS)
(5) SMB enumeration
(6) Nikto scan
(7) SMTP user scan
(8) SNMP enumeration
(9) Add a custom command
(10) Delete a custom command
(11) Help
(12) Out of ideas...
(13) Exit

CUSTOM COMMANDS
None

Select a # to run: 13   
```
## Menu Options
### Change Target
This allows the user to change the IP address currently being targeted.

### nmap
This module runs the following scans in order.  The order is designed to allow the quicker scans to finish first in order to provide rapid insight into open ports on the target machine:
1. Quick TCP CONNECT scan
2. Quick UDP scan
3. Full TCP CONNECT scan
4. Full nmap vulnerabilities scan

### Directory Enumeration - HTTP
This module runs the following scans in order, again prioritizing those which complete the fastest.
1. dirsearch.py
2. Gobuster
3. Dirb

### Directory Enumeration - HTTPS
Identical to the HTTP scans, but for HTTPS (port 443 should be included when entering the target IP address).

### SMB
1. enum4linux
2. nbtscan
3. nmap smb-os-discovery
4. nmap smb-protocols
5. nmap smb vuln* scripts
6. nmap smb enum scripts
7. smbmap
8. smbclient share listing
9. smbclient anonymous login

### Nikto
Runs Nikto against ports 80 and 443.

### SMTP
This module attempts to verify whether specified user accounts exist on the target via scanning port 25 SMTP services.  The user names to be queried must be listed in an existing .txt file, which can be specified upon running the module.

### SNMP
1. Onesixtyone
2. snmp-check
3. snmapwalk query for users
4. snmpwalk query for running processes
5. snmpwalk query for installed software
6. full snmpwalk

### Add
This module allows the user to insert a custom-defined command into the menu.  As long as the alacarte.txt file is not moved/deleted between sessions, the custom commands will persistent across sessions.

### Delete
Allows the user to delete a specified custom command.

### Help
Prints the help message.

### Out of ideas...
Wonder what this does?

### Exit
Think this one's pretty obvious.


