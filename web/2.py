#!/usr/bin/python3

import psycopg2
from psycopg2 import Error
# from flask import Flask, request,render_template
# from prettytable import PrettyTable
# from prettytable import from_db_cursor
from os import read
# from datetime import datetime
# current_datetime = datetime.now()


connection = psycopg2.connect(user="vagrant", password="vagrant",host="db.runalsh.local",port="5432",database="mydb")
cursor = connection.cursor()
cursor.execute("SELECT * FROM articles")

record = cursor.fetchall()
columns = cursor.description
# print (columns)
# print (record)  
# # tableazaglovki = from_db_cursor(cursor)
# # # print (tableazaglovki)

#ВТОРАЯ  ВЕРСИЯ - Оставляем НА ФИНАЛКУ
rows = '<tr>'
#заголовки выводим
for row1 in columns:
   rows += f'<td>{row1[0]}</td>'
rows += '</tr>'

#сама таблица
for row in record:
  rows += f"<tr>"
  for col in row:
    rows += f"<td>{col}</td>"
  rows += f"</tr>"
data = '''
<html>
<style> table,  td {    border:1px solid black; }td</style><body><table>%s</table></body></html>'''%(rows)

# print (contents)





# column_names = []
# # with connection.cursor() as cursor:
# cursor.execute("select column_name from information_schema.columns where table_schema = 'public' and table_name='articles'")
# column_names = [row[0] for row in cursor] 
# print(format(column_names))  

# РАБОТАЕТ, но без бордеров
# xxx=tabulate(record, headers=column_names, tablefmt='html', border: Border.all)
# print (xxx)


# mytable = PrettyTable()
# mytable.field_names = [столбцы]
# mytable.add_rows(
    # [
        ### cnhjr
    # ]
# )

# print (mytable)
# print(mytable.get_html_string())

# x = PrettyTable()
# x.field_names = column_names
# x.add_row(["Adelaide", 1295, 1158259, 600.5])
# print(x)

# mytable = from_db_cursor(cursor)
# print(mytable)
    
# table = PrettyTable(cursor)
    
# table.add_rows(record)
# table.field_names = column_names
# table.format = True

# data = table.get_html_string(attributes={'border': 2, 'style': 'border-width: 2px; border-collapse: collapse;'})
# print (data)

# with open('test.html', 'wb') as f:
# f.write(data)
    
# print (record)    
# print (table)
# print (table.get_html_string())

# with open("python.html", "w") as file:
    # file.write(data)
# file.close()


#первый вариант рабочий, читерство с prettytable
# column_names = []
# # with connection.cursor() as cursor:
# cursor.execute("select column_name from information_schema.columns where table_schema = 'public' and table_name='articles'")
# column_names = [row[0] for row in cursor] 
# print(format(column_names))  
# table = PrettyTable(cursor)
# table.add_rows(record)
# table.field_names = column_names
# table.format = True
# data = table.get_html_string(attributes={'border': 2, 'style': 'border-width: 2px; border-collapse: collapse;'})
# print (data)


#вывод
with open("/home/vagrant/python.html", "w") as file:
    file.write(data)
file.close()