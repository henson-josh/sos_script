#!/bin/bash
tar_file_array(){
    if [ -e "*.tar.xz" ]
    then
	tar_files=($(/usr/bin/ls *.tar.xz | awk -F. '{print $1}'))
    else
	printf '%s\n\n'"No tar file(s) found in: $(pwd) "'%s\n\n'
	exit 1
    fi
}

untar_files(){
    tar_file_array
    for file in "${tar_files[@]}"
    do 
      if [ ! -d ${file} ]
      then
        if [ ${debug} ]
        then
          echo "all files ${tar_file[@]}"
          echo "current file $file" 
        fi
        tar xf ${file}.tar.xz 
      fi
      run_commands $file
    done
}

clean_directories(){
  tar_file_array
  for file in "${tar_files[@]}"
  do 
    if [ ${debug} ]
    then
        printf '%s\n'" Removing directory: $file"'%s\n' 
    fi
    sudo rm --interactive=once -rf ${file}
  done
  exit 0
}

run_commands(){
  file=$1
  cat ${file}/hostname
  grep ansible ${file}/ps
  grep ansible ${file}/installed-rpms

}

enable_debug(){
    debug=true
}

if [ "${1}" != "" ]
then
    case $1 in
	-c | Clean | clean)
	    enable_debug
	    clean_directories
	    ;;
	-d )
	    enable_debug
	    echo $debug
	    ;;
	*)
	    echo -n "Unknown command: $1"
	    printf '%s\n'" Unknown Command: "'%s\n'
	    exit 2
	    ;;
    esac
fi

untar_files
