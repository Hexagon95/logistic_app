<?php

require_once __DIR__ . '/../config.php';

class DatabaseManager {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private string $pdoServer =     DB_SERVER;
    private string $pdoUser =       DB_USER;
    private string $pdoPassword =   DB_PASSWORD;
    private string|array|null $data = null;
    public ?PDO $conn = null;

    public function getData(): string|array|null {
        return $this->data;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(string $queryString, array $parameters = [], string $pdoDatabase = "mosaic") {
        $this->_connect($pdoDatabase);
        $this->_executeQuery($queryString, $parameters);
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _connect(string $pdoDatabase): void {
        try {
            $this->conn = new PDO(
                "sqlsrv:Server={$this->pdoServer};Database={$pdoDatabase};",
                $this->pdoUser,
                $this->pdoPassword,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
                ]
            );
        }
        catch(Throwable $th) {
            $this->conn = null;
            $this->data = $this->_createErrorResult('Connection failed', $th);
        }
    }

    private function _executeQuery(string $queryString, array $parameters): void {
        if($this->conn === null) return;
        try {
            $output = '';
            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->bindValue(':bizonylat_id', $parameters['bizonylat_id'], PDO::PARAM_STR);
            $sqlQuery->bindValue(':tetel_id', $parameters['tetel_id'], PDO::PARAM_STR);
            $sqlQuery->bindParam(':output', $output, PDO::PARAM_STR | PDO::PARAM_INPUT_OUTPUT, 4000);
            $sqlQuery->execute();
            $this->data = $output;
        }
        catch(Throwable $th) {
            $this->data = $this->_createErrorResult('Execution failed', $th);
        }
    }

    private function _createErrorResult(string $error, Throwable $th): array {
        return [[
            'error' => $error,
            'message' => $th->getMessage()
        ]];
    }
}