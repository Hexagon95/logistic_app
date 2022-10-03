// ignore_for_file: use_build_context_synchronously, recursive_getters

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:logistic_app/global.dart';

class ScanOrders extends StatefulWidget{//---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScan>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ScanOrders({Key? key}) : super(key: key);

  @override
  State<ScanOrders> createState() => ScanOrdersState();
}

class ScanOrdersState extends State<ScanOrders>{  
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScanState>
  static List<dynamic> rawData =      List<dynamic>.empty(growable: true);
  static List<bool> progressOfTasks = List<bool>.empty(growable: true);
  static int? currentTask;
 
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  TaskState _taskState = TaskState.default0;
  TaskState get taskState => _taskState; set taskState(TaskState value){_taskState = value; switch(value){

    case TaskState.scanProduct:
      buttonNoBarcode =       ButtonState.default0;
      buttonSkip =            ButtonState.default0;
      buttonOkHandleProduct = ButtonState.hidden;      
      break;

    case TaskState.handleProduct:
      buttonOkHandleProduct = ButtonState.default0;
      buttonSkip =            ButtonState.default0;
      buttonNoBarcode =       ButtonState.hidden;      
      break;

    default:
      buttonNoBarcode =       ButtonState.hidden;
      buttonOkHandleProduct = ButtonState.hidden;
      buttonSkip =            ButtonState.hidden;
      break;
  }}
  ButtonState buttonAskOk =           ButtonState.default0;
  ButtonState buttonNoBarcode =       ButtonState.hidden;
  ButtonState buttonOkHandleProduct = ButtonState.hidden;
  ButtonState buttonSkip =            ButtonState.hidden;
  bool isProgressIndicator =          false;
  bool isAskScanProductOpen =         false;
  final GlobalKey qrKey =             GlobalKey(debugLabel: 'QR');
  double? width;
  double? qrScanCutOutSize;
  String? result;
  QRViewController? controller;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  
  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override  
  Widget build(BuildContext context) {
    if(currentTask != null) {if(taskState == TaskState.default0) taskState = TaskState.askStorage;}
    else {_endTask;}
    width ??= _setWidth;    
    if(taskState == TaskState.scanProduct || taskState == TaskState.scanStorage){
      if(width != MediaQuery.of(context).size.width) width = _setWidth;
    }
    return WillPopScope(
      onWillPop:  () => _handlePop,
      child:      (Global.currentRoute == NextRoute.scanTasks)
      ? (){switch(taskState){
        case TaskState.askStorage:
        case TaskState.askProduct:  return _drawAskStorageOrProduct;
        default:                    return _drawQrScanRoute;
      }}()
      : _drawWaitingForFinishTask
    );
  }
  
  // ---------- < WidgetBuild [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawAskStorageOrProduct{
    String order = (taskState == TaskState.askStorage)
    ? 'A(z) ${rawData[currentTask!]['tarhely']} számú tárjhely QR kódjának leolvasása.'
    : 'A(z) ${rawData[currentTask!]['cikkszam']} cikkszámú termék vonalkódjának leolvasása.';
    return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(order, style: const TextStyle(fontSize: 16)),
        _drawButtonAskOk
      ])),
      _drawErrorMessaggeBottomline
    ])));
  }
  

  Widget get _drawQrScanRoute => Scaffold(
    body: Stack(children: [
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
    ])
  );

  Widget get _drawWaitingForFinishTask => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [_progressIndicator(Colors.lightBlue)])),
    _drawErrorMessaggeBottomline
  ])));

