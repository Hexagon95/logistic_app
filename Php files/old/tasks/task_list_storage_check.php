<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $success = 1;
    private $request;
    private $result;
        public function getResult() {return ($this->success == 1)? $this->result : json_encode(array(['error' => 1]));
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){        
        try {
            $this->_inizialite();
            $this->_checkStorage();
            $this->_executeTask();
        } catch (\Throwable $th) {
            //echo $th->getMessage();
            $this->success = 0;
        }
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
    }

    private function _checkStorage(){
        $this->databaseManager =        new DatabaseManager(
            $this->sqlCommand->select_tarhely_Id1(),
            [
                'raktar_id' =>  $this->request['raktar_id'],
                'input' =>      $this->request['tarhely_id'],
                'user_id' =>    $this->request['user_id']
            ],
            $this->request['customer']
        );
        $this->result =                 $this->databaseManager->getData();
        //if($this->result[0]['id'] == 0) {throw new Exception('invalid_storage_exception');}
    }

    private function _executeTask(){
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->select_tarhelyKeszletEllenorzes1(),
            [
                'raktar_id' =>  $this->request['raktar_id'],
                'tarhely_id' => $this->request['tarhely_id'],
                'user_id' =>    $this->request['user_id']
            ],
            $this->request['customer']
        );
        $this->result =         $this->databaseManager->getData();
    }
}