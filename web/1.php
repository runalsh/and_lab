<?php

ini_set('display_errors',1);  
error_reporting(E_ALL);

$servername = "db.runalsh.local";
$username = "vagrant";
$password = "vagrant";
$dbname = "mydb";
$port = "5432";

$dbconn = pg_connect("host=$servername port=$port dbname=$dbname user=$username password=$password");
$result = pg_query($dbconn, $_GET['q']);
/* $data = pg_fetch_all($result); */
/* $rows = pg_num_rows($result);
 */
/* var_dump(pg_fetch_all(pg_query($dbconn, $_GET['q']))); */

/* ужас
echo('<table border="2">');
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
    foreach ($line as $col_value => $row_value) {
        echo("<tr><td>$col_value</td><td>$row_value</td></tr>\n");
    }
}
echo("</table>"); 
*/

/*  второй вариант, лучше но не то
    echo "<table width=100% border=1>\n";
    while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
        echo "\t<tr>\n";
        foreach ($line as $col_value) {
            echo "\t\t<td>$col_value</td>\n";
        }
        echo "\t</tr>\n";
    }
    echo "</table>\n"; 
	*/

// var_dump(pg_fetch_array(pg_query($dbconn, $_GET['q'])));


// заголовок
$table = "<table border='3px'>";
$table .= "<thead>";
$table .= "<tr>";
// счтаем строки с нулевой, выводим НЕ через массив
$i = pg_num_fields($result);
for ($j = 0; $j < $i; $j++) {
    $fieldname = pg_field_name($result, $j);
    $table .= "<th>$fieldname</th>"; 
}
$table .= "</tr>";
//содержимое
$table .= "<tbody>";  
while($row = pg_fetch_assoc($result))
{
    $table .= "<tr>";
    foreach ($row as $key => $value) //во славу сатане
    {
        $table .= "<td>$value</td>";
    }
    $table .= "</tr>";  
}
$table .= "</tbody>";
$table .= "</table>";

echo $table; 
?>

