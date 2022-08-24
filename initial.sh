#!/bin/bash
## this is a test
tar_file_array(){
    if [ -n "$(ls $PWD/*.tar.xz)" ]
    then
	sos_directories=($(echo $PWD*.tar.xz | awk -F. '{print $1}'))
	tar_files=($(echo $PWD*.tar.xz ))
    else
	printf '%s\n\n'"No tar file(s) found in: $(pwd) "'%s\n\n'
	exit 1
    fi
}

untar_files(){
    tar_file_array
    for file in "${tar_files[@]}"
    do 
      sos_directory=$(echo $file | awk -F. '{print $1}')
      if [ ! -d ${sos_directory} ]
      then
        if [ ${debug} ]
        then
          echo "all files ${tar_file[@]}"
          echo "current file $file" 
        fi
        echo tar xf ${file} --directory ${PWD}
      fi
      #run_commands $file
    done
}

clean_directories(){
  tar_file_array
  for file in "${sos_directories[@]}"
  do 
    if [ -d ${file} ]
    then
	echo $file
	if [ ${debug} ]
	then
	    printf '%s\n'" Removing directory: $file"'%s\n' 
	fi
	echo sudo rm --interactive=once -rf ${file}
    fi
  done
  exit 0
}

hosts(){
    cat ${file}/hostname
}

run_commands(){
  for host in "${sos_directories}"
  do
    echo ${host}
    file=${host}
    cat ${file}/hostname
    grep ansible ${file}/ps
    grep ansible ${file}/installed-rpms
  done
}

enable_debug(){
    debug=true
}
sosreport_location(){
    PWD=$1
}

dual_arguments(){
        case $1 in
          p )
              sosreport_location $2
              ;;
          * )
              echo "how did you get here"
              echo " dual_argument error"
              exit 3
        esac
}

need_matching_argument=false
for argument in "$@"
do
    if $need_matching_argument
    then
        need_matching_argument=false
        dual_arguments "$flag_pair" "$argument"
        continue
    fi
    if [[ ${argument} == "-"* ]]; then
	flags="${argument:1}"
	for char in ${flags}
	do
	    case ${char} in
		c )
		    enable_debug
		    clean_directories
		    ;;
		d )
		    enable_debug
		    echo $debug
		    ;;
		p )
		    flag_pair=${char}
		    need_matching_argument=true
		    break
		    ;;
		*)
		    echo -n "Unknown command: $1"
		    printf '%s\n'" Unknown Command: "'%s\n'
		    exit 2
		    ;;
	    esac
	done
    else
        case ${argument} in
            clean )
                clean_directories
                ;;
            hosts )
                echo ${argument}
                ;;
            * )
                echo argument error
                echo -n "Unknown command: $1"
                printf '%s\n'" Unknown Command: "'%s\n'
                exit 2
                ;;
        esac
    fi
done

untar_files
#run_commands
