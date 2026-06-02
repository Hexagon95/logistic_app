<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_parameter_userid_output.php';
include 'tasks/task_inventory_mezandmol_save.php';

$taskInventoryMezandmolSave = new Task();
echo json_encode($taskInventoryMezandmolSave->getResult());