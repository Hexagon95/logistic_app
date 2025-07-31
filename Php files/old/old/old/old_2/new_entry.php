<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_new_entry.php';

$taskNewEntry = new Task();
echo json_encode($taskNewEntry->getResult());