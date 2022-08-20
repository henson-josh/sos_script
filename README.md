# Ansible SOS Report Analyzer
Working towards a script that will parse SOS logs

### Current Features
```
Run command without any arguments initially to extract SOS Report(s)
Syntax: asos.sh [-c|d|df|h|hosts|i|m|n|ps|s|te|tw|V]
options:
c        Remove SOS report directories
d        Enable debug
df       Print file system disk usage
h        Print this Help
hosts    Print all hostnames from respective SOS Reports
i        Print installed RPMs, will prompt user for input
m        Print memory system free/used
n        Print all nginx error.log warnings
ps       Print all running ansible processes
s        Print all denied messages from audit.log
te       Print all tower.log errors
tw       Print all tower.log warnings
V        Print software version and exit
```
### Example Output
![Alt text](https://github.com/henson-josh/sos_script/blob/main/misc/asos-output.png)
