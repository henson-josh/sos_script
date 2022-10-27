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
   echo "asos [-c|d|df|h|hosts|i|ip|m|ne|nw|os|ps|s|te|tw|V]"
   echo "options:"
   echo
   echo "c               Remove SOS report directories"
   echo "d               Enable debug"
   echo "df              Print file system disk usage"
   echo "h               Print this Help"
   echo "hosts           Print all hostnames from respective SOS Reports"
   echo "i               Print installed RPMs, will prompt user for input"
   echo "ip              Print all IP addresses from respective SOS Reports"
   echo "m               Print memory system free/used"
   echo "mnt             Print findmnt output"
   echo "os              Print /etc/os-release"
   echo "ps              Print all running ansible processes"
   echo "s               Print all denied messages from audit.log"
   echo "V               Print software version"  
   echo "----------"
   echo "awx-manage:"
   echo "li              Print awx-manage list_instances output"
   echo "cl              Print awx-manage check_license output"
   echo "----------"
   echo "nginx logs:"
   echo "ne              Print all nginx error.log errors"
   echo "nw              Print all nginx error.log warnings"
   echo "----------"
   echo "tower logs:"   
   echo "te              Print all tower.log errors"
   echo "tw              Print all tower.log warnings"
   echo
}
untar_sos_files(){
    for file in "${tar_files[@]}"
    do 
    if [ ! -d $file ]
    then
	tar xf $file.tar.xz --no-same-permissions
	find $file -type d -exec chmod 0755 {} \;
	# Removing /var/log/tower/ files older than 5 days
	find $file/var/log/tower -mtime +5 -delete 2>/dev/null
    fi
    done
}
############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while [ -n "$1" ]
do 
    for file in "${tar_files[@]}"
    do
	untar_sos_files
    done

    for file in "${tar_files[@]}"
    do    
	case "$1" in
	    -c) # Remove SOS Report directories
		# need conditional if sos directory does not exists
                for file in "${tar_files[@]}"
                do
		    printf '%s\n'" ${BOLD}Removing directory: $file${NC}"'%s\n'
		    rm --interactive=once -rf ${file}
		done
		exit;;
            -cl) # Display output from ./sos_commands/tower/awx-manage_check_license_--data
                for file in "${tar_files[@]}"
                do
    		    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} license information:\n"
                    cat $file/sos_commands/tower/awx-manage_check_license_--data 2>/dev/null
		done
                exit;;		
	    -d) # Enable debugging
		enable_debug
		echo $debug
		exit;;
	    -df)
		#fails if sos directory does not exist
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
                for file in "${tar_files[@]}"
                do
		    echo "Which packages are you looking for?  (i.e. ansible, python, etc)"
		    read rpmname
		    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} installed $rpmname packages:\n"
		    grep $rpmname $file/installed-rpms
	        done
		exit;;
            -ip) # Print IP adress of host
                for file in "${tar_files[@]}"
                do
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} IP Address: \n"
                    cat $file/ip_addr
                done
                exit;;
            -li) # Display output from ./sos_commands/tower/awx-manage_list_instances
                for file in "${tar_files[@]}"
                do
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} instances:\n"
                    cat $file/sos_commands/tower/awx-manage_list_instances 2>/dev/null
	        done
                exit;;
            -m) # Print current memory usage
                for file in "${tar_files[@]}"
                do
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} memory free/used:\n"
		    cat $file/sos_commands/memory/free_-m
	        done
		exit;;
            -mnt) # Print findmnt output
                  for file in "${tar_files[@]}"
                  do
                      printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} findmnt:\n"
                      cat $file/sos_commands/filesys/findmnt
                  done		
                  exit;;		
  
	    -ne) # Display nginx error.log error messages.
                for file in "${tar_files[@]}"
                do
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} nginx error.log:\n"
		    grep 'error' $file/var/log/nginx/error.log* 2>/dev/null
	        done
		exit;;	    
	    -nw) # Display nginx error.log warning messages.
                for file in "${tar_files[@]}"
                do
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} nginx error.log:\n"
		    grep 'warn' $file/var/log/nginx/error.log* 2>/dev/null
		done
		exit;;
	    -os) # Display Operating System.
                for file in "${tar_files[@]}"
                do
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} Operating System:\n"
		    cat $file/etc/os-release
	        done
		exit;;	    
	    -ps) # Display running ansible processes.
                for file in "${tar_files[@]}"
                do
                    echo "Which processes are you looking for?  (i.e. ansible, python, postgresql, etc)"
                    read rpmname
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} $rpmname processes:\n"
                    grep $rpmname $file/ps
                done
                exit;;		    
	    -s) # Display denied messages from audit.log
                for file in "${tar_files[@]}"
                do
	            printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} audit.log Denied messages:\n"
	            grep -v 'permissive=1' $file/var/log/audit/audit.log 2>/dev/null | grep 'denied'
		done
		exit;;	    
	    -te) # Display Error messages from tower.log (filtered scaling up/down messages)
                for file in "${tar_files[@]}"
                do		    
		    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} tower.log Error messages:\n"
		    grep -v 'pid' $file/var/log/tower/tower.log* | grep 'ERROR' 2>/dev/null
		done
		exit;;
	    -tw) # Display Warning messages from tower.log (filtered scaling up/down messages)
                for file in "${tar_files[@]}"
                do
		    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} tower.log Warning messages:\n"
		    grep -v 'pid' $file/var/log/tower/tower.log* | grep -v 'periodic beat' | grep 'WARN' 2>/dev/null
		done
		exit;;
	    -V) # Display Version
		echo "SOS_Script 1.2.6  |  27 Oct 2022"
		exit;;
            -cl) # Display output from ./sos_commands/tower/awx-manage_check_license_--data
                for file in "${tar_files[@]}"
                do
                    printf "\nHost ${BOLD_CYAN}'$(cat $file/hostname)'${NC} license information:\n"
		    cat $file/sos_commands/tower/awx-manage_check_license_--data 2>/dev/null
		done
                exit;;
	    --test)
		# need to add simple test of args
		echo "sorry this is under construction"
		exit;;
	esac
	shift
    done
