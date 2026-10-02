<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_finish_new_entry.php';

$taskFinishNewEntry = new Task();
echo json_encode(array(['success' => 1]));