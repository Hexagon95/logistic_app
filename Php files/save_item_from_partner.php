<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_save_item_from_partner.php';
include 'tasks/task_save_item_from_partner.php';

$task_save_item_from_partner = new Task();
echo json_encode($task_save_item_from_partner->getResult());