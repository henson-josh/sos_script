import os, sys
import subprocess 

#current_pwd = os.system("pwd")
current_pwd = str(subprocess.check_output("pwd", shell=True))[2:-3]

if len(sys.argv) > 1:
    # if variable change current_pwd to desired_pwd 
    desired_pwd = sys.argv[1]

tar_directories = []
tar_files = []
for element in os.listdir():
    if "sosreport" in element:
        if "tar.xz" in element:
            tar_files.append(element)
        else:
            tar_directories.append(element)


sos_directory = current_pwd + '/' + tar_directories[0]  
hostname_path = sos_directory + '/sos_commands/host/hostname' 
f = open(hostname_path, 'r')
hostname = f.read()
print(hostname)


