<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'dm_add_delivery_note_item.php';
include 'tasks/task_add_delivery_note_item_finished.php';

$taskAdddeliverynoteitemFinished = new Task();
echo json_encode($taskAdddeliverynoteitemFinished->getResult());