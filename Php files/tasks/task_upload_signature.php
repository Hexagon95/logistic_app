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
        $this->request = json_decode(file_get_contents('php://input'), true);
        switch ($this->request['mode']){
            case 'signature':       $this->_executeSignature();     break;
            case 'deliveryNote':    $this->_executeDeliveryNote();  break;
            default:break;
        }
        file_get_contents('https://app.mosaic.hu/pdfgenerator/bizonylat.php?ceg='.$this->request['customer'].'&kategoria_id=3&id='.$this->request['id'].'&save=1');
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _executeSignature(){
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_bizonylatAlairasFelvitele(),
            [
                'parameter' => json_encode(array(
                    'id' =>         $this->request['id'],
                    'alairas' =>    $this->request['alairas'],
                    'alairo' =>     $this->request['alairo']
                ))
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
    }

    private function _executeDeliveryNote(){
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_bizonylatFuvarlevelszamFelvitele(),
            [
                'parameter' => json_encode(array(
                    'id' =>         $this->request['id'],
                    'fuvarlevel' => $this->request['fuvarlevel'],
                )),
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
    }
}