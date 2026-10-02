<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_check_article.php';

$taskCheckArticle = new Task();
echo json_encode($taskCheckArticle->getResult());