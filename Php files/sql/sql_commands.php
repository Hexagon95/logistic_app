<?php
class SqlCommand {  // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    public function select_tabletLista(): string                                {return "SELECT * FROM [dbo].[tablet_lista] WHERE [Eszkoz_id] = :eszkoz_id";}
    public function select_kiszedesiLista(): string                             {return "SELECT * FROM [dbo].[Tablet_Kiszedesek] ()";}
    public function select_tabletBevetelezesek(): string                        {return "SELECT * FROM [dbo].[Tablet_Bevetelezesek] ()";}
    public function select_tabletBevetelezesek1(): string                       {return "SELECT * FROM [dbo].[Tablet_Bevetelezesek] (:raktar_id, :user_id)";}
    public function select_tabletKiszallitasok(): string                        {return "SELECT * FROM [dbo].[Tablet_Kiszallitasok] (:raktar_id, :user_id)";}
    public function select_tabletPartnertolVissza(): string                     {return "SELECT * FROM [dbo].[Tablet_PartnertolVissza] (:raktar_id, :user_id)";}
    public function select_tabletHelysziniszereles(): string                    {return "SELECT * FROM [dbo].[Tablet_Helysziniszereles] (:raktar_id, :user_id)";}
    public function select_tabletBejovoszallitolevel(): string                  {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel] (:raktar_id, :user_id)";}
    public function select_rendelesek(): string                                 {return "SELECT * FROM [dbo].[Tablet_Rendelesek] ()";}
    public function select_rendelesek1(): string                                {return "SELECT * FROM [dbo].[Tablet_Rendelesek] (:raktar_id, :user_id)";}
    public function select_tarhely_Id(): string                                 {return "SELECT * FROM [dbo].[Tarhely_id] (:input)";}
    public function select_tarhely_Id1(): string                                {return "SELECT * FROM [dbo].[Tarhely_id] (:raktar_id, :input, :user_id)";}
    public function select_tablet_leltar_tarhelyek(): string                    {return "SELECT * FROM [local].[Tablet_Leltar_tarhelyek] (:raktar_id, :bizonylat_id, :user_id)";}
    public function select_tablet_leltar_bizonylatok(): string                  {return "SELECT * FROM [local].[Tablet_Leltar_bizonylatok] (:raktar_id, :user_id)";}
    public function select_tarhelyKeszlet(): string                             {return "SELECT * FROM [dbo].[Tarhely_keszlet] (0, :tarhely_id, :datum)";}
    public function select_tarhelyKeszletEllenorzes(): string                   {return "SELECT * FROM [dbo].[Tarhely_keszlet_ellenorzes] (:tarhely_id)";}
    public function select_tarhelyKeszletEllenorzes1(): string                  {return "SELECT * FROM [dbo].[Tarhely_keszlet_ellenorzes] (:raktar_id, :tarhely_id, :user_id)";}
    public function select_keszletellenorzesId(): string                        {return "SELECT * FROM [dbo].[Keszletellenorzes_Id] (:code)";}
    public function select_keszletellenorzesId1(): string                       {return "SELECT * FROM [dbo].[Keszletellenorzes_Id] (:raktar_id, :code, :user_id)";}
    public function select_rendelesTetelek(): string                            {return "SELECT * FROM [dbo].[Tablet_Rendeles_tetelek] (:bizonylat_id, :user_id)";}
    public function select_tabletHelysziniszerelesTetelek(): string             {return "SELECT * FROM [dbo].[Tablet_Helysziniszereles_tetelek] (:bizonylat_id, :user_id)";}
    public function select_tabletBejovoszallitolevelTetelek(): string           {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel_tetelek] (:bizonylat_id, :user_id)";}
    public function select_tabletPartnertolVisszaTetelek(): string              {return "SELECT * FROM [dbo].[Tablet_PartnertolVissza_tetelek] (:bizonylat_id, :user_id)";}
    public function select_Tablet_Helysziniszereles_tetelek_uj(): string        {return "SELECT * FROM [dbo].[Tablet_Helysziniszereles_tetelek_uj] (:bizonylat_id, :rendszam, 0, :user_id)";}
    public function select_Tablet_Bejovoszallitolevel_tetelek_uj(): string      {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel_tetelek_uj] (:bizonylat_id, :rendszam, 0, :user_id)";}
    public function select_tabletKiszallitasTetelek(): string                   {return "SELECT * FROM [dbo].[Tablet_Kiszallitas_tetelek] (:bizonylat_id, :user_id)";}
    public function select_tabletBevetelezesTetelek(): string                   {return "SELECT * FROM [dbo].[Tablet_Bevetelezes_tetelek] (:bizonylat_id, :user_id)";}
    public function select_kiszedesTetelek(): string                            {return "SELECT * FROM [dbo].[Tablet_Kiszedes_tetelek] (:bizonylat_id)";}
    public function select_tabletLeltarVan(): string                            {return "SELECT * FROM [dbo].[Tablet_LeltarVan] ()";}
    public function select_tabletHelysziniszerelesUj(): string                  {return "SELECT * FROM [dbo].[Tablet_Helysziniszereles_uj] (:raktar_id, :user_id)";}
    public function select_tabletBejovoszallitolevelUj(): string                {return "SELECT * FROM [dbo].[Tablet_Bejovoszallitolevel_uj] (:raktar_id, :user_id)";}
    public function select_tabletPartnertolVisszaUj(): string                   {return "SELECT * FROM [dbo].[Tablet_PartnertolVissza_uj] (:raktar_id, :user_id)";}
    public function select_tabletCikkInfo(): string                             {return "SELECT * FROM [dbo].[Tablet_Cikk_info] (:id, :raktar_id)";}
    public function select_abroncs_reszletezo(): string                         {return "SELECT * FROM [local].[Abroncs_reszletezo] (:id, :user_id)";}
    public function select_abroncs_reszletezo1(): string                        {return "SELECT * FROM [local].[Abroncs_reszletezo1] (:id, :tarhely_id)";}
    public function select_abroncsReszletezoPoziciokValasztas(): string         {return "SELECT * FROM [local].[Abroncs_reszletezo_poziciok_valasztas] (:id, :user_id)";}
    public function select_abroncsReszletezoPoziciokValasztas1(): string        {return "SELECT * FROM [local].[Abroncs_reszletezo_poziciok_valasztas1] (:id, :user_id)";}
    public function select_verzioLogisticApp(): string                          {return "SELECT [verzio_logistic_app] FROM [dbo].[Parameters]";}
    public function select_vonalkod(): string                                   {return "SELECT [id],[IP],[megnevezes] FROM [local].[Cikk_kereses] (:vonalkod)";}
    public function select_vonalkod_old(): string                               {return "SELECT [id],[IP],[Teljes megnevezés] as megnevezes FROM [dbo].[Torzs_cikk] WHERE [EAN] = :vonalkod";}
    public function select_tabletAbroncsInfo(): string                          {return "SELECT * FROM [dbo].[Tablet_Abroncs_info] (:code)";}
    public function exec_tabletFelhasznaloAdatok(): string                      {return "EXEC [dbo].[Tablet_FelhasznaloAdatok] :eszkoz_id, :user_name, :user_password";}
    public function exec_tabletFelvitel(): string                               {return "EXEC [dbo].[TabletFelvitele] :eszkoz_id";}
    public function exec_finishOrders(): string                                 {return "EXEC [dbo].[Tablet_Rendeles_Felvitele] :completed_orders, :user_id";}
    public function exec_finishOrdersOut(): string                              {return "EXEC [dbo].[Tablet_Bevetelezes_Felvitele] :completed_orders, :user_id";}
    public function exec_tabletKiszallitasFelvitele(): string                   {return "EXEC [dbo].[Tablet_Kiszallitas_Felvitele] :completed_orders, :user_id";}
    public function exec_finishPickUps(): string                                {return "EXEC [dbo].[Tablet_Kiszedes_Felvitele] :kiszedesi_lista, :user_id";}
    public function exec_tabletKiszedesFelviteleTarhely(): string               {return "EXEC [dbo].[Tablet_Rendeles_Felvitele_Tarhely] :kiszedesi_lista, :user_id";}
    public function exec_finishInventory(): string                              {return "EXEC [dbo].[RaktarmozgasFelvitele] :input, :user_id";}
    public function exec_deleteItem(): string                                   {return "EXEC [dbo].[NyitoleltarTorles] :cikk_id, :raktar_id, :user_id";}
    public function exec_bizonylatDataTableDetails(): string                    {return "EXEC [dbo].[Bizonylat_DataTable_Details] :parameter, '', 0, 100, ''";}
    public function exec_bizonylatAlairasFelvitele(): string                    {return "EXEC [dbo].[BizonylatAlairasFelvitele] :parameter";}
    public function exec_bizonylatFuvarlevelszamFelvitele(): string             {return "EXEC [dbo].[BizonylatFuvarlevelszamFelvitele] :parameter";}
    public function exec_keszletmozgatasFelvitele(): string                     {return "EXEC [dbo].[KeszletmozgatasFelvitele] :parameter, :user_id";}
	public function exec_bizonylatDokumentumFelvitele(): string                 {return "EXEC [dbo].[BizonylatDokumentumFelvitele] :parameter, :user_id";}
    public function exec_tabletPartnertolVisszaUjTetelRendszam(): string        {return "EXEC [dbo].[Tablet_PartnertolVissza_uj_tetel_Rendszam] :rendszam, :bizonylat_id, :user_id, :output";}
    public function exec_tabletPartnertolVisszaTetelTorles(): string            {return "EXEC [dbo].[Tablet_PartnertolVissza_tetel_torles] :bizonylat_id, :tetel_id, :output";}
    public function exec_tabletPartnertolVisszaLezaras(): string                {return "EXEC [dbo].[Tablet_PartnertolVissza_lezaras] :bizonylat_id, :user_id, :output";}
	public function exec_tabletBetarolasFelvitele(): string                     {return "EXEC [dbo].[Tablet_Betarolas_Felvitele] :parameter, :user_id, :kimenet";}
    public function exec_tabletHelysziniszerelesUjFelvitele(): string           {return "EXEC [dbo].[Tablet_Helysziniszereles_uj_Felvitele] :parameter, :user_id, :output";}
    public function exec_tabletBejovoszallitolevelUjFelvitele(): string         {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_uj_Felvitele] :parameter, :user_id, :output";}
    public function exec_tabletPartnertolVisszaUjFelvitele(): string            {return "EXEC [dbo].[Tablet_PartnertolVissza_uj_Felvitele] :parameter, :user_id, :output";}
    public function exec_tabletHelysziniszerelesUjTetelFelvitele(): string      {return "EXEC [dbo].[Tablet_Helysziniszereles_uj_tetel_Felvitele] :bizonylat_id, :parameter, :user_id, :output";}
    public function exec_tabletBejovoszallitolevelUjTetelFelvitele(): string    {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_uj_tetel_Felvitele] :bizonylat_id, :parameter, :user_id, :output";}
    public function exec_tabletHelysziniszerelesTetelTorles(): string           {return "EXEC [dbo].[Tablet_Helysziniszereles_tetel_torles] :bizonylat_id, :tetel_id, :output";}
    public function exec_tabletBejovoSzallitolevelTetelTorles(): string         {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_tetel_torles] :bizonylat_id, :tetel_id, :output";}
    public function exec_tabletHelysziniszerelesUjTetelRendszam(): string       {return "EXEC [dbo].[Tablet_Helysziniszereles_uj_tetel_Rendszam] :rendszam, :bizonylat_id, :output";}
    public function exec_tabletBejovoszallitolevelUjTetelRendszam(): string     {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_uj_tetel_Rendszam] :rendszam, :bizonylat_id, :output";}
    public function exec_felhasznaloProfilModositas(): string                   {return "EXEC [dbo].[FelhasznaloProfilModositas] :parameter, :output";}
    public function exec_tabletBejovoszallitolevelLezaras(): string             {return "EXEC [dbo].[Tablet_Bejovoszallitolevel_lezaras] :bizonylat_id, :output";}
    public function exec_tabletHelysziniszerelesLezaras(): string               {return "EXEC [dbo].[Tablet_Helysziniszereles_lezaras] :bizonylat_id, :output";}
    public function exec_tabletBelep(): string                                  {return "EXEC [mosaic].[dbo].[TabletBelep] :eszkoz_id, :verzio";}
    public function exec_barcodePrintCikkek(): string                           {return "EXEC [local].[Barcode_print_cikkek] :raktar_id, :list";}
    public function exec_barcodePrintBizonylatCikkek(): string                  {return "EXEC [local].[Barcode_print_bizonylat_cikkek] :bizonylat_id, :raktar_id, :idk";}
    public function exec_abroncs_reszletezo_felvitele(): string                 {return "EXEC [local].[Abroncs_reszletezo_felvitele_temp] :parameter, :user_id";}
    public function exec_abroncs_reszletezo_felvitele1(): string                {return "EXEC [local].[Abroncs_reszletezo_felvitele_temp1] :parameter, :user_id";}
    public function exec_barcodePrintTarhelyCikkek(): string                    {return "EXEC [local].[Barcode_print_tarhely_cikkek] :tarhely, :idk";}
    public function exec_barcodePrintFelvitele(): string                        {return "EXEC [local].[Barcode_print_Felvitele] :tarhely";}
    public function exec_tabletLeltarTarhelyFelvitele(): string                 {return "EXEC [local].[Tablet_Leltar_tarhely_Felvitele] :parameter, :user_id, :lezart, :output";}
    public function exec_tablet_leltar_kiertekeles(): string                    {return "EXEC [local].[Tablet_Leltar_kiertekeles] :raktar_id, :user_id";}
    public function exec_tablet_leltar_attarolas(): string                      {return "EXEC [local].[Tablet_Leltar_Attarolas] :parameter, :user_id, :output";}
}