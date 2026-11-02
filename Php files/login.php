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
            $this->_checkID();
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
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->select_tabletLista(),
            [
                'eszkoz_id' => $this->request['eszkoz_id']
            ],
            $this->request['customer']
        );
        $this->_checkDatabaseResult($this->databaseManager->getData());
        $this->result = [[
            'error' => "Az eszköz nincs dolgozóhoz rendelve! ({$this->request['eszkoz_id']})",
            'Ugyfel_id' => 'Ismeretlen'
        ]];
    }

    private function _checkID(): void {
        $isMatch = false;
        foreach($this->databaseManager->getData() as $value) {
            if(!isset($value['Eszkoz_id'])) continue;
            if($value['Eszkoz_id'] == $this->request['eszkoz_id']) {
                $isMatch = true;
                if(isset($value['dolgozo_kod']) && $value['dolgozo_kod'] !== null && $value['dolgozo_kod'] > 0) {
                    $this->result = [
                        [
                            'error' => '',
                            'Ugyfel_id' => $value['Ugyfel_id'] ?? 'Ismeretlen'
                        ],
                        $value
                    ];
                }
                elseif(isset($value['raktar_id']) && $value['raktar_id'] !== null) {
                    $this->result = [
                        [
                            'error' => '',
                            'raktar_megnevezes' => $value['raktar_megnevezes'] ?? ''
                        ],
                        $value
                    ];
                }
                break;
            }
        }
        if(!$isMatch) {
            $databaseManager = new DatabaseManager(
                $this->sqlCommand->exec_tabletFelvitel(),
                [
                    'eszkoz_id' => $this->request['eszkoz_id']
                ],
                $this->request['customer']
            );
            $this->_checkDatabaseResult($databaseManager->getData());
        }
    }

    private function _checkDatabaseResult(array $result): void {
        if(isset($result[0]['error']) && $result[0]['error'] !== '') throw new RuntimeException(
            $result[0]['message'] ?? (string)$result[0]['error']
        );
    }
}

$taskLogin = new Task();

echo json_encode(
    $taskLogin->getResult(),
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);