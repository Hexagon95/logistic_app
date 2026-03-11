<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_add_new_item_from_partner.php';
include 'tasks/task_add_new_item_from_partner.php';

$task_add_new_item_from_partner = new Task();
echo json_encode($task_add_new_item_from_partner->getResult());