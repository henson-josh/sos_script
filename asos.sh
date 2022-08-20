#!/bin/bash

# Ansible SOS Report Analyzer Script

############################################################
# Arrays/Variables/Options                                 #
############################################################

# If color doesn't work replace 033 with \e
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN_ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD_GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
BOLD_RED='\e[1;31m'
BOLD_GREEN='\e[1;32m'
YELLOW='\033[1;33m'
BOLD_BLUE='\e[1;34m'
BOLD_PURPLE='\033[1;35m'
BOLD_CYAN='\e[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color/Formatting
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UL='\033[4m'
BLINK='\033[5m'
REV='\033[7m'
INVIS='\033[8m'


tar_files=($(ls *.tar.xz | awk -F. '{print $1}'))

tar_file_array()
{
    if [ -e "*.tar.xz" ]
    then
        tar_files=($(/usr/bin/ls *.tar.xz | awk -F. '{print $1}'))
    else
        printf '%s\n\n'"${BLINK}${BOLD_RED}[31mNo tar file(s) found in: $(pwd)${NC} "'%s\n\n'
        exit 1
    fi
}

enable_debug()
{
    debug=true
}

Help()
{
   # Display Help
   echo
   echo "Run command without any arguments initially to extract SOS Report(s)"
   echo "Syntax: asos.sh [-c|d|h|n|ps|te|tw|V]"
   echo "options:"
   echo "c     Remove SOS report directories"
   echo "d     Enable debug"
   echo "df    Print file system disk usage"
   echo "h     Print this Help"
   echo "i     Print installed RPMs, will prompt user for input"
   echo "m     Print memory system free/used"
   echo "n     Print all nginx error.log warnings"
   echo "ps    Print all running ansible processes"
   echo "s     Print all denied messages from audit.log"
   echo "te    Print all tower.log errors"
   echo "tw    Print all tower.log warnings"
   echo "V     Print software version and exit"
   echo
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while [ -n "$1" ]; do # while loop starts

        case "$1" in
        -c)
            for file in "${tar_files[@]}"
            do
              printf '%s\n'" ${BOLD}Removing directory: $file${NC}"'%s\n'
              sudo rm --interactive=once -rf ${file}
            done
            exit;;
        -d)
            enable_debug
            echo $debug
            exit;;
        -df)
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} file system disk usage:\n"
                cat $file/df
            done
    	    exit;;
        -h) # Display help
            Help
            exit;;
        -hosts) # Display all hostnames from SOS Reports
            for file in "${tar_files[@]}"
            do
                printf "${BOLD_CYAN}'$(cat $file/hostname)'${NC}\n"
            done
            exit;;
               
        -i) # Print Intalled RPMs, grep for variable
            echo "Which packages are you looking for?  (i.e. ansible, python, etc)"
            read rpmname
            for file in "${tar_files[@]}"
            do
		printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} installed $rpmname packages:\n"
                grep $rpmname $file/installed-rpms
            done
            exit;;		
        -m) # Print current memory usage
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} memory free/used:\n"
                cat $file/free
            done
            exit;;
        -n) # Display nginx error.log warning messages.
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} nginx error.log:\n"
                grep 'warn' $file/var/log/nginx/error.log
            done
            exit;;
        -ps) # Display running ansible processes.
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} ansible processes running:\n"
                grep ansible $file/ps
            done
            exit;;
        -s)
            # Display denied messages from audit.log
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} audit.log Denied messages:\n"
                grep 'denied' $file/var/log/audit/audit.log
            done
            exit;;	    
        -te)
	    # Display Error messages from tower.log (filtered scaling up/down messages)
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} tower.log Error messages:\n"
                grep -v 'pid' $file/var/log/tower/tower.log | grep 'ERROR'
            done
            exit;;
        -tw) # Display Warning messages from tower.log (filtered scaling up/down messages)
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} tower.log Warning messages:\n"
                grep -v 'pid' $file/var/log/tower/tower.log | grep -v 'periodic beat' | grep 'WARN'
            done
            exit;;
        -V) # Display Version
            echo "SOS_Script 1.1.2  |  19 Aug 2022"
            exit;;
        esac

        shift

done

############################################################
# System Overview                                          #
############################################################

for file in "${tar_files[@]}"
do 
  if [ ! -d $file ]
  then
    tar xf $file.tar.xz
    # Removing /var/log/tower/ files older than 5 days
    find $file/var/log/tower -mtime +5 -delete
  fi
done

printf "\n${BOLD_GREEN}${BLINK}Use -h flag to see additional options.${NC}\n"

for file in "${tar_files[@]}"
    do

# Variables for high level overview of the system
ansible=$(grep -i '^ansible' $file/installed-rpms | awk '{printf "   - "$1"\n"}')
auditlogDenied=$(grep -c 'denied' $file/var/log/audit/audit.log)
hostname=$(cat $file/hostname)
nginxErrorWarn=$(grep -c 'warn' $file/var/log/nginx/error.log)
ps=$(grep -c ansible $file/ps)
python=$(grep -i '^/usr/bin/python' $file/sos_commands/alternatives/alternatives_--display_python | awk -F/ '{printf "   - "$4"\n"}' 2> /dev/null )
towerlogError=$(grep -v 'pid' $file/var/log/tower/tower.log 2>/dev/null | grep -c 'ERROR')
towerlogWarn=$(grep -v 'pid' $file/var/log/tower/tower.log 2>/dev/null | grep -v 'periodic beat' | grep -c 'WARN')


# Printing high level overview of the system
printf "\nOverview of host:${BOLD_CYAN} '$hostname'${NC}\n"
printf " - ${BOLD_BLUE}$ps${NC} ${UL}ansible${NC} processes running
 - ${BOLD_BLUE}$nginxErrorWarn${NC} warnings in the ${UL}nginx error.log${NC}
 - ${BOLD_BLUE}$towerlogWarn${NC} warnings in the current ${UL}tower.log${NC} (filtered scaling up/down warnings)
 - ${BOLD_BLUE}$towerlogError${NC} errors in the current ${UL}tower.log${NC} 
 - ${BOLD_BLUE}$auditlogDenied${NC} denials logged in ${UL}audit.log${NC}
 - has ${BOLD_GREEN}Ansible${NC} versions: \n$ansible
 - has ${BOLD_GREEN}Python${NC} versions: \n$python
"
done 

