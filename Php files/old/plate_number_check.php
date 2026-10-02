<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_plate_number_check.php';
include 'tasks/task_plate_number_check.php';

$taskPlateNumberCheck = new Task();
echo json_encode($taskPlateNumberCheck->getResult());