<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/database_manager.php';

class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private array $request = [];
    private array $result = [];

    public function getResult(): array {
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct() {
        $this->_initialize();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize(): void {
        try {
            $input = file_get_contents('php://input');
            if($input === false) throw new RuntimeException('A kérés tartalma nem olvasható.');
            $this->request = json_decode($input, true, 512, JSON_THROW_ON_ERROR);
            if(!is_array($this->request)) throw new UnexpectedValueException('A kérés nem érvényes JSON objektum.');
            $this->sqlCommand = new SqlCommand();
            $this->databaseManager = new DatabaseManager(
                $this->sqlCommand->select_Tablet_Bejovoszallitolevel_tetelek_uj(),
                [
                    'bizonylat_id' => $this->request['bizonylat_id'] ?? null,
                    'rendszam' => $this->request['rendszam'] ?? '',
                    'user_id' => $this->request['user_id'] ?? null
                ],
                $this->request['customer']
            );
            $this->result = $this->databaseManager->getData();
        }
        catch(Throwable $th) {
            $this->result = [[
                'error' => 'Execution failed',
                'message' => $th->getMessage()
            ]];
        }
    }
}

$taskAddDeliveryNoteItem = new Task();

echo json_encode(
    $taskAddDeliveryNoteItem->getResult(),
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);