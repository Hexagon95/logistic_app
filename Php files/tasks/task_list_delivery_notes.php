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
        $this->databaseManager =    new DatabaseManager($this->sqlCommand->exec_bizonylatDataTableDetails(), [
            'parameter' =>  json_encode(array('felhasznalo_id' => $this->request['dolgozo_kod'], 'kategoria_id' => 3, 'statusz_id' => 1))
        ]);
        $this->result = $this->databaseManager->getData();
    }
}