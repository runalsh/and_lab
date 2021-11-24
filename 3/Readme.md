Скрипт показывает информацию о процессе и по требованию пользователя выводит информацию о странах соединениях.

Справка 

Usage: ./and.sh [-p process] [-s state] [-w whois][-r row][-v verbose]

  -p|--process   Name or PID of process (ex:  wget 6678)
  
  -s|--state     State of connection (opt: l - listen, e - established, с - closed, cw - close_wait or you can enter any other. Ignorecase (Ex:  l  wc  listen LAST_ACK YN_SEND
  
  -r|--row     Rows to display (ex: 1 6 56)
  
  -w|--who    Whois information .Show information about hosts from whois cmd. Ignorecase. Default - Country. (ex: OrgName Country OrgAbuseHandle)
  
  -v|--verbose     Optional. Logging on. By default off  (Ex: -v or dont use)
  
Example: ./and.sh [-p chrome] [-s listen] [-w city][-r 3][-v]



TODO
добавить проверок вводимых данных по типу,   
что такое в задании ss уточнить ,   
доделать число коннектов под каждую страну (просто, но нет времени),   
добавить проверки на введение значений ключей
