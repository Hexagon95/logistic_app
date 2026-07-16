// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logistic_app/src/scanner_datawedge.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';

class Evaluate{
  late ButtonState info;
  late ButtonState print;
  late ButtonState missing;
  Evaluate({required this.info, required this.print, required this.missing});
}

class InventoryMezAndMol extends StatefulWidget {
  const InventoryMezAndMol({super.key});

  @override
  State<InventoryMezAndMol> createState() => InventoryMezAndMolState();
}

class InventoryMezAndMolState extends State<InventoryMezAndMol> {
  // ---------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //

    // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    static List<dynamic> rawData =          [];
    static List<dynamic> listBizonylatok =  [];
    static List<dynamic> listEvaluate =     [];

    // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    ButtonState buttonStorage =         ButtonState.disabled;
    ButtonState buttonContinue =        ButtonState.disabled;
    ButtonState buttonEvaluate =        ButtonState.default0;
    ButtonState buttonSave =            ButtonState.default0;
    List<List<dynamic>> listOfItems =   [];
    ValueNotifier<ScannerDatas>? scannerDatas;
    ScannerDatawedge? scannerDatawedge;
    int? selectedBizonylat;

    // ---------- [💎 complex variables] -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    InventoryMState _inventoryMState = InventoryMState.inventoryPick; InventoryMState get inventoryMState => _inventoryMState; set inventoryMState(InventoryMState value){
      ButtonState getButtonStateForButtonStorage() {switch(value){
        case InventoryMState.scanItemsInStorage:  return (rawData.length > index + 1)? ButtonState.default0 : ButtonState.disabled;
        default:                                  return ButtonState.disabled;
      }}
      buttonStorage =     getButtonStateForButtonStorage();
      _inventoryMState =  value;
    }
    String _message = ''; set message(String value) => _message = value; String get message {if(_message.isNotEmpty) {return _message;} switch(inventoryMState){
      case InventoryMState.scanStorageCode:             return 'Kérem olvassa be a tárhely QR-kódját!';
      case InventoryMState.scanItemsInStorage:          return 'Kérem olvasson be egy cikket a tárhelyen!';
      default: return '';
    }}
    int _index = 0; int get index => _index; set index(int value){
      if(value < rawData.length) _index = value;
    }
    Evaluate evaluateButton = Evaluate(
      info:     ButtonState.default0,
      missing:  ButtonState.default0,
      print:    ButtonState.default0
    );
    Color get colorBasedOnState {switch(inventoryMState){
      case InventoryMState.scanStorageCode:     return Global.getColorOfButton(ButtonState.default0);
      case InventoryMState.scanItemsInStorage:  return Global.getColorOfButton(ButtonState.loading);
      default:                                  return Colors.transparent;
    }}
  
  // ---------- < Constructor > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  InventoryMezAndMolState() {
    //if(rawData.isEmpty) _inventoryMState = InventoryMState.empty;
    scannerDatas =      ValueNotifier(ScannerDatas(scanData: ''));
    scannerDatawedge =  ScannerDatawedge(
      scannerDatas: scannerDatas!,
      profileName:  'InventoryMezAndMol'
    );
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
        body: GestureDetector(
          onTap: _unselect,
          child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Padding(padding: const EdgeInsets.all(10), child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: colorBasedOnState, width: 4),
              ),
              child: ((){switch(inventoryMState){
                case InventoryMState.scanStorageCode:     return _drawScanStorageCode;            
                case InventoryMState.scanItemsInStorage:  return _drawScanItemsInStorage;
                case InventoryMState.inventoryPick:       return _drawListBizonylatok;
                case InventoryMState.evaluate:            return _drawEvaluate;
                case InventoryMState.empty:               return _drawEmpty;
                default:                                  return Container();
              }})()
            ))),
            _drawBottomBar
          ])
        )
      )
    );
  }

  // ---------- < WidgetBuild [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: (() {switch(inventoryMState){
    case InventoryMState.inventoryPick: return <Widget>[_drawButtonEvaluate, Container(), _drawButtonContinue];
    case InventoryMState.evaluate:      return <Widget>[_drawButtonInfo, _drawButtonPrint, _drawButtonMissing];
    case InventoryMState.empty:         return <Widget>[];
    default:                            return <Widget>[Container(), (index < rawData.length - 1)? _drawButtonStorage : _drawButtonSave];
  }})()));
  
  Widget get _drawScanStorageCode => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(rawData[index]['tarhely_megnevezes'], style: TextStyle(color: Global.getColorOfButton(ButtonState.default0), fontSize: 26, fontWeight: FontWeight.bold)),
    Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.shelves, size: 160, color: Global.getColorOfButton(ButtonState.default0))),
    Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Color.fromARGB(255, 60, 60, 60), borderRadius: BorderRadius.circular(20)),
      child:      Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14))
    )
  ])]);

  Widget get _drawScanItemsInStorage => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(rawData[index]['tarhely_megnevezes'], style: TextStyle(color: Global.getColorOfButton(ButtonState.loading), fontSize: 26, fontWeight: FontWeight.bold)),
    Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.qr_code_scanner, size: 160, color: Global.getColorOfButton(ButtonState.loading))),
    Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Color.fromARGB(255, 60, 60, 60), borderRadius: BorderRadius.circular(20)),
      child:      Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14))
    ),
    Padding(padding: const EdgeInsets.all(5), child: Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Color.fromARGB(255, 60, 60, 60), width: 1)),
      child:      Column(children: [
        Text('Leolvasott termékek száma:', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
        Text((listOfItems.isNotEmpty)? listOfItems[index].length.toString() : '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
      ])
    ))
  ])]);

  Widget get _drawListBizonylatok => ListView.builder(
    itemCount:    listBizonylatok.length,
    itemBuilder:  (context, index) {
      bool isSelected = (selectedBizonylat == index);
      return Card(color: isSelected? Global.getColorOfButton(ButtonState.default0) : null, child: ListTile(
        leading:  Icon(Icons.description, color: isSelected? Global.getColorOfIcon(ButtonState.default0) : null),
        title:    Text(listBizonylatok[index]['sorszam'].toString(), style: TextStyle(color: isSelected? Global.getColorOfIcon(ButtonState.default0) : null, fontWeight: FontWeight.bold)),
        subtitle: Text(listBizonylatok[index]['tarhely'].toString(), style: TextStyle(color: isSelected? Global.getColorOfIcon(ButtonState.default0) : null)),
        trailing: isSelected? Icon(Icons.check_circle, color: Global.getColorOfIcon(ButtonState.default0)) : null,
        onTap:    () => _onBizonylatSelected(index)
      ));
    },
  );

  Widget get _drawEvaluate {
    if (listEvaluate.isEmpty) {
      return const Center(
        child: Text(
          'Nincs megjeleníthető kiértékelés.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    final item =            listEvaluate.first;
    Widget storageDisplay({
      required String title,
      required dynamic value,
      required IconData icon,
      required Color primaryColor,
      required TextStyle textStyle
    }) {
      final text = value?.toString() ?? '';
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: primaryColor.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 34, color: primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign:  TextAlign.center,
                style:      const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Text(
                text.isEmpty ? '—' : text,
                textAlign:  TextAlign.center,
                style:      textStyle,
              ),
            ],
          ),
        ),
      );
    }
    Widget informationBlock({
      required String title,
      required dynamic value,
      required IconData icon,
      required Color primaryColor,
    }) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.black54)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value?.toString() ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.black)
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 170,
                child:  Row(
                  children: [
                    storageDisplay(
                      title:        'Tárhely\nnyilvántartás szerint',
                      value:        item['tarhely1'],
                      icon:         Icons.inventory_2_outlined,
                      primaryColor: (item['tarhely1'].isNotEmpty)? Global.getColorOfButton(ButtonState.default0) : Colors.grey,
                      textStyle:    const TextStyle(fontSize: 14, color: Colors.black)
                    ),
                    const SizedBox(width: 12),
                    storageDisplay(
                      title:        'Tárhely\nleltár szerint',
                      value:        item['tarhely2'],
                      icon:         Icons.qr_code_scanner,
                      primaryColor: (item['tarhely2'].isNotEmpty)? Global.getColorOfButton(ButtonState.default0) : Colors.grey,
                      textStyle:    const TextStyle(fontSize: 14, color: Colors.black)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              informationBlock(
                title: 'Abroncs azonosító',
                value: item['abroncs_azonosíto'],
                icon: Icons.tire_repair,
                primaryColor: Global.getColorOfButton(ButtonState.default0),
              ),
              const SizedBox(height: 10),
              informationBlock(
                title: 'Megjegyzés',
                value: item['statusz'],
                icon: Icons.info_outline,
                primaryColor: Global.getColorOfButton(ButtonState.default0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _drawEmpty => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.done, size: 260, color: Global.getColorOfButton(ButtonState.disabled))),
    Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Color.fromARGB(255, 60, 60, 60), borderRadius: BorderRadius.circular(20)),
      child:      Text('✅ Nincs leltározási feladat!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14))
    )
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

  Widget get _drawButtonEvaluate => TextButton(
    onPressed:  (buttonEvaluate == ButtonState.default0)? buttonEvaluatePressed : null,
    style:      ButtonStyle(foregroundColor: WidgetStatePropertyAll(Global.getColorOfIcon(buttonEvaluate))),
    child:      Row(children: [
      if(buttonEvaluate == ButtonState.loading) _progressIndicator,
      Icon(Icons.list_alt, size: 36),
      Text(' Kiértékelés', style: TextStyle(fontSize: 16))
    ])
  );

  Widget get _drawButtonInfo => TextButton(
    onPressed:  (evaluateButton.info == ButtonState.default0)? buttonInfoPressed : null,
    style:      ButtonStyle(foregroundColor: WidgetStatePropertyAll(Global.getColorOfIcon(evaluateButton.info))),
    child:      Row(children: [
      if(evaluateButton.info == ButtonState.loading) _progressIndicator,
      Icon(Icons.info, size: 36)
    ])
  );

  Widget get _drawButtonPrint => TextButton(
    onPressed:  (evaluateButton.print == ButtonState.default0)? buttonPrintPressed : null,
    style:      ButtonStyle(foregroundColor: WidgetStatePropertyAll(Global.getColorOfIcon(evaluateButton.print))),
    child:      Row(children: [
      if(evaluateButton.print == ButtonState.loading) _progressIndicator,
      Icon(Icons.print, size: 36)
    ])
  );

  Widget get _drawButtonMissing => TextButton(
    onPressed:  (evaluateButton.missing == ButtonState.default0)? ButtonMissingPressed : null,
    style:      ButtonStyle(foregroundColor: WidgetStatePropertyAll(Global.getColorOfIcon(evaluateButton.missing))),
    child:      Row(children: [
      if(evaluateButton.missing == ButtonState.loading) _progressIndicator,
      Icon(Icons.cancel, size: 36)
    ])
  );

  Widget get _drawButtonContinue => TextButton(
    onPressed:  (buttonContinue == ButtonState.default0)? buttonContinuePressed : null,
    style:      ButtonStyle(foregroundColor: WidgetStatePropertyAll(Global.getColorOfIcon(buttonContinue))),
    child:      Row(children: [
      if(buttonContinue == ButtonState.loading) _progressIndicator,
      Icon(Icons.arrow_forward, size: 36)
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
  void _onBizonylatSelected(int index) => (buttonContinue == ButtonState.disabled)? setState(() {selectedBizonylat = index; buttonContinue = ButtonState.default0;}) : null;
  void _initListOfIems() => listOfItems = List.generate(rawData.length, (_) => []);

  @override
  void initState(){
    super.initState();
    scannerDatas!.addListener(_triggerScan);
  }

  Future onReadingNextEvaluation() async{
    
  }

  void _unselect() {switch(inventoryMState){
    case InventoryMState.inventoryPick: return (buttonContinue == ButtonState.default0)? setState((){selectedBizonylat = null; buttonContinue = ButtonState.disabled;}) : null;
    default:                            return;
  }}

  Future buttonEvaluatePressed() async{
    setState(() => buttonEvaluate = ButtonState.loading);
    await DataManager(quickCall: QuickCall.inventoryMezAndMolEvaluate).beginQuickCall;
    setState(() {buttonEvaluate = ButtonState.default0; inventoryMState = InventoryMState.evaluate;});
  }

  Future buttonInfoPressed() async{

  }

  Future buttonPrintPressed() async{

  }

  Future ButtonMissingPressed() async{

  }

  Future buttonContinuePressed() async{
    setState(() => buttonContinue = ButtonState.loading);
    await DataManager(input: {'bizonylat_id': listBizonylatok[selectedBizonylat!]['bizonylat_id']}).beginProcess;
    _initListOfIems();
    setState(() => inventoryMState = InventoryMState.scanStorageCode);
  }

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
          'tetelek':      listOfItems[i]
        });
      }
      await DataManager(quickCall: QuickCall.inventoryMezAndMolSave, input: {'parameter': parameter, 'lezart': 1}).beginQuickCall;
      if(mounted) Navigator.pop(context);
    }
    if(mounted) setState(() => buttonSave = ButtonState.default0);
  }

  Future<bool> _handlePop() async {
    if([InventoryMState.empty, InventoryMState.inventoryPick].contains(inventoryMState)) return true;
    bool result = (await Global.yesNoDialog(context, title: 'ℹ️ Leltár folymat félbeszakítása', content: 'Kívánja félbeszakítani a leltár folyamatát és visszalépni a főmenübe?\n\n💾 Az idáig beolvasott adatok elmentésre kerülnek.'));
    if(result && listOfItems.isNotEmpty) {
      List<Map<String, dynamic>> parameter = [];
      for(int i = 0; i <= index; i++){
        parameter.add({
          'bizonylat_id': rawData[i]['bizonylat_id'],
          'tarhely_id':   rawData[i]['tarhely_id'],
          'tetelek':      listOfItems[i]
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
      if((rawData[index]['barcode'].toString() != scanResult)){
        AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
        setState(() => message = '⚠️ Helytelen tárhely kód!\n$scanResult');
        Future.delayed(const Duration(seconds: 3), () => setState(() => message = ''));
      }
      else {setState(() => inventoryMState = InventoryMState.scanItemsInStorage);}
      break;

    case InventoryMState.scanItemsInStorage:
      String scanResult =     scannerDatas!.value.scanData.trim();
      if(!RegExp(r'^\d{6,7}$').hasMatch(scanResult)){
        setState(() => message = '⚠️ Érvénytelen vonalkód!\n$scanResult');
        AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
        Future.delayed(const Duration(seconds: 3), () => setState(() => message = ''));
        return; 
      }
      if(listOfItems[index].any((item) => item['abroncs_id'] == scanResult)){
        setState(() => message = '⚠️ Ez a vonalkód már be lett olvasva!\n$scanResult');
        AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
        Future.delayed(const Duration(seconds: 3), () => setState(() => message = ''));
        return;
      }
      setState(() => listOfItems[index].add({
        'abroncs_id':   scanResult,
        'dolgozo_kod':  DataManager.userId,
        'dolgozo_nev':  DataManager.userName,
        'datum':        DateFormat('yyyy.MM.dd H:mm').format(DateTime.now())
      }));
      break;

    default: break;
  }}
}