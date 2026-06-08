// ignore_for_file: use_build_context_synchronously

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/src/scanner_datawedge.dart';

class InventoryMezAndMol extends StatefulWidget {
  const InventoryMezAndMol({super.key});

  @override
  State<InventoryMezAndMol> createState() => InventoryMezAndMolState();
}

class InventoryMezAndMolState extends State<InventoryMezAndMol> {
  // ---------- < Variables [Static] > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> rawData = [];

  // ---------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  // ---------- [simple variables] ----------- ---------- ---------- //  
  ButtonState buttonStorage =       ButtonState.disabled;
  ButtonState buttonSave =          ButtonState.default0;
  List<List<String>> listOfItems =  [];
  ValueNotifier<ScannerDatas>? scannerDatas;
  ScannerDatawedge? scannerDatawedge;
  // ---------- [complex variables] ---------- ---------- ---------- //
  String get message {switch(inventoryMState){
    case InventoryMState.scanStorageCode:             return 'Kérem olvassa be a tárhely QR-kódját!';
    case InventoryMState.scanStorageCodeError:        return '⚠️ Helytelen tárhely!';
    case InventoryMState.scanStorageCodeSuccess:      return '✅ Tárhely azonosítva!';
    case InventoryMState.scanItemsInStorage:          return 'Kérem olvasson be egy cikket a tárhelyen!';
    case InventoryMState.scanItemsInStorageSuccess:   return '✅ Cikk sikeresen beolvasva!';
    case InventoryMState.scanItemsInStorageDuplicate: return '⚠️ Cikk már van beolvasva!';
    case InventoryMState.scanItemsInStorageError:     return '⚠️ A beolvasott kód érvénytelen!';
    default: return '';
  }}
  int _index = 0; int get index => _index; set index(int value){
    if(value < rawData.length) _index = value;
  }
  InventoryMState _inventoryMState = InventoryMState.scanStorageCode; InventoryMState get inventoryMState => _inventoryMState; set inventoryMState(InventoryMState value){
    ButtonState getButtonStateForButtonStorage() {switch(value){
      case InventoryMState.scanItemsInStorage:  return (rawData.length > index + 1)? ButtonState.default0 : ButtonState.disabled;
      default:                                  return ButtonState.disabled;
    }}
    buttonStorage =     getButtonStateForButtonStorage();
    _inventoryMState =  value;
  }
  
