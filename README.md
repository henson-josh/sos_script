# Ansible SOS Report Analyzer
Working towards a script that will parse SOS logs

### Current Features
```
asos [-c|d|df|h|hosts|i|m|ne|nw|os|ps|s|te|tw|V]
options:

c               Remove SOS report directories
d               Enable debug
df              Print file system disk usage
h               Print this Help
hosts           Print all hostnames from respective SOS Reports
i               Print installed RPMs, will prompt user for input
m               Print memory system free/used
os              Print /etc/os-release
ps              Print all running ansible processes
s               Print all denied messages from audit.log
V               Print software version
----------
awx-manage:
li              Print awx-manage list_instances output
ch              Print awx-manage check_license output
----------
nginx logs:
ne              Print all nginx error.log errors
nw              Print all nginx error.log warnings
----------
tower logs:
te              Print all tower.log errors
tw              Print all tower.log warnings
```
### Example Output
![Alt text](https://github.com/henson-josh/sos_script/blob/main/misc/asos-output.png)
