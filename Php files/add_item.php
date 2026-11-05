<?php

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/altered_database_managers/dm_add_item.php';

class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private array $request = [];
    private string|array|null $result = null;

    public function getResult(): string|array|null {
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(array $request) {
        $this->request = $request;
        $this->_initialize();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize(): void {
        try {
            $this->sqlCommand = new SqlCommand();
            $parameter = json_encode(
                [
                    'tarhely_id' => $this->request['tarhely_id'] ?? null,
                    'cikk_id' => $this->request['cikk_id'] ?? null,
                    'mennyiseg' => $this->request['mennyiseg'] ?? null
                ],
                JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE | JSON_THROW_ON_ERROR
            );
            $this->databaseManager = new DatabaseManager(
                $this->sqlCommand->exec_tabletBetarolasFelvitele(),
                [
                    'parameter' => $parameter ?? null,
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

try {
    $input = file_get_contents('php://input');
    if($input === false) throw new RuntimeException('A kérés tartalma nem olvasható.');
    $request = json_decode($input, true, 512, JSON_THROW_ON_ERROR);
    if(!is_array($request)) throw new UnexpectedValueException('A kérés nem érvényes JSON objektum.');
    $today = date('Y-m-d H:i:s');
    file_put_contents(
        __DIR__ . '/logs/mihidra.log',
        $today . " login.php \n\rJSON_ARRAY:\n\r" . json_encode($request, JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE) . "\n\r",
        FILE_APPEND
    );
    $taskAddItem = new Task($request);
    $response = [['result' => $taskAddItem->getResult()]];
}
catch(Throwable $th) {
    $response = [[
        'result' => [[
            'error' => 'Execution failed',
            'message' => $th->getMessage()
        ]]
    ]];
}

echo json_encode(
    $response,
    JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
);