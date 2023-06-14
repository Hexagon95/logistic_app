<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $success = 1;
    private $request;
    private $result;
        public function getResult(){return ($this->success == 1)? $this->result : array(['error' => 1]);
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){        
        try {
            $this->_inizialite();
            $this->_checkStorage();
            $this->_executeTask();
        } catch (\Throwable $th) {
            $this->success = 0;
        }
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand($this->request['customer']);        
    }

    private function _checkStorage(){
        $this->databaseManager =        new DatabaseManager($this->sqlCommand->select_tarhely_Id(), [
            'input' => $this->request['tarhely_id'],
        ]);
        $this->result =                 $this->databaseManager->getData();
        if($this->result[0]['id'] == 0) throw new Exception('invalid_storage_exception');
    }

    private function _executeTask(){
        $this->databaseManager =    new DatabaseManager($this->sqlCommand->select_tarhelyKeszletEllenorzes(), [
            'tarhely_id' => $this->request['tarhely_id'],
        ]);
        $this->result =             $this->databaseManager->getData();
    }
}