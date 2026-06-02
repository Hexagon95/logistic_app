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
  List<String> listOfItems =        [];
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
  }

  // ---------- < WidgetBuild [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            case InventoryMState.scanItemsInStorageSuccess:
            case InventoryMState.scanItemsInStorage:  return _drawScanItemsInStorage;
            default:                                  return Container();
          }})()
        ))),
        _drawBottomBar
      ])
    );
  }

  // ---------- < WidgetBuild [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(),
    _drawButtonStorage
  ]));
  
  Widget get _drawScanStorageCode => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(rawData[0]['tarhely_megnevezes'], style: TextStyle(color: Global.getColorOfButton(ButtonState.default0), fontSize: 26, fontWeight: FontWeight.bold)),
    Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.shelves, size: 160, color: Global.getColorOfButton(ButtonState.default0))),
    Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Color.fromARGB(255, 60, 60, 60), borderRadius: BorderRadius.circular(100)),
      child:      Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14))
    )
  ])]);

  Widget get _drawScanItemsInStorage => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(rawData[0]['tarhely_megnevezes'], style: TextStyle(color: Global.getColorOfButton(ButtonState.loading), fontSize: 26, fontWeight: FontWeight.bold)),
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
        Text(listOfItems.length.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
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
    case InventoryMState.scanStorageCodeError:
    case InventoryMState.scanStorageCodeSuccess:
    case InventoryMState.scanStorageCode:     return Global.getColorOfButton(ButtonState.default0);
    // ---------- [scan Item] -- ---------- ---------- ---------- //
    case InventoryMState.scanItemsInStorageDuplicate:
    case InventoryMState.scanItemsInStorageSuccess:
    case InventoryMState.scanItemsInStorage:  return Global.getColorOfButton(ButtonState.loading);
    default: return Colors.transparent;
  }}

  Future buttonStoragePressed() async {if(await Global.yesNoDialog(context, title: 'Következő tárhely: ${rawData[index + 1]['tarhely_megnevezes']}', content: 'Minden Cikket sikerült beolvasni?')){
    setState(() => buttonStorage = ButtonState.loading);
    await DataManager(quickCall: QuickCall.inventoryMezAndMolSave, input: {'parameter': {
      'bizonylat_id': rawData[index]['bizonylat_id'],
      'tarhely_id':   rawData[index]['tarhely_id'],
      'tetelek':      listOfItems.map((e) => {'abroncs_id': e}).toList()
    }}).beginQuickCall;
    listOfItems = [];
    setState(() => inventoryMState = InventoryMState.scanStorageCode);
  }}

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
      bool alreadyContains =  (listOfItems.contains(scanResult));
      setState(() => inventoryMState = (alreadyContains)? InventoryMState.scanItemsInStorageDuplicate : InventoryMState.scanItemsInStorageSuccess);
      if(!alreadyContains) listOfItems.add(scanResult);
      if(inventoryMState == InventoryMState.scanItemsInStorageDuplicate) AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
      await Future.delayed(const Duration(seconds: 1));
      setState(() => inventoryMState = InventoryMState.scanItemsInStorage);
      break;

    default: break;
  }}
}