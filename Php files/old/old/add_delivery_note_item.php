<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_add_delivery_note_item.php';

$taskRemoveDeliveryNoteItem = new Task();
echo json_encode($taskRemoveDeliveryNoteItem->getResult());