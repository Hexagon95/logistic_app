<?php
class DatabaseManager{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $pdoServer =   "localhost";
    private $pdoDatabase = "mosaic";
    //private $pdoDatabase = "mosaic_test";
    private $pdoUser =     "app";
    private $pdoPassword = "Dh!Flmn2J6uJ";
    private $data;
    public function getData(){return $this->data;
    }
    public $conn;
    
    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($queryString, $parameters = []){        
        $this->_connect();
        $this->_executeQuery($queryString, $parameters);
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _connect(){
        try {            
            $this->conn = new PDO("sqlsrv:Server=$this->pdoServer;Database=$this->pdoDatabase;", $this->pdoUser, $this->pdoPassword);            
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }
        catch (\Throwable $th) {            
            echo json_encode(array(['Connection failed' => $th->getMessage()]));
        }
    }

    private function _executeQuery($queryString, $parameters){
        try {
            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->bindParam(':parameter', $parameters['parameter'], PDO::PARAM_STR);
            $sqlQuery->bindParam(':user_id', $parameters['user_id'], PDO::PARAM_INT);
			$sqlQuery->bindParam(':kimenet', $this->data, PDO::PARAM_STR|PDO::PARAM_INPUT_OUTPUT, 4000);
            $sqlQuery->execute();
        }
        catch (\Throwable $th){
            $this->data = json_encode(array(['Execution failed' => $th->getMessage()]));
        }
    }
}