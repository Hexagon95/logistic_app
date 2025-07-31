<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_delete_item.php';

$taskDeleteItem = new Task();
echo json_encode(array(['result' => $taskDeleteItem->getResult()]));