<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_ask_local_maintenance_scan.php';

$taskAskLocalMaintenanceScan = new Task();
echo json_encode($taskAskLocalMaintenanceScan->getResult());