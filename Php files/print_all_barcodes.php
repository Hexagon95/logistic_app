<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_print_all_barcodes.php';

$task_print_all_barcodes = new Task();
echo json_encode($task_print_all_barcodes->getResult());