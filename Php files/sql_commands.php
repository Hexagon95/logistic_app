<?php
class SqlCommand{
    // ---------- <Variables>  -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $customer = '';

    // ---------- <Constructor> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __Construct(){}

    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_tabletLista()                            {return "SELECT * FROM [dbo].[tablet_lista] WHERE [Eszkoz_id] = :eszkoz_id";}
    public function select_kiszedesiLista()                         {return "SELECT * FROM [dbo].[Tablet_Kiszedesek] ()";}
    public function select_tabletBevetelezesek()                    {return "SELECT * FROM [dbo].[Tablet_Bevetelezesek] ()";}
    public function select_tabletBevetelezesek1()                   {return "SELECT * FROM [dbo].[Tablet_Bevetelezesek] (:raktar_id, :user_id)";}
    public function select_tabletKiszallitasok()                    {return "SELECT * FROM [dbo].[Tablet_Kiszallitasok] (:raktar_id, :user_id)";}
    public function select_tabletBejovoszallitolevel()              {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel] (:raktar_id, :user_id)";}
    public function select_rendelesek()                             {return "SELECT * FROM [dbo].[Tablet_Rendelesek] ()";}
    public function select_rendelesek1()                            {return "SELECT * FROM [dbo].[Tablet_Rendelesek] (:raktar_id, :user_id)";}
    public function select_tarhely_Id()                             {return "SELECT * FROM [dbo].[Tarhely_id] (:input)";}
    public function select_tarhely_Id1()                            {return "SELECT * FROM [dbo].[Tarhely_id] (:raktar_id, :input, :user_id)";}
    public function select_tarhelyKeszlet()                         {return "SELECT * FROM [dbo].[Tarhely_keszlet] (0, :tarhely_id, :datum)";}
    public function select_tarhelyKeszletEllenorzes()               {return "SELECT * FROM [dbo].[Tarhely_keszlet_ellenorzes] (:tarhely_id)";}
    public function select_tarhelyKeszletEllenorzes1()              {return "SELECT * FROM [dbo].[Tarhely_keszlet_ellenorzes] (:raktar_id, :tarhely_id, :user_id)";}
    public function select_keszletellenorzesId()                    {return "SELECT * FROM [dbo].[Keszletellenorzes_Id] (:code)";}
    public function select_keszletellenorzesId1()                   {return "SELECT * FROM [dbo].[Keszletellenorzes_Id] (:raktar_id, :code, :user_id)";}
    public function select_rendelesTetelek()                        {return "SELECT * FROM [dbo].[Tablet_Rendeles_tetelek] (:bizonylat_id, :user_id)";}
    public function select_tabletBejovoszallitolevelTetelek()       {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel_tetelek] (:bizonylat_id, :user_id)";}
    public function select_Tablet_Bejovoszallitolevel_tetelek_uj()  {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel_tetelek_uj] (:bizonylat_id, 0, :user_id)";}
    public function select_tabletKiszallitasTetelek()               {return "SELECT * FROM [dbo].[Tablet_Kiszallitas_tetelek] (:bizonylat_id, :user_id)";}
    public function select_tabletBevetelezesTetelek()               {return "SELECT * FROM [dbo].[Tablet_Bevetelezes_tetelek] (:bizonylat_id, :user_id)";}
    public function select_kiszedesTetelek()                        {return "SELECT * FROM [dbo].[Tablet_Kiszedes_tetelek] (:bizonylat_id)";}
    public function select_tabletLeltarVan()                        {return "SELECT * FROM [dbo].[Tablet_LeltarVan] ()";}
    public function select_tabletBejovoszallitolevelUj()            {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel_uj] (:raktar_id, :user_id)";}
    public function select_tabletCikkInfo()                         {return "SELECT * FROM [dbo].[Tablet_Cikk_info] (:id, :raktar_id)";}
    public function select_abroncs_reszletezo()                     {return "SELECT * FROM [local].[Abroncs_reszletezo] (:id, :user_id)";}
    public function select_abroncs_reszletezo1()                    {return "SELECT * FROM [local].[Abroncs_reszletezo1] (:id, :tarhely_id)";}
    public function select_abroncsReszletezoPoziciokValasztas()     {return "SELECT * FROM [local].[Abroncs_reszletezo_poziciok_valasztas] (:id, :user_id)";}
    public function select_abroncsReszletezoPoziciokValasztas1()    {return "SELECT * FROM [local].[Abroncs_reszletezo_poziciok_valasztas1] (:id, :user_id)";}
    public function select_verzioLogisticApp()                      {return "SELECT [verzio_logistic_app] FROM [dbo].[Parameters]";}
    public function select_vonalkod()                               {return "SELECT [id],[IP],[megnevezes] FROM [local].[Cikk_kereses] (:vonalkod)";}
    public function select_vonalkod_old()                           {return "SELECT [id],[IP],[Teljes megnevezés] as megnevezes FROM [dbo].[Torzs_cikk] WHERE [EAN] = :vonalkod";}
    public function exec_tabletFelhasznaloAdatok()                  {return "EXEC [dbo].[Tablet_FelhasznaloAdatok] :eszkoz_id, :user_name, :user_password";}
    public function exec_tabletFelvitel()                           {return "EXEC [dbo].[TabletFelvitele] :eszkoz_id";}
    public function exec_finishOrders()                             {return "EXEC [dbo].[Tablet_Rendeles_Felvitele] :completed_orders, :user_id";}
    public function exec_finishOrdersOut()                          {return "EXEC [dbo].[Tablet_Bevetelezes_Felvitele] :completed_orders, :user_id";}
    public function exec_tabletKiszallitasFelvitele()               {return "EXEC [dbo].[Tablet_Kiszallitas_Felvitele] :completed_orders, :user_id";}
    public function exec_finishPickUps()                            {return "EXEC [dbo].[Tablet_Kiszedes_Felvitele] :kiszedesi_lista, :user_id";}
    public function exec_tabletKiszedesFelviteleTarhely()           {return "EXEC [dbo].[Tablet_Rendeles_Felvitele_Tarhely] :kiszedesi_lista, :user_id";}
    public function exec_finishInventory()                          {return "EXEC [dbo].[RaktarmozgasFelvitele] :input, :user_id";}
    public function exec_deleteItem()                               {return "EXEC [dbo].[NyitoleltarTorles] :cikk_id, :raktar_id, :user_id";}
    public function exec_bizonylatDataTableDetails()                {return "EXEC [dbo].[Bizonylat_DataTable_Details] :parameter, '', 0, 100, ''";}
    public function exec_bizonylatAlairasFelvitele()                {return "EXEC [dbo].[BizonylatAlairasFelvitele] :parameter";}
    public function exec_bizonylatFuvarlevelszamFelvitele()         {return "EXEC [dbo].[BizonylatFuvarlevelszamFelvitele] :parameter";}
    public function exec_keszletmozgatasFelvitele()                 {return "EXEC [dbo].[KeszletmozgatasFelvitele] :parameter, :user_id";}
	public function exec_bizonylatDokumentumFelvitele()             {return "EXEC [dbo].[BizonylatDokumentumFelvitele] :parameter";}
    public function exec_abroncs_reszletezo_felvitele()             {return "EXEC [local].[Abroncs_reszletezo_felvitele_temp] :parameter";}
    public function exec_abroncs_reszletezo_felvitele1()            {return "EXEC [local].[Abroncs_reszletezo_felvitele_temp1] :parameter";}
    public function exec_barcodePrintTarhelyCikkek()                {return "EXEC [local].[Barcode_print_tarhely_cikkek] :tarhely, :idk";}
    public function exec_barcodePrintFelvitele()                    {return "EXEC [local].[Barcode_print_Felvitele] :tarhely";}
    public function exec_barcodePrintBizonylatCikkek()              {return "EXEC [local].[Barcode_print_bizonylat_cikkek] :bizonylat_id, :raktar_id, '[]'";}
	public function exec_tabletBetarolasFelvitele()                 {return "EXEC [dbo].[Tablet_Betarolas_Felvitele] :parameter, :user_id, :kimenet";}
    public function exec_tabletBejovoszallitolevelUjFelvitele()     {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_uj_Felvitele] :parameter, :user_id, :output";}
    public function exec_tabletBejovoszallitolevelUjTetelFelvitele(){return "EXEC [dbo].[Tablet_Bejovoszallitolevel_uj_tetel_Felvitele] :bizonylat_id, :parameter, :output";}
    public function exec_tabletBejovoSzallitolevelTetelTorles()     {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_tetel_torles] :bizonylat_id, :tetel_id, :output";}
    public function exec_tabletBejovoszallitolevelUjTetelRendszam() {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_uj_tetel_Rendszam] :rendszam, :bizonylat_id, :output";}
    public function exec_felhasznaloProfilModositas()               {return "EXEC [dbo].[FelhasznaloProfilModositas] :parameter, :output";}
    public function exec_tabletBelep()                              {return "EXEC [mosaic].[dbo].[TabletBelep] :eszkoz_id, :verzio";}
}