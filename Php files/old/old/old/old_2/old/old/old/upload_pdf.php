<?php
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_upload_pdf.php';

$ROOT = __DIR__;
$ROOT_ARRAY = explode(DIRECTORY_SEPARATOR,__DIR__);
$ROOT = array_slice($ROOT_ARRAY, 0, (sizeof($ROOT_ARRAY)-2) );
$ROOT_DIRECTORY = implode(DIRECTORY_SEPARATOR, $ROOT);

$ROOT = $ROOT_DIRECTORY."/logs/upload.pdf.log";
$return_array = array();

$json = file_get_contents('php://input');
$data = json_decode($json);
$json_pretty = json_encode($data, JSON_PRETTY_PRINT);
file_put_contents( $ROOT, "\n\r".$json_pretty."\n\r", FILE_APPEND);

header( 'Content-Type: application/json' );


$taskUploadPdf = new Task($ROOT_DIRECTORY);
$taskUploadPdf->_SaveFile();
$taskUploadPdf->_executeBizonylatDokumentumFelvitele();
echo json_encode(array(['result' => $taskUploadPdf->getResult()]));
?>