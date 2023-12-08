// ignore_for_file: use_build_context_synchronously, recursive_getters

import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/src/scanner_hardware.dart';

class ScanCheckStock extends StatefulWidget{//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScan>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ScanCheckStock({Key? key}) : super(key: key);

  @override
  State<ScanCheckStock> createState() => ScanCheckStockState();
}

class ScanCheckStockState extends State<ScanCheckStock>{  
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScanState>
  static List<dynamic> rawData =    List<dynamic>.empty(growable: true);
  static List<bool> selectionList = List<bool>.empty();
  static dynamic messageData =      {};
  static StockState stockState =    StockState.default0;
  static String storageId =         '';
  static String itemId =            '';
  static int? get selectedIndex {for(int i = 0; i < selectionList.length; i++) {if(selectionList[i]) return i;} return null;}
  //static set selectedIndex(int? value) {if(value == null) return; selectionList[value] = !selectionList[value];}
  static bool storageFromExist =    true;
  static bool storageToExist =      true;
  static Map<String, dynamic>? currentItem;
  static List<dynamic>? barcodeResult;
  static TaskState? taskState;
  static String? result;
 
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  final GlobalKey qrKey =             GlobalKey(debugLabel: 'QR');
  TextStyle formTextStyle =           const TextStyle(fontSize: 14);
  ButtonState buttonPreviousStorage = ButtonState.default0;
  ButtonState buttonNextStorage =     ButtonState.default0;
  ButtonState buttonContinueToForm =  ButtonState.disabled;
  ButtonState buttonPrint =           ButtonState.default0;
  ButtonState buttonAddItem =         ButtonState.default0;
  ButtonState buttonGiveDatas =       ButtonState.disabled;
  bool isProcessIndicator =           false;
  int? _selected; int? get selected => _selected; set selected(int? value) {if(buttonContinueToForm != ButtonState.loading){
    buttonContinueToForm =  (selectionList.contains(true))? ButtonState.default0 : ButtonState.disabled;
    buttonGiveDatas =       (value == null)? ButtonState.disabled : ButtonState.default0;
    _selected =     value;
    setState((){});
  }}
  double? width;
  double? qrScanCutOutSize;
  QRViewController? controller;
  ScannerHardware? scannerHardware;
  ValueNotifier<ScannerDatas>? scannerDatas;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  
  ScanCheckStockState(){
    taskState ??= TaskState.default0;
    if(Global.isScannerDevice){
      scannerDatas =    ValueNotifier(ScannerDatas(dateTime: '', scanData: '', symbology: ''));
      scannerHardware = ScannerHardware(scannerDatas: scannerDatas!, profileName: 'ScanCheckStock');
    }
  }

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {
    if(taskState == TaskState.default0) taskState = TaskState.scanStorage;
    width ??= _setWidth;    
    if(taskState == TaskState.scanProduct || taskState == TaskState.scanStorage){
      if(width != MediaQuery.of(context).size.width) width = _setWidth;
    }    
    return WillPopScope(
      onWillPop:  () => _handlePop,
      child:      (){switch(taskState){
        case TaskState.scanDestinationStorage:
        case TaskState.scanProduct:
        case TaskState.scanStorage:   return _drawQrScanRoute;
        case TaskState.barcodeManual: return _drawBarcodeManual;
        case TaskState.inventory:     return _drawInventory;
        default: return Container();
      }}()      
    );
  }
  
