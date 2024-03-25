<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_add_new_delivery_note.php';

$taskAddNewDeliveryNote = new Task();
echo json_encode($taskAddNewDeliveryNote->getResult());