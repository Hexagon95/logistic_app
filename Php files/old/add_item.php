<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_add_item.php';
include 'tasks/task_add_item.php';

$json = file_get_contents('php://input');
$data = json_decode($json);
$today = date("Y-m-d H:i:s", time());
file_put_contents("logs/mihidra.log", $today." login.php \n\rJSON_ARRAY:\n\r".json_encode($data)."\n\r", FILE_APPEND);

$taskAddItem = new Task();
echo json_encode(array(['result' => $taskAddItem->getResult()]));