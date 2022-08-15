#!/bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo
   echo "Syntax: whatever_the_final_name_will_be [-a|h|v|V]"
   echo "options:"
   echo "a     Print all information."
   echo "h     Print this Help."
   echo "n     Print all nginx error.log warnings."
   echo "t     Print all tower.log warnings."
   echo "V     Print software version and exit."
   echo
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

############################################################
# Main program                                             #
############################################################

# Verifying SOS Report tar file is present
printf '%s\n'"Verifying SOS tarball is present in current directory."'%s\n'
if [ ! -e *.tar.xz ]
   then
	printf '%s\n'"\x1b[31mNo SOS Report found.\\x1b[0m"'%s\n'
	exit 2
fi

# Extracting all SOS tar files
tar_files=($(ls *.tar.xz | awk -F. '{print $1}'))
if [ $Clean ]
then
  for file in "${tar_files[@]}"
  do 
      sudo rm -rf $file
  done
  exit 0
fi

for file in "${tar_files[@]}"
do 
  if [ ! -d $file ]
  then
    tar xf $file.tar.xz
  fi

# Removing /var/log/tower/ files older than 5 days
printf '%s\n'"Removing /var/log/tower/ files older than 5 days."'%s\n'
find $file/var/log/tower -mtime +5 -delete

# Variables
hostname=$(cat $file/hostname)
ps=$(grep -c ansible $file/ps)
nginxErrorWarn=$(grep -c 'warn' $file/var/log/nginx/error.log)
towerlogWarn=$(grep -v 'scaling' $file/var/log/tower/tower.log | grep -c 'WARN')

# Printing high level overview of the system
printf "\nHost ""\x1b[31m\'$hostname'\\x1b[0m has...\n"
printf " - ""\x1b[1;32m$ps\\x1b[0m ansible processes running
 - ""\x1b[1;32m$nginxErrorWarn\\x1b[0m warnings in the nginx error.log
 - ""\x1b[1;32m$towerlogWarn\\x1b[0m warnings in the current tower.log file (minus scaling worker warnings)
 - has \x1b[31mAnsible\\x1b[0m versions \n$(grep -i '^ansible' $file/installed-rpms | awk '{printf "   - "$1"\n"}')
 - has \x1b[1;32mPython\\x1b[0m versions \n$(grep -i '^/usr/bin/python' $file/sos_commands/alternatives/alternatives_--display_python | awk -F/ '{printf "   - "$4"\n"}')
"
done 
