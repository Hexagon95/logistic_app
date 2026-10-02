<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){        
        $this->_inizialite();        
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand($this->request['customer']);
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_abroncs_reszletezo_felvitele1(),
            ['parameter' => $this->request['parameter']]
        );
        $this->result =             $this->databaseManager->getData();
    }
}