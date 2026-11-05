<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/altered_database_managers/dm_plate_number_check.php';

class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private array $request = [];
    private string|array|null $result = null;
    private bool $success = true;
    private string $errorMessage = '';

    public function getResult(): string|array|null {
        return $this->success ? $this->result : [[
            'error' => 1,
            'message' => $this->errorMessage
        ]];
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct() {
        try {
            $this->_initialize();
            $this->_checkPlateNumber();
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

    private function _checkPlateNumber(): void {
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_tabletHelysziniszerelesUjTetelRendszam(),
            [
                'rendszam' => $this->request['rendszam'] ?? null,
                'bizonylat_id' => $this->request['bizonylat_id'] ?? null
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
    }

    private function _checkDatabaseResult(): void {
        if(is_array($this->result) && isset($this->result[0]['error'])) {
            $this->success = false;
            $this->errorMessage = $this->result[0]['message'] ?? (string)$this->result[0]['error'];
        }
    }
}

$taskPlateNumberCheck = new Task();

echo json_encode(
    $taskPlateNumberCheck->getResult(),
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);