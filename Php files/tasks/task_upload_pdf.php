<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;
	private $konyvtar;
	private $bizonylat_id;
	private $megnevezes;
	private $RootDirectory;
	private $DirectorySeparator; 
	private $pdf;
	private $files;
	
        public function getResult(){return $this->result;}
	
    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($ROOT_DIRECTORY){
        $this->request = json_decode(file_get_contents('php://input'), true);
		$this->konyvtar				=	"documents/".$this->request['customer'];
		$this->bizonylat_id			=	$this->request['id'];
		$this->pdf					=	$this->request['pdf'];
		$this->megnevezes			=	$this->randomString().".pdf";
		$this->RootDirectory		=	$ROOT_DIRECTORY;
		$this->DirectorySeparator	=	DIRECTORY_SEPARATOR; 
		
		$this->files['bizonylat_id'] = $this->bizonylat_id;
		$this->files['TabletPDFUpload'] = 1;
		$this->files['files'] = array();
		array_push($this->files['files'], 
			array(
				"id" => 0,
				"konyvtar" => $this->konyvtar,
				"megnevezes" => $this->megnevezes,
				"name" => "Bizonylat ".time()
			)
		);
		$json_pretty = json_encode($this->files, JSON_PRETTY_PRINT);
		file_put_contents( $this->RootDirectory.$this->DirectorySeparator."logs/files.logs", "\n\r".$json_pretty."\n\r", FILE_APPEND);
    }
	
	function _SaveFile(){
		file_put_contents( $this->RootDirectory.$this->DirectorySeparator."appdoc".$this->DirectorySeparator.$this->konyvtar.$this->DirectorySeparator.$this->megnevezes, base64_decode($this->pdf) );
	}
	
    function _executeBizonylatDokumentumFelvitele(){
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
			$this->sqlCommand->exec_bizonylatDokumentumFelvitele(),
			[
				'parameter' =>	json_encode($this->files, JSON_PRETTY_PRINT),
				'user_id' =>	$this->request['user_id']
			],
			$this->request['customer']
		);
        $this->result = $this->databaseManager->getData();
    }	
	
	private function randomString()
	{
		// Define the result variable
		$str   = '';

		// Generate an array with a-f
		$alpha = range('a', 'f');

		// Get either 25 or 26
		$alphaCount = rand(25, 26);

		// Add a random alpha char to the string 25 or 26 times.
		for ($i = 0; $i < $alphaCount; $i++) {
			$str .= $alpha[array_rand($alpha)];
		}

		// Check how many numbers we need to add
		$numCount = 64 - $alphaCount;

		// Add those numbers to the string
		for ($i = 0; $i < $numCount;  $i++) {
			$str .= rand(0, 9);
		}

		// Randomize the string and return it
		return str_shuffle($str);
	}	
}