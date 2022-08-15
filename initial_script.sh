#!/bin/bash

############################################################
# Arrays/Variables/Options                                 #
############################################################

tar_files=($(ls *.tar.xz | awk -F. '{print $1}'))

tar_file_array(){
    if [ -e "*.tar.xz" ]
    then
        tar_files=($(/usr/bin/ls *.tar.xz | awk -F. '{print $1}'))
    else
        printf '%s\n\n'"\x1b[31mNo tar file(s) found in: $(pwd)\\x1b[0m "'%s\n\n'
        exit 1
    fi
}

enable_debug(){
    debug=true
}

Help()
{
   # Display Help
   echo
   echo "Syntax: whatever_the_final_name_will_be [-a|c|h|n|ps|V]"
   echo "options:"
   echo "a     Print all information."
   echo "c     Remove SOS report directories"
   echo "d     Enable debug."
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
        -h) # Display help
            Help
            exit;;
        -n) # Display nginx error.log warning messages.
            for file in "${tar_files[@]}"
            do
                printf "\nHost ""\x1b[31m\'$(cat $file/hostname)'\\x1b[0m nginx error.log:\n"
                grep 'warn' $file/var/log/nginx/error.log
            done
            exit;;
        -ps) # Display running ansible processes.
            for file in "${tar_files[@]}"
            do
                printf "\nHost ""\x1b[31m\'$(cat $file/hostname)'\\x1b[0m ansible processes running:\n"
                grep ansible $file/ps
            done
            exit;;
        -t) # Display Warning messages from tower.log (filtered scaling up/down messages)
            for file in "${tar_files[@]}"
            do
                printf "\nHost ""\x1b[31m\'$(cat $file/hostname)'\\x1b[0m tower.log warning messages:\n"
                grep -v 'pid' $file/var/log/tower/tower.log | grep 'WARN'
            done
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
  fi
done

for file in "${tar_files[@]}"
    do

# Removing /var/log/tower/ files older than 5 days
find $file/var/log/tower -mtime +5 -delete

# Variables for high level overview of the system
hostname=$(cat $file/hostname)
ps=$(grep -c ansible $file/ps)
nginxErrorWarn=$(grep -c 'warn' $file/var/log/nginx/error.log)
towerlogWarn=$(grep -v 'pid' $file/var/log/tower/tower.log | grep -c 'WARN')

# Printing high level overview of the system
printf "\nHost ""\x1b[31m\'$hostname'\\x1b[0m has...\n"
printf " - ""\x1b[1;32m$ps\\x1b[0m ansible processes running
 - ""\x1b[1;32m$nginxErrorWarn\\x1b[0m warnings in the nginx error.log
 - ""\x1b[1;32m$towerlogWarn\\x1b[0m warnings in the current tower.log file (filtered scaling up/down warnings)
 - has \x1b[31mAnsible\\x1b[0m versions \n$(grep -i '^ansible' $file/installed-rpms | awk '{printf "   - "$1"\n"}')
 - has \x1b[1;32mPython\\x1b[0m versions \n$(grep -i '^/usr/bin/python' $file/sos_commands/alternatives/alternatives_--display_python | awk -F/ '{printf "   - "$4"\n"}')
"
done 

