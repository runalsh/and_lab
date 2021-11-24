#!/bin/bash

proc = 
sost
strok



sudo netstat -tunapl | 
awk '/@proc/ {print $5}' | 
cut -d: -f1 | 
sort | 
uniq -c | 
sort | 
tail -n5 | 
grep -oP '(\d+\.){3}\d+' | 
while read IP ; 
	do whois $IP | 
		awk -F':' '/^organisation/ {print $2}' ; 
done














