import os
import sys
import json
import subprocess


def fun(args, data, i=0):
    if len(args) > 1:
        for key in data.keys():
            if key == args[i]:
                i = i + 1
                if isinstance(data[key], dict):
                    return fun(args, data[key], i)
                else:
                    return data[key]
    else:
        return data[args[0]]


def run(parent_key, json):
    for key, value in json.items():
        if isinstance(value, dict):
            run(key, value)
            next
        else:
            # json[key] = subprocess.check_output(value)
            json[key] = subprocess.run(value, capture_output=True, shell=True).stdout.decode('utf-8')
    return {parent_key: json}


# current_pwd = os.system("pwd")
current_pwd = str(subprocess.check_output("pwd", shell=True))[2:-3]

tar_directories = []
tar_files = []
for element in os.listdir():
    if "sosreport" in element:
        if "tar.xz" in element:
            tar_files.append(element)
        else:
            tar_directories.append(element)

config_file = open('/home/mhimes/workplace/sos_script/asos.config')
args_by_commands = json.load(config_file)
print(tar_directories)
for directory in tar_directories:
    for name, command in args_by_commands.items():
        # os.chdir('sosreport-cpvra79a1172-03308392-2022-09-13-sirrngj')
        if isinstance(command, dict):
            args_by_commands.update(run(name, command))
            next
        else:
            args_by_commands[name] = subprocess.run(command, capture_output=True, shell=True).stdout.decode('utf-8')


if len(sys.argv) > 1:
    # if variable change current_pwd to desired_pwd
    desired_pwd = sys.argv[1]
    print(fun(sys.argv[1:], args_by_commands))
