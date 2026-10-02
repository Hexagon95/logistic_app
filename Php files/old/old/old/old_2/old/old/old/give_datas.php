<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_give_datas.php';

$taskGiveDatas = new Task();

/*$directory = "../../";
$logPath = $directory."logs/array_".date("YmdHi").".txt";
file_put_contents($logPath, print_r($taskGiveDatas->getResult(), true), FILE_APPEND);*/

echo json_encode($taskGiveDatas->getResult());