  // ---------- < WidgetBuild [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawQrScanRoute => Scaffold(
    appBar: AppBar(
      title:            Center(child: Text(_getQRCodeScanTitle)),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0)
    ),
    body:   Stack(children: [
      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Expanded(child: _buildQrView),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          _drawBottomBar,
          _drawErrorMessaggeBottomline
        ])
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.end, children:[
        Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 10), child: Container(
          decoration: const BoxDecoration(color: Color.fromARGB(90, 0, 0, 0), borderRadius: BorderRadius.all(Radius.circular(10))),
          child:      _getDrawTask
        )))
      ]),
      Center(child: Visibility(visible: isProcessIndicator, child: _progressIndicator(Colors.lightBlue)))
    ])
  );

  Widget get _drawBarcodeManual => Scaffold(
    appBar: AppBar(
      title:            const Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Vonalkód Manuálisan'))),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
    ),
    backgroundColor:  Colors.white,
    body:             LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _drawBarcodeManualForm,
          _drawBottomBar
        ]);
      }
    )    
  );

  Widget get _drawInventory => Stack(children: [
    Scaffold(
      appBar: AppBar(
        title:            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          (stockState == StockState.checkStock)? _drawButtonPreviousStorage : Container(),
          Text(storageId),
          (stockState == StockState.checkStock)? _drawButtonNextStorage : Container()
        ]),
        backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      ),
      backgroundColor:  Colors.white,
      body:             LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return (rawData.isNotEmpty) 
          ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _drawDataTable,          
            _drawBottomBar
          ]) 
          : const Center(child: Text('Nincs adat'));
        }
      )
    ),
    Padding(padding: const EdgeInsets.fromLTRB(0, 70, 0, 0), child: Container(
      height:     25,
      decoration: BoxDecoration(
        color:        Global.getColorOfButton(ButtonState.default0),
        borderRadius: BorderRadius.circular(10),
        boxShadow:    const[BoxShadow(color: Colors.grey, offset: Offset(5, 5), blurRadius: 5)]
      ),
      child:      Text(' Készlet: ${rawData[0]['tetelek'].length.toString()} ', style: TextStyle(color: Global.getColorOfIcon(ButtonState.default0), fontSize: 16, decoration: TextDecoration.none))
    ))
  ]);

