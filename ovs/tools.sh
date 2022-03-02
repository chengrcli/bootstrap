# print ovs threads
cat /proc/`pidof ovs-vswitchd`/task/*/comm

# run an application in debug mode
./helloworld -l 3-8,1 -n 4 --log-level lib.eal:debug

