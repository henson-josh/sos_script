#!/bin/bash

############################################################
# Arrays/Variables/Options                                 #
############################################################

# If color doesn't work replace 033 with \e
# Only difference I see is LIGHT makes text bold.
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN_ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='033[0;37m'
DARK_GRAY='033[1;30m'
LIGHT_RED='\e[1;31m'
LIGHT_GREEN='\e[1;32m'
YELLOW='033[1;33m'
LIGHT_BLUE='\e[1;34m'
LIGHT_PURPLE='033[1;35m'
LIGHT_CYAN='\e[1;36m'
WHITE='033[1;37m'
NC='\033[0m' # No Color

tar_files=($(ls *.tar.xz | awk -F. '{print $1}'))

tar_file_array()
{
    if [ -e "*.tar.xz" ]
    then
        tar_files=($(/usr/bin/ls *.tar.xz | awk -F. '{print $1}'))
    else
        printf '%s\n\n'"${LIGHT_RED}[31mNo tar file(s) found in: $(pwd)${NC} "'%s\n\n'
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
   echo "Syntax: whatever_the_final_name_will_be [-c|d|h|n|ps|t|V]"
   echo "options:"
   echo "c     Remove SOS report directories"
   echo "d     Enable debug."
   echo "df    Print file system disk usage"
   echo "f     Print memory system free/used"
   echo "h     Print this Help."
   echo "n     Print all nginx error.log warnings."
   echo "ps    Print all running ansible processes."
   echo "t     Print all tower.log warnings."
   echo "V     Print software version and exit."
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
              printf '%s\n'" Removing directory: $file"'%s\n'
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
                printf "\nHost ${LIGHT_CYAN}'$(cat $file/hostname)'${NC} file system disk usage:\n"
                cat $file/df
            done
    	    exit;;
        -f)
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${LIGHT_CYAN}'$(cat $file/hostname)'${NC} memory free/used:\n"
                cat $file/free
            done
            exit;;	    
        -h) # Display help
            Help
            exit;;
        -n) # Display nginx error.log warning messages.
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${LIGHT_CYAN}'$(cat $file/hostname)'${NC} nginx error.log:\n"
                grep 'warn' $file/var/log/nginx/error.log
            done
            exit;;
        -ps) # Display running ansible processes.
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${LIGHT_CYAN}'$(cat $file/hostname)'${NC} ansible processes running:\n"
                grep ansible $file/ps
            done
            exit;;
        -t) # Display Warning messages from tower.log (filtered scaling up/down messages)
            for file in "${tar_files[@]}"
            do
                printf "\nHost ${LIGHT_CYAN}'$(cat $file/hostname)'${NC} tower.log warning messages:\n"
                grep -v 'pid' $file/var/log/tower/tower.log | grep 'WARN'
            done
            exit;;
        -V) # Display Version
            echo "SOS_Script 1.1.0  |  16 Aug 2022"
            exit;;
        esac

        shift

done

############################################################
# Main program                                             #
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

for file in "${tar_files[@]}"
    do

# Variables for high level overview of the system
hostname=$(cat $file/hostname)
ps=$(grep -c ansible $file/ps)
nginxErrorWarn=$(grep -c 'warn' $file/var/log/nginx/error.log)
towerlogWarn=$(grep -v 'pid' $file/var/log/tower/tower.log | grep -c 'WARN')
ansible=$(grep -i '^ansible' $file/installed-rpms | awk '{printf "   - "$1"\n"}')
python=$(grep -i '^/usr/bin/python' $file/sos_commands/alternatives/alternatives_--display_python | awk -F/ '{printf "   - "$4"\n"}')


# Printing high level overview of the system
#printf "\nOverview of host: ""\x1b[31m\'$hostname'\\x1b[0m has...\n"

printf "\nOverview of host:${LIGHT_CYAN} '$hostname'${NC}\n"
printf " - ${LIGHT_BLUE}$ps${NC} ansible processes running
 - ${LIGHT_BLUE}$nginxErrorWarn${NC} warnings in the nginx error.log
 - ${LIGHT_BLUE}$towerlogWarn${NC} warnings in the current tower.log file (filtered scaling up/down warnings)
 - has ${LIGHT_GREEN}Ansible${NC} versions \n$ansible
 - has ${LIGHT_GREEN}Python${NC} versions \n$python
"
done 

