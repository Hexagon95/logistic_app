<?php
class Task{
    // ---------- <Variables [public]>  ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public $success;

    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){
        try {
            $this->_inizialite();
            $this->_queryStorages();
            $this->_executeKeszletmozgatasFelvitele();
            $this->success = 1;
        } catch (\Throwable $th) {
            $this->success = 0;
        }
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =    json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand = new SqlCommand($this->request['customer']);
    }

    private function _queryStorages(){
        $this->databaseManager =        new DatabaseManager($this->sqlCommand->select_tarhely_Id(), [
            'input' => $this->request['storageFrom'],
        ]);
        $this->result =                 $this->databaseManager->getData();
        $this->request['storageFrom'] = $this->result[0]['id'];
        $this->databaseManager =        new DatabaseManager($this->sqlCommand->select_tarhely_Id(), [
            'input' => $this->request['storageTo'],
        ]);
        $this->result =                 $this->databaseManager->getData();
        if($this->result[0]['id'] == 0) throw new Exception('invalid_storage_exception');
        $this->request['storageTo'] =   $this->result[0]['id'];
    }

    private function _executeKeszletmozgatasFelvitele(){
        $this->databaseManager = new DatabaseManager($this->sqlCommand->exec_keszletmozgatasFelvitele(), [
            'parameter' => json_encode(array(
                'cikk_id' =>        $this->request['id'],
                'raktar_honnan' =>  $this->request['storageFrom'],
                'raktar_hova' =>    $this->request['storageTo'],
                'mennyiseg' =>      $this->request['amount']
            ))
        ]);
    }
}