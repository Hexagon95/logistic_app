<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_scan_barcode_for_sticker.php';

$task_scan_barcode_for_sticker = new Task();
echo json_encode($task_scan_barcode_for_sticker->getResult());