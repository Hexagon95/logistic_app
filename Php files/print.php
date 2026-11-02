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
            $this->_loadBarcodeData();
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

    private function _loadBarcodeData(): void {
        $isStorage = ($this->request['type'] ?? '') === 'storage';

        $queryString = $isStorage
            ? $this->sqlCommand->exec_barcodePrintTarhelyCikkek()
            : $this->sqlCommand->exec_barcodePrintFelvitele();

        $parameters = $isStorage
            ? [
                'tarhely' => $this->request['tarhely'],
                'idk' => $this->request['idk']
            ]
            : [
                'tarhely' => $this->request['tarhely']
            ];

        $this->databaseManager = new DatabaseManager(
            $queryString,
            $parameters,
            $this->request['customer']
        );

        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
    }

    private function _checkDatabaseResult(): void {
        if(isset($this->result[0]['error'])) {
            $this->success = false;
            $this->errorMessage = $this->result[0]['message'] ?? (string)$this->result[0]['error'];
        }
    }
}

$taskFinishGiveDatas = new Task();

echo json_encode(
    [[
        'result' => $taskFinishGiveDatas->getResult()
    ]],
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);