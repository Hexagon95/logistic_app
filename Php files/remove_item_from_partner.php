<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_remove_delivery_note_item.php';
include 'tasks/task_remove_item_from_partner.php';

$task_remove_item_from_partner = new Task();
echo json_encode($task_remove_item_from_partner->getResult());