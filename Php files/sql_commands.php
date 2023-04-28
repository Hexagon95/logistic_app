<?php
class SqlCommand{
    // ---------- <Variables>  -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $customer = '';

    // ---------- <Constructor> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __Construct($customer = 'mosaic'){$this->customer = $customer;}
    //function __Construct($customer = 'mosaic_test'){$this->customer = $customer;}

    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_tabletLista()                {return "SELECT * FROM [" . $this->customer . "].[dbo].[tablet_lista] WHERE [Eszkoz_id] = :eszkoz_id";}
    public function select_kiszedesiLista()             {return "SELECT * FROM [" . $this->customer . "].[dbo].[Tablet_Kiszedesek] ()";}
    public function select_rendelesek()                 {return "SELECT * FROM [" . $this->customer . "].[dbo].[Tablet_Rendelesek] ()";}
    public function select_tarhelyKeszlet()             {return "SELECT * FROM [" . $this->customer . "].[dbo].[Tarhely_keszlet] (0, :tarhely_id, :datum)";}
    public function select_tarhelyKeszletEllenorzes()   {return "SELECT * FROM [" . $this->customer . "].[dbo].[Tarhely_keszlet_ellenorzes] (:tarhely_id)";}
    public function select_rendelesTetelek()            {return "SELECT * FROM [" . $this->customer . "].[dbo].[Tablet_Rendeles_tetelek] (:bizonylat_id)";}
    public function select_kiszedesTetelek()            {return "SELECT * FROM [" . $this->customer . "].[dbo].[Tablet_Kiszedes_tetelek] (:bizonylat_id)";}
    public function select_vonalkod()                   {return "SELECT [id],[IP],[megnevezes] FROM [" . $this->customer . "].[local].[Cikk_kereses] (:vonalkod)";}
    public function select_vonalkod_old()               {return "SELECT [id],[IP],[Teljes megnevezés] as megnevezes FROM [" . $this->customer . "].[dbo].[Torzs_cikk] WHERE [EAN] = :vonalkod";}
    public function select_tabletLeltarVan()            {return "SELECT * FROM [" . $this->customer . "].[dbo].[Tablet_LeltarVan] ()";}
    public function exec_tabletFelvitel()               {return "EXEC [" . $this->customer . "].[dbo].[TabletFelvitele] :eszkoz_id";}
    public function exec_finishOrders()                 {return "EXEC [" . $this->customer . "].[dbo].[Tablet_Rendeles_Felvitele] :completed_orders";}
    public function exec_finishInventory()              {return "EXEC [" . $this->customer . "].[dbo].[RaktarmozgasFelvitele] :input";}
    public function exec_finishPickUps()                {return "EXEC [" . $this->customer . "].[dbo].[Tablet_Kiszedes_Felvitele] :kiszedesi_lista";}
    public function exec_deleteItem()                   {return "EXEC [" . $this->customer . "].[dbo].[NyitoleltarTorles] :cikk_id, :raktar_id";}
}