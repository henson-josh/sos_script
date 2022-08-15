#!/bin/bash


printf '%s\n'"Verifying SOS tarball is present in current directory."'%s\n'
if [ ! -e *.tar.xz ]

   then 
       printf '%s\n\n'"No .tar.xz file found!"'%s\n\n' 
       exit 2
fi

# this needs to be an array
tar_file=$(ls *.tar.xz | awk -F. '{print $1}')
if [ ! -d $tar_file ]
   then
   tar xf $tar_file.tar.xz
fi
cat $tar_file/hostname
grep ansible $tar_file/ps
grep ansible $tar_file/installed-rpms
#time configurable var
# time_range="+5"
find $tar_file/var/log/tower -mtime +5 -delete
grep ansible $
grep -iR "WARN\|ERR\|FATAL" $tar_file/var/log/tower | awk -F'/' '{print $5, $NF}'
