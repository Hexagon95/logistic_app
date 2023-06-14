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
        file_get_contents('https://app.mosaic.hu/pdfgenerator/bizonylat.php?ceg='.$this->request['customer'].'&kategoria_id=3&id='.$this->request['id'].'&save=1');
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand($this->request['customer']);        
        $this->databaseManager =    new DatabaseManager($this->sqlCommand->exec_bizonylatAlairasFelvitele(), [
            'parameter' => json_encode(array(
                'id' =>         $this->request['id'],
                'alairas' =>    $this->request['alairas'],
                'alairo' =>     $this->request['alairo']
            )),
        ]);
        $this->result = $this->databaseManager->getData();
    }
}