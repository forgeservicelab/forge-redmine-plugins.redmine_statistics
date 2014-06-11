<?php
$username = "";
$password = "";
$hostname = "";
$database = "";

if (!$link = mysql_connect($hostname,$username,$password)) {
    echo 'Could not connect to mysql';
    exit;
}

if (!mysql_select_db($database, $link)) {
    echo 'Could not select database';
    exit;
}
//Gets project identifier from iframe URL
$name = mysql_real_escape_string($_GET['project_id']);

//Calculates average from closed issues, but doesn't count issues that have been created as closed and welcome messages
$average    = "select TIME_FORMAT(SEC_TO_TIME(AVG(TIME_TO_SEC(TIMEDIFF(issues.updated_on,issues.created_on)))), '%H hours %i minutes %S seconds' ) AS Duration from issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id=5 AND issues.updated_on != issues.created_on AND projects.identifier='".$name."' AND issues.subject!='Welcome to FORGE Service Lab!'";
$average_result = mysql_query($average, $link);

//Calculates max time from closed issues, but doesn't count issues that have been created as closed and welcome messages
$max = "select TIME_FORMAT(SEC_TO_TIME(MAX(TIME_TO_SEC(TIMEDIFF(issues.updated_on,issues.created_on)))), '%H hours %i minutes %S seconds' ) AS Max from issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id=5 AND projects.identifier='".$name."' AND issues.updated_on != issues.created_on AND issues.subject!='Welcome to FORGE Service Lab!'"
$max_result = mysql_query($max, $link);

//Calculates min time from closed issues, but doesn't count issues that have been created as closed and welcome messages
$min = "select TIME_FORMAT(SEC_TO_TIME(MIN(TIME_TO_SEC(TIMEDIFF(issues.updated_on,issues.created_on)))), '%H hours %i minutes %S seconds' ) AS Min from issues INNER JOIN projects ON projects.id = issues.project_id WHERE issues.status_id=5 AND projects.identifier='".$name."' AND issues.updated_on != issues.created_on AND issues.subject!='Welcome to FORGE Service Lab!'";
$min_result  = mysql_query($min, $link);

//prints everything in tables
echo "<table border='1'>
<tr>
<th>Fastest Issue Closure Time</th>
</tr>";

while ($row = mysql_fetch_assoc($min_result)) {
 echo "<tr>";
 echo "<td>$row[Min]</td>";
 echo "</tr>";
}
echo "</table><br>";
echo "<table border='1'>
<tr>
<th>Slowest Issue Closure Time</th>
</tr>";

while ($row = mysql_fetch_assoc($max_result)) {


 echo "<tr>";
 echo "<td>$row[Max]</td>";
 echo "</tr>";
}
echo "</table><br>";

echo "<table border='1'>
<tr>
<th>Average Issue Closure Time</th>
</tr>";

while ($row1 = mysql_fetch_assoc($average_result)) {
 echo "<tr>";
 echo "<td>$row1[Duration]</td>";
 echo "<tr>";
}

echo "</table>";

?>
