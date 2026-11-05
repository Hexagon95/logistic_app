<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/database_manager.php';

class Task {
    // ---------- <Variables [public]>  ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public int $success = 0;

    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private array $request = [];
    private array $result = [];
    private string $errorMessage = '';

    public function getResult(): array {
        return $this->result;
    }

    public function getErrorMessage(): string {
        return $this->errorMessage;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct() {
        try {
            $this->_initialize();
            $this->_queryStorages();
            $this->_executeStockMovement();
            $this->success = 1;
        }
        catch(Throwable $th) {
            $this->success = 0;
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

    private function _queryStorages(): void {
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->select_tarhely_Id1(),
            [
                'raktar_id' => $this->request['raktar_id'] ?? null,
                'input' => $this->request['storageFrom'] ?? null,
                'user_id' => $this->request['user_id'] ?? null
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
        if(!isset($this->result[0]['id']) || $this->result[0]['id'] == 0) throw new RuntimeException('A forrás tárhely nem található.');
        $this->request['storageFrom'] = $this->result[0]['id'];

        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->select_tarhely_Id1(),
            [
                'raktar_id' => $this->request['raktar_id'] ?? null,
                'input' => $this->request['storageTo'] ?? null,
                'user_id' => $this->request['user_id'] ?? null
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
        if(!isset($this->result[0]['id']) || $this->result[0]['id'] == 0) throw new RuntimeException('A cél tárhely nem található.');
        $this->request['storageTo'] = $this->result[0]['id'];
    }

    private function _executeStockMovement(): void {
        $parameter = json_encode(
            [
                'raktar_honnan' => $this->request['storageFrom'],
                'raktar_hova' => $this->request['storageTo'],
                'cikkek' => $this->request['cikkek']
            ],
            JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE | JSON_THROW_ON_ERROR
        );
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_keszletmozgatasFelvitele(),
            [
                'parameter' => $parameter,
                'user_id' => $this->request['user_id'] ?? null
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->_checkDatabaseResult();
    }

    private function _checkDatabaseResult(): void {
        if(isset($this->result[0]['error'])) throw new RuntimeException(
            $this->result[0]['message'] ?? (string)$this->result[0]['error']
        );
    }
}

$taskMove = new Task();

$response = $taskMove->success === 1
    ? [['success' => 1]]
    : [[
        'success' => 0,
        'error' => 1,
        'message' => $taskMove->getErrorMessage()
    ]];

echo json_encode(
    $response,
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);