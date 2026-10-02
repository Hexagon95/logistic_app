<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_list_delivery_out_items.php';

$taskListDeliveryOutItems = new Task();
echo json_encode($taskListDeliveryOutItems->getResult());