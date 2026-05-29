<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_inventory_mezandmol.php';

$taskInventoryMezandmol = new Task();
echo json_encode($taskInventoryMezandmol->getResult());