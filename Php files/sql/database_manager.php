<?php

require_once __DIR__ . '/config.php';

class DatabaseManager {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private string $pdoServer =     DB_SERVER;
    private string $pdoUser =       DB_USER;
    private string $pdoPassword =   DB_PASSWORD;
    private ?PDO $conn =            null;
    private array $data =           [];

    public function getData(): array {
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
            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->execute($parameters);
            $this->data = [];
            do {
                if($sqlQuery->columnCount() > 0) {
                    $this->data = $sqlQuery->fetchAll(PDO::FETCH_ASSOC);
                    break;
                }
            } while($sqlQuery->nextRowset());
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