// ---------- < WidgetBuild [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawDataTable => (rawData[0]['tetelek'].isNotEmpty)
  ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child:
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            _generateColumns,
      columnSpacing:      25.0,
      rows:               _generateRows,                
      showCheckboxColumn: false,                
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ))
  : const Expanded(child: Center(child: Text('Üres', style: TextStyle(fontSize: 20))));

  Widget get _buildQrView => (!Global.isScannerDevice)
  ? QRView(
    key:              qrKey,
    onQRViewCreated:  _onQRViewCreated,
    overlay:          QrScannerOverlayShape(
      borderColor:  Global.getColorOfIcon(ButtonState.default0),
      borderRadius: 10,
      borderLength: 30,
      borderWidth:  10,
      cutOutSize:   qrScanCutOutSize!
    ),
    onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
  )
  : Icon(Icons.barcode_reader, size: 200, color: Global.getColorOfButton(ButtonState.default0));

  Widget get _drawBarcodeManualForm => Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(5), child: TextFormField(
    enabled:      true,
    initialValue: '',
    onChanged:    (String? newValue) => setState(() {result = newValue!;}),
    style:        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    textAlign:    TextAlign.center,
  ))));

  Widget get _getDrawTask{ switch(taskState){
    case TaskState.scanStorage:   return _drawTaskScanStorageText;
    case TaskState.scanProduct:   return _drawTaskScanProductText;    
    default:                      return Container();
  }}

  Widget get _drawBottomBar{ switch(taskState){

    case TaskState.scanProduct:
    case TaskState.scanStorage: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          _drawFlash,
          _drawFlipCamera,        
        ]),
        (taskState == TaskState.scanStorage)? _drawButtonBarcodeManual : Container(),
        const SizedBox(height: 1)
      ])
    );
    
    case TaskState.barcodeManual: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [        
        _drawButtonOk
      ])
    );

    case TaskState.inventory: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _drawButtonAddItem,
        _drawButtonPrint,
        _drawButtonContinueToForm
      ])
    );

    case TaskState.itemData: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _drawButtonOk
      ])
    );

    default: return Container();
  }}

  Widget get _drawErrorMessaggeBottomline => Visibility(
    visible:  !DataManager.isServerAvailable,
    child:    Container(height: 20, color: Colors.red, child: Row(
      mainAxisAlignment:  MainAxisAlignment.center,
      children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
    )) 
  ); 

  // ---------- < WidgetBuild [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawTaskScanStorageText => const Padding(padding: EdgeInsets.all(5), child: Center(child: Text(
    'Tárolóhely QR kódjának leolvasása',
    style: TextStyle(color: Colors.white, fontSize: 16),
  )));

  Widget get _drawTaskScanProductText => const Padding(padding: EdgeInsets.all(5), child: Center(child: Text(
    'Kérem olvasson be egy terméket',
    style: TextStyle(color: Colors.white, fontSize: 16),
  )));
  
  // ---------- < WidgetBuild [5] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] >  ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonOk => TextButton(
    onPressed:  () => _buttonOkPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Icon(Icons.check,
      color: Global.getColorOfIcon(ButtonState.default0),
      size: 30,
      )
    )
  );

  Widget get _drawButtonBarcodeManual => Padding(padding: const EdgeInsets.all(5), child: TextButton(
    onPressed:  () => _buttonBarcodeManualPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Icon(Icons.keyboard, color: Global.getColorOfIcon(ButtonState.default0), size: 30)
  ));

  Widget get _drawFlash => (!Global.isScannerDevice)
  ? TextButton(
    onPressed:  () => _toggleFlash,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: FutureBuilder(
      future:     controller?.getFlashStatus(),
      builder:    (context, snapshot) => Icon(
        (snapshot.data.toString() == 'true')? Icons.flash_on : Icons.flash_off,
        color: (snapshot.data.toString() == 'true')
          ? Global.getColorOfIcon(ButtonState.default0)
          : Global.getColorOfIcon(ButtonState.disabled),
        size: 30,
      ),
    ))
  )
  : Container();

  Widget get _drawFlipCamera => (!Global.isScannerDevice)
  ? TextButton(
    onPressed:  () => _flipCamera,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: FutureBuilder(
      future:   controller?.getCameraInfo(),
      builder:  (context, snapshot) => Icon(
        (snapshot.data != null)
          ? (describeEnum(snapshot.data!) == 'back')? Icons.camera_rear : Icons.camera_front
          : Icons.error,
        color:  Global.getColorOfIcon(ButtonState.default0),
        size:   30,
      ),
    ))
  )
  : Container();

  Widget get _drawButtonPreviousStorage => (rawData[0]['elozo_tarhely'].toString().isEmpty)? Container() : TextButton(
    onPressed:  () => (buttonPreviousStorage == ButtonState.default0)? _buttonPreviousStoragePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      Icon(Icons.arrow_back_ios_new, color: Global.getColorOfIcon(buttonPreviousStorage), size: 30),
    ]))
  );

  Widget get _drawButtonNextStorage => (rawData[0]['elozo_tarhely'].toString().isEmpty)? Container() : TextButton(
    onPressed:  () => (buttonNextStorage == ButtonState.default0)? _buttonNextStoragePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      Icon(Icons.arrow_forward_ios, color: Global.getColorOfIcon(buttonNextStorage), size: 30)
    ]))
  );

  Widget get _drawButtonContinueToForm => (stockState == StockState.checkStock)
    ? TextButton(
      onPressed:  () => (buttonContinueToForm == ButtonState.default0)? _buttonContinueToFormPressed : null,
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
        (buttonContinueToForm == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonContinueToForm)) : Container(),
        //Text(' Áru mozgatás ', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonContinueToForm))),
        Icon(Icons.move_down, color: Global.getColorOfIcon(buttonContinueToForm), size: 30)
      ]))
    )
    : Container()
  ;

  Widget get _drawButtonPrint => (stockState == StockState.checkStock)
    ? TextButton(
      onPressed:  () => (buttonPrint == ButtonState.default0)? _buttonPrintPressed : null,
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
        (buttonPrint == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonPrint)) : Container(),
        Icon(Icons.print, color: Global.getColorOfIcon(buttonPrint), size: 30)
      ]))
    )
    : Container()
  ;

  Widget get _drawButtonAddItem => (stockState == StockState.stockIn)
    ? TextButton(
      onPressed:  () => (buttonAddItem == ButtonState.default0)? setState(() => taskState = TaskState.scanProduct) : null,
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
        (buttonAddItem == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonAddItem)) : Container(),
        Text(' Áru hozzáadása ', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonAddItem))),
        Icon(Icons.add_box_outlined, color: Global.getColorOfIcon(buttonAddItem), size: 30)
      ]))
    )
    : _drawButtonGiveDatas
  ;

  Widget get _drawButtonGiveDatas => TextButton(
    onPressed:  () => (buttonGiveDatas == ButtonState.default0)? _buttonGiveDatasPressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonGiveDatas == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonGiveDatas)) : Container(),
      //Text(' Adatok ', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonGiveDatas))),
      Icon(Icons.edit_document, color: Global.getColorOfIcon(buttonGiveDatas), size: 30)
    ]))
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  void initState(){
    super.initState();
    if(Global.isScannerDevice) scannerDatas!.addListener(_triggerScan);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      if(!Global.isScannerDevice) controller!.pauseCamera();
    }
    if(!Global.isScannerDevice) controller!.resumeCamera();
  }
  
  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for(var item in rawData[0]['oszlop']) {columns.add(DataColumn(label: Text(item['text'])));}
    /*columns.add(const DataColumn(label: Text('')));
    for (var item in rawData[0]['tetelek'][0].keys) {switch(item){
      case 'ip':      columns.add(const DataColumn(label: Text('ip')));       break;
      case 'cikknev': columns.add(const DataColumn(label: Text('Cikk név'))); break;
      case 'keszlet': columns.add(const DataColumn(label: Text('Készlet')));  break;
      default:break;
    }}*/
    return columns;
  }

  List<DataRow> get _generateRows{
    bool isHiba(int index) => (rawData[0]['tetelek'][index]['hiba'].toString() == '1');
    int? setSelected(i) {int count = 0; for(bool item in selectionList) {if(item) count++;} return(count == 1)? i : null;}

    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData[0]['tetelek'].length; i++) {if(rawData[0]['tetelek'][i]['ip'].isNotEmpty){
      rows.add(DataRow(
        color: (isHiba(i))
          ? (selected != null && selected == i)
            ? const MaterialStatePropertyAll(Color.fromARGB(20, 255, 0, 100))
            : const MaterialStatePropertyAll(Color.fromARGB(10, 255, 0, 0))
          : null,
        onSelectChanged:  (value) => setState(() {selectionList[i] = value!; selected = setSelected(i);}),
        selected:         (selectionList[i]),
        //selected:         (selected != null && selected == i),
        cells:            _getCells(rawData[0]['tetelek'][i]),
      ));
    }}
    return rows;
  }

  void _onQRViewCreated(QRViewController controller) {    
    if(!Global.isScannerDevice) setState(() => this.controller = controller);    
    controller.scannedDataStream.listen((scanData){      
      result = scanData.code;      
      _checkResult;      
    });
    if(!Global.isScannerDevice) this.controller?.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if(!p) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nincs hozzáférés!')));
  }  

  String get _getQRCodeScanTitle {switch(taskState){
    case TaskState.scanStorage:             return 'Tárolóhely Azonosítása';
    case TaskState.scanDestinationStorage:  return 'Cél Tárolóhely Azonosítása';
    default:                                return 'Termék Azonosítása';
  }}

  double get _setWidth{
    qrScanCutOutSize = (MediaQuery.of(context).size.width <= MediaQuery.of(context).size.height)
    ? MediaQuery.of(context).size.width   * 0.5
    : MediaQuery.of(context).size.height  * 0.5;
    return MediaQuery.of(context).size.width;
  }

  Future get _toggleFlash async{
    try       {await controller?.toggleFlash(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  Future get _flipCamera async{
    try       {await controller?.flipCamera(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  void get _buttonBarcodeManualPressed => setState(() {if(!Global.isScannerDevice) controller!.pauseCamera(); taskState = TaskState.barcodeManual;});

  Future get _buttonContinueToFormPressed async{
    setState(() => buttonContinueToForm = ButtonState.loading);
    Global.routeNext =        NextRoute.dataFormMonetization;
    buttonContinueToForm =    ButtonState.default0;
    if(DataManager.isServerAvailable){
      await Navigator.pushNamed(context, '/dataForm');
    }
    else {setState((){});}
  }

  Future get _buttonPrintPressed async{
    setState(() => buttonPrint = ButtonState.loading);
    if(await Global.yesNoDialog(context,
      title:    'Címkék nyomtatása',
      content:  'Kinyomtat ${rawData[0]['tetelek'].length.toString()}db címkét?'
    )){
      DataManager dataManager = DataManager(quickCall: QuickCall.print);
      await dataManager.beginQuickCall;
    }
    setState(() => buttonPrint = ButtonState.default0);
  }

  Future get _buttonOkPressed async{switch(taskState){

    case TaskState.barcodeManual:
      _checkResult;
      return;

    case TaskState.itemData:
      void insertCurrentItem(){
        for (var i = 0; i < rawData.length; i++){
          if(rawData[i]['cikkszam'].toString() == currentItem!['cikkszam'].toString()) {rawData[i] = currentItem; return;}
        }
      }
      insertCurrentItem();
      DataManager dataManager = DataManager(quickCall: QuickCall.saveInventory);
      await dataManager.beginQuickCall;
      await dataManager.beginProcess;
      setState(() => taskState = TaskState.inventory);
      return;

    default:return;
  }}

  Future get _buttonPreviousStoragePressed async{
    setState(() => buttonPreviousStorage = ButtonState.loading);
    storageId =               rawData[0]['elozo_tarhely'];
    DataManager dataManager = DataManager(quickCall: QuickCall.checkStock);
    await dataManager.beginQuickCall;
    buttonPreviousStorage =   (rawData[0]['elozo_tarhely'].toString().isNotEmpty)?     ButtonState.default0 : ButtonState.disabled;
    buttonNextStorage =       (rawData[0]['kovetkezo_tarhely'].toString().isNotEmpty)? ButtonState.default0 : ButtonState.disabled;
    selected =                null;
    setState((){});
  }

  Future get _buttonNextStoragePressed async{
    setState(() => buttonNextStorage = ButtonState.loading);
    storageId =               rawData[0]['kovetkezo_tarhely'];
    DataManager dataManager = DataManager(quickCall: QuickCall.checkStock);
    await dataManager.beginQuickCall;
    buttonPreviousStorage =   (rawData[0]['elozo_tarhely'].toString().isNotEmpty)?     ButtonState.default0 : ButtonState.disabled;
    buttonNextStorage =       (rawData[0]['kovetkezo_tarhely'].toString().isNotEmpty)? ButtonState.default0 : ButtonState.disabled;
    setState((){});
  }

  Future get _buttonGiveDatasPressed async{
    setState(() => buttonGiveDatas = ButtonState.loading);
    DataManager dataManager = DataManager(quickCall: QuickCall.giveDatas);
    await dataManager.beginQuickCall;
    buttonGiveDatas =         ButtonState.default0;
    if(DataManager.isServerAvailable){
      Global.routeNext = NextRoute.dataFormGiveDatas;
      setState((){});
      await Navigator.pushNamed(context, '/dataForm');
    }
  }

  Future<bool> get _handlePop async{switch(taskState){

    case TaskState.scanDestinationStorage:
      setState(() => taskState = TaskState.inventory);
      return false;
    
    case TaskState.scanProduct:
      setState(() => taskState = TaskState.inventory);
      return false;
    
    case TaskState.inventory: switch(await customDialog(context,
      title:    '$storageId tárolóhely elhagyása?',
      content:  'El kívánja hagyni az agkutális tárolóhelyet: $storageId és szkennelni egy másikat?'
    )){      
      case DialogResult.back:   setState(() => taskState = TaskState.scanStorage);    return false;
      case DialogResult.cancel:                                                       return false;
      default:                  taskState = TaskState.scanStorage; Global.routeBack;  return true;
    }
    
    case TaskState.barcodeManual:
      setState(() => taskState = TaskState.scanStorage);
      return false;

    default:
      if(!Global.isScannerDevice) await controller?.pauseCamera();
      return true;
  }}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future _triggerScan() async{
    List<dynamic> getSelectedItems() {
      List<dynamic> varList = List<dynamic>.empty(growable: true);
      for(int i = 0; i < selectionList.length; i++) {if(selectionList[i]){
        varList.add({
          'cikk_id':    rawData[0]['tetelek'][i]['id'],
          'mennyiseg':  rawData[0]['tetelek'][i]['keszlet']
        });
      }}
      return varList;
    }
    switch(taskState){

      case TaskState.scanStorage:
        DataManager dataManager = DataManager(quickCall: QuickCall.checkStock);
        setState(() => isProcessIndicator = true);
        storageId = scannerDatas!.value.scanData;
        await dataManager.beginQuickCall;
        if(storageFromExist){
          buttonPreviousStorage = (rawData[0]['elozo_tarhely'].toString().isNotEmpty)?     ButtonState.default0 : ButtonState.disabled;
          buttonNextStorage =     (rawData[0]['kovetkezo_tarhely'].toString().isNotEmpty)? ButtonState.default0 : ButtonState.disabled;
          setState(() {isProcessIndicator = false; taskState = TaskState.inventory;});
        }
        else{
          await Global.showAlertDialog(context, content: 'A megadott tárolóhely nem létezik!', title: 'Tárolóhely hiba');
          setState(() {isProcessIndicator = false; taskState = TaskState.scanStorage;});
        }
        break;

        case TaskState.scanDestinationStorage:
          DataManager dataManager = DataManager(
            quickCall:  QuickCall.scanDestinationStorage,
            input:      {
              'storageFrom':  storageId,
              'storageTo':    scannerDatas!.value.scanData,
              'cikkek':       getSelectedItems(),
            }
          );
          if(!Global.isScannerDevice) await controller!.pauseCamera();
          setState((){});
          await dataManager.beginQuickCall;
          if(storageToExist){
            if(!Global.isScannerDevice) controller!.resumeCamera();
            dataManager =           DataManager(quickCall: QuickCall.checkStock);
            storageId =             scannerDatas!.value.scanData;
            await dataManager.beginQuickCall;
            buttonPreviousStorage = (rawData[0]['elozo_tarhely'].toString().isNotEmpty)?     ButtonState.default0 : ButtonState.disabled;
            buttonNextStorage =     (rawData[0]['kovetkezo_tarhely'].toString().isNotEmpty)? ButtonState.default0 : ButtonState.disabled;
            setState(() => taskState = TaskState.inventory);
          }
          else{
            await Global.showAlertDialog(context, content: 'A megadott tárolóhely nem létezik!', title: 'Tárolóhely hiba');
            if(!Global.isScannerDevice) controller!.resumeCamera();
            setState(() => taskState = TaskState.scanDestinationStorage);
          }
          break;

      case TaskState.scanProduct:
        DataManager dataManager = DataManager(quickCall: QuickCall.addItem);
        isProcessIndicator = true;
        itemId = scannerDatas!.value.scanData;
        setState((){});
        await dataManager.beginQuickCall;
        dataManager = DataManager(quickCall: QuickCall.checkStock);
        await dataManager.beginQuickCall;
        setState(() {isProcessIndicator = false; taskState = TaskState.inventory;});
        if(messageData.isNotEmpty) await Global.showAlertDialog(context, title: messageData['title'], content: messageData['content']);
        break;

      default: break;
    }
  }

  List<DataCell> _getCells(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for(var item in rawData[0]['oszlop']) {switch(item['id'].toString()){

      case 'hiba':
        cells.add(DataCell((row['hiba'].toString() == '1')
          ? const Icon(Icons.warning_amber_rounded, color: Colors.red)
          : const Icon(Icons.check,                 color: Colors.green)
        ));
        break;

      default:
        cells.add(DataCell(Text(row[item['id'].toString()].toString())));
        break;
    }}
    /*for (var item in row.keys) {switch(item){
      case 'ip':  
      case 'cikknev':
      case 'keszlet': cells.add(DataCell(Text(row[item].toString())));  break;
      default:break;
    }}*/   
    return cells;
  }

  Future get _checkResult async {switch(taskState){

    case TaskState.scanProduct:
      DataManager dataManager = DataManager(quickCall: QuickCall.addItem);
      if(!Global.isScannerDevice) await controller!.pauseCamera();
      //controller!.stopCamera();
      isProcessIndicator = true;
      itemId = result!;
      setState((){});
      await dataManager.beginQuickCall;
      dataManager = DataManager(quickCall: QuickCall.checkStock);
      await dataManager.beginQuickCall;
      setState(() {isProcessIndicator = false; taskState = TaskState.inventory;});
      if(messageData.isNotEmpty) await Global.showAlertDialog(context, title: messageData['title'], content: messageData['content']);
      break;

    case TaskState.scanStorage:
    case TaskState.barcodeManual:
      DataManager dataManager = DataManager(quickCall: QuickCall.checkStock);
      if(!Global.isScannerDevice) await controller!.pauseCamera(); 
      setState(() => isProcessIndicator = true);
      storageId = result!;             
      await dataManager.beginQuickCall;
      if(storageFromExist){
        buttonPreviousStorage = (rawData[0]['elozo_tarhely'].toString().isNotEmpty)?     ButtonState.default0 : ButtonState.disabled;
        buttonNextStorage =     (rawData[0]['kovetkezo_tarhely'].toString().isNotEmpty)? ButtonState.default0 : ButtonState.disabled;
        setState(() {isProcessIndicator = false; taskState = TaskState.inventory;});
      }
      else{
        await Global.showAlertDialog(context, content: 'A megadott tárolóhely nem létezik!', title: 'Tárolóhely hiba');
        setState(() {isProcessIndicator = false; if(!Global.isScannerDevice) controller!.resumeCamera(); taskState = TaskState.scanStorage;});
      }
      break;

    default:break;
  }}

// ---------- < Dialogs > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<DialogResult> customDialog(BuildContext context, {String title = '', String content = ''}) async{
    Widget back = TextButton(
      child: const Text('Másik Tárolóhely'),
      onPressed: () => Navigator.pop(context, DialogResult.back)
    );

    Widget mainMenu = TextButton(
      child: const Text('Főmenü'),
      onPressed: () => Navigator.pop(context, DialogResult.mainMenu)
    );

    Widget cancel = TextButton(
      child: const Text('Mégsem'),
      onPressed: () => Navigator.pop(context, DialogResult.cancel)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 12)),
      actions:  [back, mainMenu, cancel]
    );

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }
}
