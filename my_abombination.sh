#!/bin/bash

# Verifying SOS Report tar file is present
printf '%s\n'"Verifying SOS tarball is present in current directory."'%s\n'
if [ ! -e *.tar.xz ]
   then
        printf '%s\n'"No SOS Report found."'%s\n'
        exit 2
fi

# this needs to be an array
tar_file=$(ls *.tar.xz | awk -F. '{print $1}')
if [ ! -d $tar_file ]
   then
      tar xf $tar_file.tar.xz
fi

# Removing /var/log/tower/ files older than 5 days
printf '%s\n'"Removing /var/log/tower/ files older than 5 days."'%s\n'
find $tar_file/var/log/tower -mtime +5 -delete

# Variables
hostname=$(cat $tar_file/hostname)
ps=$(grep -c ansible $tar_file/ps)
nginxErrorWarn=$(grep -c 'warn' ./sos*/var/log/nginx/error.log)
towerlogWarn=$(grep -v 'scaling' $tar_file/var/log/tower/tower.log | grep -c 'WARN')

# Printing high level overview of the system
printf "\nHost ""\x1b[31m\'$hostname'\\x1b[0m has...\n"
printf " - ""\x1b[1;32m$ps\\x1b[0m ansible processes running
 - ""\x1b[1;32m$nginxErrorWarn\\x1b[0m warnings in the nginx error.log
 - ""\x1b[1;32m$towerlogWarn\\x1b[0m warnings in the current tower.log file (minus scaling worker warnings)
 - has \x1b[31mAnsible\\x1b[0m versions \n$(grep -i '^ansible' $tar_file/installed-rpms | awk '{printf "   - "$1"\n"}')
 - has \x1b[1;32mPython\\x1b[0m versions \n$(grep -i '^/usr/bin/python' $tar_file/sos_commands/alternatives/alternatives_--display_python | awk -F/ '{printf "   - "$4"\n"}')
