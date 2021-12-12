#!/bin/bash

psql -U vagrant -d mydb -c 'SELECT * FROM articles' > /local/files/ans$(date +"%Y_%m_%d_%I_%M_%s")

declare -i number

number=$(ls /local/files | wc -l)
echo "$number"


if [ $number -gt 3 ]; then 
	echo "more than 3 files, archive and move tO /local/backups"
	tar -cf /local/backups/arch$(date +"%Y_%m_%d_%I_%M_%s").tar  /local/files --remove-files  &> /dev/null
	else echo "less than 3 files"
fi



