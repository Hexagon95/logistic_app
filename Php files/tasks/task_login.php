<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $customer;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){       
        $this->_inizialite();
        $this->_checkID();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->select_tabletLista(),
            ['eszkoz_id' => $this->request['eszkoz_id']],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
        $this->result = array([
            'error' =>      "Az eszköz nincs dolgozóhoz rendelve! (".$this->request['eszkoz_id'].")",
            'Ugyfel_id' =>  'Ismeretlen'
        ]);
    }

    private function _checkID(){
        $isMatch = false;
        foreach ($this->databaseManager->getData() as $value) {
            if($value['Eszkoz_id'] == $this->request['eszkoz_id']){
                $isMatch = true;
                if(!is_null($value['dolgozo_kod']) && $value['dolgozo_kod'] > 0){
                    $this->result = array(['error' => '', 'Ugyfel_id' => $value['Ugyfel_id']], $value);
                }
                else if(!is_null($value['raktar_id'])){
                    $this->result = array(['error' => '', 'raktar_megnevezes' => $value['raktar_megnevezes']], $value);
                }
                break;
            }
        }
        if(!$isMatch) new DatabaseManager(
            $this->sqlCommand->exec_tabletFelvitel(),
            ['eszkoz_id' => $this->request['eszkoz_id']],
            $this->request['customer']
        );
    }
}
/*
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
        $this->_checkID();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->select_tabletLista(),[
            'eszkoz_id' =>      $this->request['eszkoz_id']
        ]);
        $this->result = array([
            'error' =>          "Az eszköz nincs dolgozóhoz rendelve! (".$this->request['eszkoz_id'].")",
            'dolgozo_nev' =>    'Ismeretlen'
        ]);
    }

    private function _checkID(){
        $isMatch = false;
        foreach ($this->databaseManager->getData() as $value) {
            if($value['Eszkoz_id'] == $this->request['eszkoz_id']){
                $isMatch = true;
                if($value['dolgozo_kod'] > 0) $this->result = array(
                    ['error' => '', 'dolgozo_nev' => $value['dolgozo_nev']],
                    $value
                );                
                break;
            }
        }
        if(!$isMatch) new DatabaseManager($this->sqlCommand->exec_tabletFelvitel(), [            
            'eszkoz_id' => $this->request['eszkoz_id']
        ]);
    }
}*/