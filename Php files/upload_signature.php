<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/database_manager.php';

class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private bool $success = true;
    private string $errorMessage = '';
    private array $request = [];
    private array $result = [];

    public function getResult(): array {
        return $this->success ? $this->result : [[
            'error' => 1,
            'message' => $this->errorMessage
        ]];
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct() {
        try {
            $this->_initialize();

            switch($this->request['mode'] ?? '') {
                case 'signature':
                    $this->_executeSignature();
                    break;

                case 'deliveryNote':
                    $this->_executeDeliveryNote();
                    break;

                default:
                    throw new UnexpectedValueException('Ismeretlen vagy hiányzó mód.');
            }

            $this->_generatePdf();
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
        $this->sqlCommand = new SqlCommand();
    }

    private function _executeSignature(): void {
        $parameter = json_encode(
            [
                'id' => $this->request['id'],
                'alairas' => $this->request['alairas'],
                'alairo' => $this->request['alairo']
            ],
            JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE | JSON_THROW_ON_ERROR
        );
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_bizonylatAlairasFelvitele(),
            [
                'parameter' => $parameter
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
    }

    private function _executeDeliveryNote(): void {
        $parameter = json_encode(
            [
                'id' => $this->request['id'],
                'fuvarlevel' => $this->request['fuvarlevel']
            ],
            JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE | JSON_THROW_ON_ERROR
        );
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_bizonylatFuvarlevelszamFelvitele(),
            [
                'parameter' => $parameter
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
    }

    private function _generatePdf(): void {
        $query = http_build_query([
            'ceg' => $this->request['customer'],
            'kategoria_id' => 3,
            'id' => $this->request['id'],
            'save' => 1
        ]);
        $url = 'https://app.mosaic.hu/pdfgenerator/bizonylat.php?' . $query;
        $context = stream_context_create([
            'http' => [
                'timeout' => 15
            ]
        ]);
        $response = @file_get_contents($url, false, $context);
        if($response === false) throw new RuntimeException('A PDF generálása sikertelen.');
    }

    private function _checkDatabaseResult(): void {
        if(
            isset($this->result[0]['error'], $this->result[0]['message'])
            && in_array($this->result[0]['error'], ['Connection failed', 'Execution failed'], true)
        ) {
            throw new RuntimeException($this->result[0]['message']);
        }
    }
}

$taskUploadSignature = new Task();

echo json_encode(
    [[
        'result' => $taskUploadSignature->getResult()
    ]],
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);