done

############################################################
# System Overview                                          #
############################################################

printf "\n${BOLD_GREEN}${BLINK}Use -h flag to see additional options.${NC}\n"

for file in "${tar_files[@]}"
    do
        untar_sos_files
done

for file in "${tar_files[@]}"
    do
# Variables for high level overview of the system
ansible=$(grep -i '^ansible\|automation' $file/installed-rpms 2> /dev/null | awk '{printf "   - "$1"\n"}')
auditlogDenied=$(grep -v 'permissive=1' $file/var/log/audit/audit.log 2>/dev/null | grep -c 'denied')
hostname=$(cat $file/hostname)
nginxErrorErr=$(grep -o 'error' $file/var/log/nginx/error.log* 2>/dev/null | wc -l)
nginxErrorWarn=$(grep -v 'upstream response is buffered' $file/var/log/nginx/error.log* 2>/dev/null | grep -o 'warn' | wc -l)
ps=$(grep -c 'ansible\|pulp' $file/ps 2>/dev/null)
python=$(grep -i '^/usr/bin/python' $file/sos_commands/alternatives/alternatives_--display_python 2>/dev/null | awk -F/ '{printf "   - "$4"\n"}')
towerlogError=$(grep -v 'pid' $file/var/log/tower/tower.log* 2>/dev/null | grep -o 'ERROR' | wc -l)
towerlogWarn=$(grep -v 'pid' $file/var/log/tower/tower.log* 2>/dev/null | grep -v 'periodic beat' | grep -o 'WARN' | wc -l)


# Printing high level overview of the system
printf "\nOverview of host:${BOLD_CYAN} '$hostname'${NC}\n"
printf " - ${BOLD_BLUE}$ps${NC} ${UL}ansible${NC} processes running
 - ${BOLD_BLUE}$nginxErrorErr${NC} ${BOLD}errors${NC} in the ${UL}nginx error.log${NC}
 - ${BOLD_BLUE}$nginxErrorWarn${NC} ${BOLD}warnings${NC} in the ${UL}nginx error.log${NC}
 - ${BOLD_BLUE}$towerlogWarn${NC} ${BOLD}warnings${NC} in the current ${UL}tower.log${NC} (filtered scaling up/down warnings)
 - ${BOLD_BLUE}$towerlogError${NC} ${BOLD}errors${NC} in the current ${UL}tower.log${NC} 
 - ${BOLD_BLUE}$auditlogDenied${NC} ${BOLD}denials${NC} logged in ${UL}audit.log${NC} (permissive=1 excluded)
 - has ${BOLD_GREEN}Ansible${NC} versions: \n$ansible
 - has ${BOLD_GREEN}Python${NC} versions: \n$python
"
done 