// ---------- < WidgetBuild [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _buildQrView => QRView(
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
  );

  Widget get _getDrawTask{ switch(taskState){
    case TaskState.scanStorage:   return _drawTaskScanStorageText;
    case TaskState.scanProduct:   return _drawTaskScanProductText;
    case TaskState.handleProduct: return _drawTaskHandleProductText;
    default:                      return Container();
  }}

  Widget get _drawBottomBar{ switch(taskState){

    case TaskState.scanStorage: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        _drawFlash,
        _drawFlipCamera
      ])
    );

    case TaskState.scanProduct: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          _drawFlash,
          _drawFlipCamera,        
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _drawSkip,
          _drawNoBarcode
        ])
      ])
    );

    case TaskState.handleProduct: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _drawSkip,
        _drawOkHandleProduct
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
  Widget get _drawTaskScanStorageText => Padding(padding: const EdgeInsets.all(5), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(
      'Kérem olvassa be a(z) ${rawData[currentTask!]['tarhely']} számú tárjhely QR kódját.',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: (result != null)      
      ? (result! == rawData[currentTask!]['tarhely'])
        ? [
          const Icon(Icons.check_circle_outline, color: Color.fromARGB(200, 100, 255, 100), size: 30),
          const SizedBox(width: 10),
          const Text('Betöltés  ', style: TextStyle(color: Color.fromARGB(200, 100, 255, 100), fontSize: 16)),
          _progressIndicator(const Color.fromARGB(200, 100, 255, 100))
        ]
        : [
          (isProgressIndicator)? _progressIndicator(Colors.lightBlue) : Container(),
          const Icon(Icons.error_outline, color: Color.fromARGB(200, 255, 150, 0), size: 30),
          const SizedBox(width: 10),          
          const Text('Nem megfelelő QR kód!', style: TextStyle(color: Color.fromARGB(200, 255, 150, 0), fontSize: 16)),
        ]      
      : []
    )
  ]));

  Widget get _drawTaskScanProductText => Padding(padding: const EdgeInsets.all(5), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(
      'Kérem olvassa be a(z) ${rawData[currentTask!]['cikkszam']} cikkszámú termék vonalkódját.',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: (result != null)      
      ? (result! == rawData[currentTask!]['cikk_id'] || result! == rawData[currentTask!]['cikkszam'])
        ? [
          const Icon(Icons.check_circle_outline, color: Color.fromARGB(200, 100, 255, 100), size: 30),
          const SizedBox(width: 10),
          const Text('Betöltés  ', style: TextStyle(color: Color.fromARGB(200, 100, 255, 100), fontSize: 16)),
          _progressIndicator(const Color.fromARGB(200, 100, 255, 100))
        ]
        : [
          (isProgressIndicator)? _progressIndicator(Colors.lightBlue) : Container(),
          const Icon(Icons.error_outline, color: Color.fromARGB(200, 255, 150, 0), size: 30),
          const SizedBox(width: 10),          
          const Text('Nem megfelelő vonalkód!', style: TextStyle(color: Color.fromARGB(200, 255, 150, 0), fontSize: 16)),
        ]      
      : []
    )
  ]));

  Widget get _drawTaskHandleProductText => Padding(padding: const EdgeInsets.all(5), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(
      'Helyezzen ${rawData[currentTask!]['mennyiseg']}db ${rawData[currentTask!]['cikkszam']} cikkszámú terméket a gyűjtőterületre.',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
  ]));
  
  // ---------- < WidgetBuild [5] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] >  ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonAskOk => Padding(
    padding:  const EdgeInsets.fromLTRB(20, 40, 20, 40),
    child:    SizedBox(height: 40, width: 100, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonAskOk))),
      onPressed:  (buttonAskOk == ButtonState.default0)? () => _buttonAskOkPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonAskOk == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonAskOk))))
        ),
        Text((buttonAskOk == ButtonState.loading)? 'Betöltés...' : 'Ok', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonAskOk)))
      ])
    ))
  );

  Widget get _drawFlash => TextButton(
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
  );

  Widget get _drawFlipCamera => TextButton(
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
  );
  
  Widget get _drawSkip => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(height: 40, child: TextButton(          
    style:      TextButton.styleFrom(
      foregroundColor:  Global.getColorOfButton(buttonSkip),
      side:             BorderSide(color: Global.getColorOfIcon(ButtonState.loading), width: 1)
    ),
    onPressed:  (buttonSkip == ButtonState.default0)? () => _skipToNextTask : null,          
    child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible:  (buttonSkip == ButtonState.loading)? true : false,
        child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading)))
      ),
      Text((buttonSkip == ButtonState.loading)? 'Betöltés...' : 'Kihagyás', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonSkip)))
    ])
  )));

  Widget get _drawNoBarcode => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(height: 40, child: TextButton(          
    style:      TextButton.styleFrom(
      foregroundColor:  Global.getColorOfButton(buttonNoBarcode),
      side:             BorderSide(color: Global.getColorOfIcon(ButtonState.loading), width: 1)
    ),
    onPressed:  (buttonNoBarcode == ButtonState.default0)? () => _goToHandleProduct : null,          
    child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible:  (buttonNoBarcode == ButtonState.loading)? true : false,
        child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading)))
      ),
      Text((buttonNoBarcode == ButtonState.loading)? 'Betöltés...' : 'Nincs vonalkód', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonNoBarcode)))
    ])
  )));

  Widget get _drawOkHandleProduct => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(height: 40, child: TextButton(          
    style:      TextButton.styleFrom(
      foregroundColor:  Global.getColorOfButton(buttonOkHandleProduct),
      side:             BorderSide(color: Global.getColorOfIcon(ButtonState.loading), width: 1)
    ),
    onPressed:  (buttonOkHandleProduct == ButtonState.default0)? () => _goToNextTask : null,          
    child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible:  (buttonOkHandleProduct == ButtonState.loading)? true : false,
        child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading)))
      ),
      Text((buttonOkHandleProduct == ButtonState.loading)? 'Betöltés...' : 'Ok', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonOkHandleProduct)))
    ])
  )));

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }
  
  void _onQRViewCreated(QRViewController controller) {    
    setState(() => this.controller = controller);    
    controller.scannedDataStream.listen((scanData){
      if(isProgressIndicator || buttonNoBarcode == ButtonState.loading) return;      
      setState(() => isProgressIndicator = true);
      result = scanData.code;      
      _checkResult;
      if(isProgressIndicator) Future.delayed(const Duration(milliseconds: 500), () => setState(() => isProgressIndicator = false));      
    });
    this.controller?.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if(!p) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nincs hozzáférés!')));
  }

  Future<bool> get _handlePop async{
    controller?.stopCamera();
    if (await Global.yesNoDialog(context,
      title:    'Munka elvetése?',
      content:  'El kívánja vetni az idáigi munkát és visszatér a rendelésekhez?'
    )){
      String varString = '';
      for (var i = 0; i < progressOfTasks.length; i++){
        if(progressOfTasks[i]) varString += '${rawData[i]['cikkszam']}\tMennyiség: ${rawData[i]['mennyiseg']}\tTárhely: ${rawData[i]['tarhely']}\n';
      }
      if(varString.isEmpty) {return true;}
      else{
        return await Global.showAlertDialog( context,
          title:    'Termékek visszahelyezése',
          content:  'Kérem helyezze vissza az alábbi termékeket a helyükre:\n$varString'
        );  
      }
    }
    else {
      setState((){});
      return false;
    }
  }

  double get _setWidth{
    qrScanCutOutSize = (MediaQuery.of(context).size.width <= MediaQuery.of(context).size.height)
    ? MediaQuery.of(context).size.width   * 0.5
    : MediaQuery.of(context).size.height  * 0.5;
    return MediaQuery.of(context).size.width;
  }

  void get _buttonAskOkPressed => setState(() => taskState = (taskState == TaskState.askStorage)? TaskState.scanStorage : TaskState.scanProduct);

  Future get _toggleFlash async{
    try       {await controller?.toggleFlash(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  Future get _flipCamera async{
    try       {await controller?.flipCamera(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  void get _goToHandleProduct{    
    setState((){controller?.stopCamera(); taskState = TaskState.handleProduct;});
  }

  void get _goToNextTask{    
    progressOfTasks[currentTask!] = true;
    currentTask = (currentTask! < rawData.length - 1)? currentTask! + 1 : null;
    setState(() => taskState = TaskState.askStorage);
  }

  Future get _skipToNextTask async{
    if(!await Global.yesNoDialog( context,
      title:    'Kihagyás?',
      content:  'Biztosan kihagyja a ${rawData[currentTask!]['cikkszam']} cikkszámú terméket?'
    )) return;
    progressOfTasks[currentTask!] = false;
    currentTask = (currentTask! < rawData.length - 1)? currentTask! + 1 : null;
    setState(() => taskState = TaskState.askStorage);
  }

  Future get _endTask async{
    controller =              null;
    Global.routeNext =        NextRoute.finishTasks;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    if(DataManager.isServerAvailable){
      Global.routeNext = NextRoute.listOrders;
      dataManager.beginProcess;
      Navigator.popUntil(context, ModalRoute.withName('/listOrders'));
      await Navigator.pushReplacementNamed(context, '/listOrders');
    }
    else {setState((){}); Future.delayed(const Duration(seconds: 5), () => _endTask);}
  }


  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  void get _checkResult{switch(taskState){

    case TaskState.scanStorage:
      if(result != null && result == rawData[currentTask!]['tarhely']){        
        Future.delayed(const Duration(milliseconds: 500), () => setState(() => isProgressIndicator = false));
        Future.delayed(const Duration(seconds: 1), () => setState(() {controller?.stopCamera(); result = null; taskState = TaskState.askProduct;}));
      }
      break;
    
    case TaskState.scanProduct:
      if(result != null && (result == rawData[currentTask!]['cikk_id'] || result == rawData[currentTask!]['cikkszam'])){        
        Future.delayed(const Duration(milliseconds: 500), () => setState(() => isProgressIndicator = false));
        Future.delayed(const Duration(seconds: 1), () {result = null; _goToHandleProduct;});        
      }
      break;

    default:break;
  }}  
}