  // ---------- < Constructor > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  InventoryMezAndMolState() {
    scannerDatas =      ValueNotifier(ScannerDatas(scanData: ''));
    scannerDatawedge =  ScannerDatawedge(
      scannerDatas: scannerDatas!,
      profileName:  'InventoryMezAndMol'
    );
    listOfItems = List.generate(rawData.length, (_) => []);
  }

  // ---------- < WidgetBuild [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:                 false,
      onPopInvokedWithResult: (didPop, result) async {if(didPop) return; if(await _handlePop()) {if(mounted) {Navigator.pop(context);}}},
      child:                  Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Leltár')),
          backgroundColor: Global.getColorOfButton(ButtonState.default0),
          foregroundColor: Global.getColorOfIcon(ButtonState.default0),
        ),
        body: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Padding(padding: const EdgeInsets.all(10), child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: _getColorBasedOnState, width: 4),
            ),
            child: ((){switch(inventoryMState){
              // ---------- [scan Storage] ---------- ---------- ---------- //
              case InventoryMState.scanStorageCodeError:
              case InventoryMState.scanStorageCodeSuccess:
              case InventoryMState.scanStorageCode:     return _drawScanStorageCode;            
              // ---------- [scan Item] -- ---------- ---------- ---------- //
              case InventoryMState.scanItemsInStorageDuplicate:
              case InventoryMState.scanItemsInStorageError:
              case InventoryMState.scanItemsInStorageSuccess:
              case InventoryMState.scanItemsInStorage:  return _drawScanItemsInStorage;
              default:                                  return Container();
            }})()
          ))),
          _drawBottomBar
        ])
      )
    );
  }

  // ---------- < WidgetBuild [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(),
    (index < rawData.length - 1)? _drawButtonStorage : _drawButtonSave
  ]));
  
  Widget get _drawScanStorageCode => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(rawData[index]['tarhely_megnevezes'], style: TextStyle(color: Global.getColorOfButton(ButtonState.default0), fontSize: 26, fontWeight: FontWeight.bold)),
    Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.shelves, size: 160, color: Global.getColorOfButton(ButtonState.default0))),
    Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Color.fromARGB(255, 60, 60, 60), borderRadius: BorderRadius.circular(100)),
      child:      Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14))
    )
  ])]);

  Widget get _drawScanItemsInStorage => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(rawData[index]['tarhely_megnevezes'], style: TextStyle(color: Global.getColorOfButton(ButtonState.loading), fontSize: 26, fontWeight: FontWeight.bold)),
    Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.qr_code_scanner, size: 160, color: Global.getColorOfButton(ButtonState.loading))),
    Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Color.fromARGB(255, 60, 60, 60), borderRadius: BorderRadius.circular(100)),
      child:      Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14))
    ),
    Padding(padding: const EdgeInsets.all(5), child: Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Color.fromARGB(255, 60, 60, 60), width: 1)),
      child:      Column(children: [
        Text('Leolvasott termékek száma:', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
        Text(listOfItems[index].length.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
      ])
    ))
  ])]);

  // ---------- < WidgetBuild [2] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawButtonStorage => TextButton(
    onPressed:  (buttonStorage == ButtonState.default0)? buttonStoragePressed : null,
    style:      ButtonStyle(foregroundColor: WidgetStatePropertyAll(Global.getColorOfIcon(buttonStorage))),
    child:      Row(children: [
      if(buttonStorage == ButtonState.loading) _progressIndicator,
      Icon(Icons.shelves, size: 36)
    ])
  );

  Widget get _drawButtonSave => TextButton(
    onPressed:  (buttonSave == ButtonState.default0)? buttonSavePressed : null,
    style:      ButtonStyle(foregroundColor: WidgetStatePropertyAll(Global.getColorOfIcon(buttonSave))),
    child:      Row(children: [
      if(buttonSave == ButtonState.loading) _progressIndicator,
      Icon(Icons.save, size: 36)
    ])
  );

  // ---------- < WidgetBuild [3] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _progressIndicator => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: Global.getColorOfIcon(ButtonState.loading))
  ));

  // ---------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  void initState(){
    super.initState();
    scannerDatas!.addListener(_triggerScan);
  }

  Color get _getColorBasedOnState {switch(inventoryMState){
    // ---------- [scan Storage] ---------- ---------- ---------- //
    case InventoryMState.scanStorageCode:
      return Global.getColorOfButton(ButtonState.default0);
    // ---------- [scan Item] -- ---------- ---------- ---------- //
    case InventoryMState.scanItemsInStorage:
      return Global.getColorOfButton(ButtonState.loading);
    // ---------- [Default] ---- ---------- ---------- ---------- //
    default: return Colors.transparent;
  }}

  Future buttonStoragePressed() async {if(await Global.yesNoDialog(context, title: 'Következő tárhely: ${rawData[index + 1]['tarhely_megnevezes']}', content: 'Minden Cikket sikerült beolvasni?')){
    setState(() => buttonStorage = ButtonState.loading);
    index++;
    setState(() => inventoryMState = InventoryMState.scanStorageCode);
  }}

  Future buttonSavePressed() async{
    setState(() => buttonSave = ButtonState.loading);
    bool result = (await Global.yesNoDialog(context, title: 'ℹ️ Leltár folymat befejezése', content: 'Kívánja befejezni a leltár folyamatát és visszalépni a főmenübe?'));
    if(result){
      setState(() => buttonSave = ButtonState.loading);
      List<Map<String, dynamic>> parameter = [];
      for(int i = 0; i <= index; i++){
        parameter.add({
          'bizonylat_id': rawData[i]['bizonylat_id'],
          'tarhely_id':   rawData[i]['tarhely_id'],
          'tetelek':      listOfItems[i].map((e) => {'abroncs_id': e}).toList()
        });
      }
      await DataManager(quickCall: QuickCall.inventoryMezAndMolSave, input: {'parameter': parameter}).beginQuickCall;
      if(mounted) Navigator.pop(context);
    }
    if(mounted) setState(() => buttonSave = ButtonState.default0);
  }

  Future<bool> _handlePop() async {
    bool result = (await Global.yesNoDialog(context, title: 'ℹ️ Leltár folymat félbeszakítása', content: 'Kívánja félbeszakítani a leltár folyamatát és visszalépni a főmenübe?\n\n💾 Az idáig beolvasott adatok elmentésre kerülnek.'));
    if(result){
      List<Map<String, dynamic>> parameter = [];
      for(int i = 0; i <= index; i++){
        parameter.add({
          'bizonylat_id': rawData[i]['bizonylat_id'],
          'tarhely_id':   rawData[i]['tarhely_id'],
          'tetelek':      listOfItems[i].map((e) => {'abroncs_id': e}).toList()
        });
      }
      await DataManager(quickCall: QuickCall.inventoryMezAndMolSave, input: {'parameter': parameter}).beginQuickCall;
    }
    return result;
  }

  @override
  void dispose() {
    scannerDatas?.removeListener(_triggerScan);
    scannerDatas?.dispose();
    super.dispose();
  }

  // ---------- < Methods [2] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future<void> _triggerScan() async {switch(inventoryMState){
    case InventoryMState.scanStorageCode:
      String scanResult = scannerDatas!.value.scanData.trim();
      setState(() => inventoryMState = (rawData[index]['barcode'].toString() == scanResult)? InventoryMState.scanStorageCodeSuccess : InventoryMState.scanStorageCodeError);
      if(inventoryMState == InventoryMState.scanStorageCodeError) AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
      await Future.delayed(const Duration(seconds: 1));
      setState(() => inventoryMState = (inventoryMState == InventoryMState.scanStorageCodeSuccess)? InventoryMState.scanItemsInStorage : InventoryMState.scanStorageCode);
      break;

    case InventoryMState.scanItemsInStorage:
      String scanResult =     scannerDatas!.value.scanData.trim();
      if(!RegExp(r'^\d+$').hasMatch(scanResult)){
        setState(() => inventoryMState = InventoryMState.scanItemsInStorageError);
        AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
        await Future.delayed(const Duration(seconds: 1));
        setState(() => inventoryMState = InventoryMState.scanItemsInStorage);
        return; 
      }
      bool alreadyContains =  (listOfItems[index].contains(scanResult));
      setState(() => inventoryMState = (alreadyContains)? InventoryMState.scanItemsInStorageDuplicate : InventoryMState.scanItemsInStorageSuccess);
      if(!alreadyContains) listOfItems[index].add(scanResult);
      if(inventoryMState == InventoryMState.scanItemsInStorageDuplicate) AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
      await Future.delayed(const Duration(seconds: 1));
      setState(() => inventoryMState = InventoryMState.scanItemsInStorage);
      break;

    default: break;
  }}
}