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
        $date = new DateTime();
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand($this->request['customer']);
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_finishInventory(),
            ['input' => json_encode([
                'id' =>         0,
                'jogcim_id' =>  189,
                'datum' =>      $this->request['datum'],
                'cikk_id' =>    $this->request['cikk_id'],
                'raktar_id' =>  $this->request['raktar_id'],
                'mennyiseg' =>  $this->request['mennyiseg'],
                'megjegyzes'=>  ''
            ])]
        );
        $this->result = $this->databaseManager->getData();
    }
}