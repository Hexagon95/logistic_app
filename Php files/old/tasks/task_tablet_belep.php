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
        $this->sqlCommand =         new SqlCommand();        
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_tabletBelep(),
            [
                'eszkoz_id' =>  $this->request['eszkoz_id'],
                'verzio' =>     $this->request['verzio']
            ],
            $this->request['customer']
        );
        $this->result =             $this->databaseManager->getData();
    }
}