<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_save_deliverynote_item.php';
include 'tasks/task_save_deliverynote_item.php';

$save_deliverynote_item = new Task();
echo json_encode($save_deliverynote_item->getResult());