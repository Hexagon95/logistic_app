<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_incoming_delivery_note.php';

$taskIncomingDeliveryNote = new Task();
echo json_encode($taskIncomingDeliveryNote->getResult());