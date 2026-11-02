<?php

error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/database_manager.php';

class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private string $rootDirectory;
    private array $request = [];
    private array $files = [];
    private array $result = [];
    private string $konyvtar = '';
    private string $megnevezes = '';
    private string $pdf = '';
    private int|string $bizonylatId;
    private bool $success = true;
    private string $errorMessage = '';

    public function getResult(): array {
        return $this->success ? $this->result : [[
            'error' => 1,
            'message' => $this->errorMessage
        ]];
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(string $rootDirectory) {
        $this->rootDirectory = $rootDirectory;
        try {
            $this->_initialize();
            $this->_saveFile();
            $this->_executeDocumentUpload();
        }
        catch(Throwable $th) {
            $this->success = false;
            $this->errorMessage = $th->getMessage();
        }
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize(): void {
        $input = file_get_contents('php://input');
        if($input === false) throw new RuntimeException('A kérés tartalma nem olvasható.');
        $this->request = json_decode($input, true, 512, JSON_THROW_ON_ERROR);
        if(!is_array($this->request)) throw new UnexpectedValueException('A kérés nem érvényes JSON objektum.');
        foreach(['customer', 'id', 'pdf', 'user_id'] as $key) {
            if(!array_key_exists($key, $this->request)) throw new UnexpectedValueException("Hiányzó paraméter: {$key}");
        }
        if(!is_string($this->request['customer']) || !preg_match('/^[A-Za-z0-9_-]+$/', $this->request['customer'])) {
            throw new UnexpectedValueException('Érvénytelen customer érték.');
        }
        if(!is_string($this->request['pdf']) || $this->request['pdf'] === '') throw new UnexpectedValueException('Hiányzó vagy érvénytelen PDF adat.');
        $this->konyvtar = 'documents/' . $this->request['customer'];
        $this->bizonylatId = $this->request['id'];
        $this->pdf = $this->request['pdf'];
        $this->megnevezes = $this->_randomString() . '.pdf';
        $this->files = [
            'bizonylat_id' => $this->bizonylatId,
            'TabletPDFUpload' => 1,
            'files' => [
                [
                    'id' => 0,
                    'konyvtar' => $this->konyvtar,
                    'megnevezes' => $this->megnevezes,
                    'name' => 'Bizonylat ' . time()
                ]
            ]
        ];
        $this->_writeLogs();
    }

    private function _saveFile(): void {
        $pdfData = base64_decode($this->pdf, true);
        if($pdfData === false) throw new RuntimeException('A PDF base64 adata érvénytelen.');
        $directory = $this->rootDirectory
            . DIRECTORY_SEPARATOR . 'appdoc'
            . DIRECTORY_SEPARATOR . $this->konyvtar;
        if(!is_dir($directory)) throw new RuntimeException("A dokumentum könyvtár nem létezik: {$directory}");
        $filePath = $directory . DIRECTORY_SEPARATOR . $this->megnevezes;
        $bytesWritten = @file_put_contents($filePath, $pdfData, LOCK_EX);
        if($bytesWritten === false) throw new RuntimeException('A PDF fájl mentése sikertelen.');
    }

    private function _executeDocumentUpload(): void {
        $parameter = json_encode(
            $this->files,
            JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE | JSON_THROW_ON_ERROR
        );
        $this->sqlCommand = new SqlCommand();
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_bizonylatDokumentumFelvitele(),
            [
                'parameter' => $parameter,
                'user_id' => $this->request['user_id']
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
    }

    private function _checkDatabaseResult(): void {
        if(
            isset($this->result[0]['error'], $this->result[0]['message'])
            && in_array($this->result[0]['error'], ['Connection failed', 'Execution failed'], true)
        ) {
            throw new RuntimeException($this->result[0]['message']);
        }
    }

    private function _writeLogs(): void {
        $requestLog = $this->request;
        $requestLog['pdf'] = '[BASE64 PDF OMITTED - ' . strlen($this->pdf) . ' characters]';
        $requestJson = json_encode(
            $requestLog,
            JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
        );
        $filesJson = json_encode(
            $this->files,
            JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
        );
        $uploadLog = $this->rootDirectory
            . DIRECTORY_SEPARATOR . 'app'
            . DIRECTORY_SEPARATOR . 'logs'
            . DIRECTORY_SEPARATOR . 'upload.pdf.log';
        $filesLog = $this->rootDirectory
            . DIRECTORY_SEPARATOR . 'logs'
            . DIRECTORY_SEPARATOR . 'files.logs';
        if(@file_put_contents($uploadLog, PHP_EOL . $requestJson . PHP_EOL, FILE_APPEND | LOCK_EX) === false) {
            error_log("Nem sikerült írni a log fájlt: {$uploadLog}");
        }
        if(@file_put_contents($filesLog, PHP_EOL . $filesJson . PHP_EOL, FILE_APPEND | LOCK_EX) === false) {
            error_log("Nem sikerült írni a log fájlt: {$filesLog}");
        }
    }

    private function _randomString(): string {
        return bin2hex(random_bytes(32));
    }
}

$rootDirectory = dirname(__DIR__, 3);
$taskUploadPdf = new Task($rootDirectory);

echo json_encode(
    [[
        'result' => $taskUploadPdf->getResult()
    ]],
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);