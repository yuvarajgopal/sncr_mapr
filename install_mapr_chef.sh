#!/bin/bash

#Node list:
nodes="ip-172-16-2-225.ec2.internal ip-172-16-2-16.ec2.internal ip-172-16-2-176.ec2.internal ip-172-16-2-108.ec2.internal ip-172-16-2-37.ec2.internal ip-172-16-2-79.ec2.internal"
log_date=`date +%F_%H-%M`

if [ ! -d ~/mapr_install_logs ]; then
	echo "Making mapr_install directory"
	mkdir -p ~/mapr_install_logs/bak
else
  if [[ "`ls ~/mapr_install_logs/*.install.log 2>/dev/null`" != "" ]]; then
	echo "Moving old installation logs"
	mv ~/mapr_install_logs/*.install.log ~/mapr_install_logs/bak
  fi
fi

for i in $nodes; do
	echo "Starting chef-client run for node $i"
	nohup ssh $i chef-client >>~/mapr_install_logs/$i.$log_date.install.log 2> ~/mapr_install_logs/error.$i.$log_date.install.log < /dev/null &
done

sleep 10 

for i in $nodes; do
	while [[ "`ssh $i ps -ef|grep chef-client|grep -v grep|grep -v ssh`" != "" ]]; do
	  sleep 20;
          echo "Waiting for $i to finish chef-client"
	done
done

applied="no"
while [[ "$applied" != "y" ]]; do 
  echo -n "Have you applied a MapR license ('y' if so, 'q' to quit script):  "
  read applied
  case $applied in
    q*)
      echo -e "\n\nQuitting script...\n\n"
      exit
  esac
done

echo -e "\n\n###IMPORTANT!!  THIS NEXT STEP WILL REBOOT THE SERVERS###"
echo -e "###IMPORTANT!!  THIS NEXT STEP WILL REBOOT THE SERVERS###\n\n"

rb="no"
while [[ "$rb" != "y" ]]; do 
  echo -n "Reboot all servers?('y' if so, 'q' to quit script):  "
  read rb
  case $rb in 
    q*)
      echo "Quitting script..."\n\n
      exit
  esac
done 

echo -e "\n\nRebooting all servers!!!\n\n"
echo -e "Waiting for all servers to come back\n\n"

for i in $nodes; do
  if [[ "`ssh $i ls /opt/mapr/roles|grep cldb`" != "cldb" ]]; then 
    ssh $i service mapr-warden stop
  fi
done

for i in $nodes; do 
  if [[ "`ssh $i ls /opt/mapr/roles|grep cldb`" == "cldb" ]]; then 
    ssh $i service mapr-warden stop
  fi
done

for i in $nodes; do
  if [[ "`ssh $i ls /opt/mapr/roles|grep zookeeper`" == "zookeeper" ]]; then
    ssh $i service mapr-zookeeper stop
  fi
done

for i in $nodes; do
  ssh $i reboot
done

for i in $nodes; do
  while [[ "`ssh $i uname -m 2>/dev/null`" != "x86_64" ]]; do
    sleep 20
    echo "Sleeping 20 seconds for host $i"  
  done 
done


node_count=`echo $nodes|wc -w`
echo "node_count == $node_count"
warden_up="0"
echo "Nodes = $nodes"
for i in $nodes; do 
  while [[ "`ssh $i service mapr-warden status`" != "WARDEN running as process "[0-9]*\. ]]; do 
    sleep 5
    echo "sleeping for $i warden"
 done
    echo "Warden on $i is  up"
    warden_up+=1
done


test=`echo $nodes|awk '{print $1}'`
#echo -e "\n\ntest == $test\n\n"

echo -e "\n\nLooking for active CLDB\n\n"
while [[ "`ssh $test maprcli node cldbmaster|awk '{print $1}'`" != "cldbmaster
ServerID:" ]]; do
  sleep 5
  echo -e "Waiting for active CLDB..."
done

echo -e "\n\nFound active CLDB!\n\n"

echo -e "Restarting all Wardens\n\n"
for i in $nodes; do
  ssh $i service mapr-warden restart
done

test=`echo $nodes|awk '{print $1}'`
#echo -e "\n\ntest == $test\n\n"

echo -e "\n\nLooking for active CLDB\n\n"
while [[ "`ssh $test maprcli node cldbmaster|awk '{print $1}'`" != "cldbmaster
ServerID:" ]]; do
  sleep 5
  echo -e "Waiting for active CLDB..."
done

echo -e "\n\nFound active CLDB!\n\n"

echo -e "\n\n\nAll Done Here!!!!!\n\n\n"
