#!/bin/bash
#set -x	


# обнуляемся,  пусть будет
statecon=
proc=
IP=
state=
row=
whoscript=organisation

CLEAR='\033[0m'
RED='\033[0;31m'

#справка, раз сделал пусть будет
function usage() {
  if [ -n "$1" ]; then
    echo -e "${RED} $1${CLEAR}\n";
  fi
  echo "Usage: $0 [-p process] [-s state] [-w whois][-r row][-v verbose]"
  echo "  -p|--process   Name or PID of process (ex:  wget 6678)"
  echo "  -s|--state     State of connection (opt: l - listen, e - established, с - closed, cw - close_wait or you can enter any other. Ignorecase (Ex:  l  wc  listen LAST_ACK YN_SEND"
  echo "  -r|--row     Rows to display (ex: 1 6 56)"
  echo "  -w|--who    Whois information .Show information about hosts from whois cmd. Ignorecase. Default - Country. (ex: OrgName Country OrgAbuseHandle)"
   echo "  -v|--verbose     Optional. Logging on. By default off  (Ex: -v or dont use)"
  echo "Example: $0 [-p chrome] [-s listen] [-w city][-r 3][-v]"  
  echo ""
  exit 1
}

#отбивка
while [[ "$#" > 0 ]]; do case $1 in
  -p|--process) proc="$2"; shift;shift;;
  -s|--state) state="$2";shift;shift;;
  -r|--row) row="$2";shift;shift;;
  -w|--who) who="$2";shift;shift;;  
  -v|--verbose) set -x	;shift;;
  *) usage "Unknown parameter: $1"; shift; shift;;
esac; 
done

# echo "process $proc"
# echo "state $state"
# echo "row $row"
# echo "verbose $verbose"
# echo "who $who"

#дичь, заменить или убрать
if [ "$state" == l ]; then statecon=listen
else
if [ "$state" == e ]; then statecon=established
else
if [ "$state" == c ]; then statecon=closed
else
if [ "$state" == cw ]; then statecon=close_wait
else 
statecon=$state
fi  fi  fi  fi 


# echo "state posle proverki = $state"
# echo "statecon posle proverki = $statecon"
# echo "row $row"
# echo "whoscript $whoscript"


if [ "$who" != "$whoscript" ]; then 
whoscript=$who
fi  


result=`sudo netstat -tunapl | 
#добавляем фильтр  для state, отключаем регистрозависимость
grep -wi  "$statecon" |
# проблема с переменными в одинарных кавычках в awk, решено разбиением, больше страданий
awk '/'"$proc/"' {print $5}' | 
cut -d: -f1 | 
sort | 
uniq -c | 
sort | 
# добавил строки
tail -n"$row" | 
grep -oP '(\d+\.){3}\d+' | 
while 
	read IP ; 
  do whois $IP | 
# в финалке поправить обратно organisation на Organization и убрать пробелы после, ну или нет. регистрозависимость убрана
  awk -F':   ' 'BEGIN{IGNORECASE = 1}/^'"$whoscript"'/ {print $2 }' ; 
	done`

echo $result

# todo- добавить проверок вводимых данных по типу,   что такое в задании ss уточнить , 
