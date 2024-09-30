<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_parameter_userid_output.php';
include 'tasks/task_add_new_delivery_note_finish.php';

$taskAddNewDeliveryNoteFinish = new Task();
echo json_encode($taskAddNewDeliveryNoteFinish->getResult());