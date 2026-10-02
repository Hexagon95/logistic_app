<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_parameter_output.php';
include 'tasks/task_change_password.php';

$taskChangePassword = new Task();
echo json_encode($taskChangePassword->getResult());