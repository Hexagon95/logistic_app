<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $sqlCommand;
    private $sqlQuery;
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
            $this->sqlCommand->exec_tabletBetarolasFelvitele(),
            [
                'parameter' =>  json_encode(array(
                    'tarhely_id' => $this->request['tarhely_id'],
                    'cikk_id' =>    $this->request['cikk_id'],
                    'mennyiseg' =>  $this->request['mennyiseg']
                )),
                'user_id' =>    $this->request['user_id']
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
    }
}
