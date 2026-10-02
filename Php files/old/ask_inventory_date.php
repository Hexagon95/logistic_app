<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_ask_inventory_date.php';

$taskInventoryDate = new Task();
echo json_encode($taskInventoryDate->getResult());