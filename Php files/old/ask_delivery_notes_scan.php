<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_ask_delivery_notes_scan.php';

$taskAskDeliveryNotesScan = new Task();
echo json_encode($taskAskDeliveryNotesScan->getResult());