#!/bin/bash

echo "$(date +"%Y_%m_%d_%I_%M_%s")" >> /home/vagrant/1.txt

echo $$ >/var/run/sc2.pid
sleep 10

declare -i number
declare -i files_number
declare -i user
declare -i vesbackup

number=$(sudo ls /local/backups | wc -l)

# user=$(cat /etc/sc2.cfg)

vesbackup=$(sudo du -s /local/backups/ | cut -f 1)

source /etc/sc2.cfg

echo "number $number"
echo "files number $files_number"
echo "obiem $obiem"
echo "cucumber $user"
echo "vesbackup $vesbackup"


if [ $number -gt $files_number ]; then 
	echo "da "
		echo "alert! number of files is $number more than $files_number" | exim root@localhost

	else echo "no"
fi


if [ $vesbackup -gt $obiem ]; then 
	echo "da "
		echo "alert! size of files is $vesbackup Kb and more than $obiem Kb" | exim root@localhost

	else echo "no"
fi


sleep 10