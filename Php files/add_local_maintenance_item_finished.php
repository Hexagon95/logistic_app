<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_add_delivery_note_item.php';
//include 'database_manager.php';
include 'tasks/task_add_local_maintenance_item_finished.php';

$task_add_local_maintenance_item_finished = new Task();
echo json_encode($task_add_local_maintenance_item_finished->getResult());