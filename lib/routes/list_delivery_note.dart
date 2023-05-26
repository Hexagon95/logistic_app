// ignore_for_file: use_build_context_synchronously, recursive_getters

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';

class ListDeliveryNote extends StatefulWidget{//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScan>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ListDeliveryNote({Key? key}) : super(key: key);

  @override
  State<ListDeliveryNote> createState() => ListDeliveryNoteState();
}

class ListDeliveryNoteState extends State<ListDeliveryNote>{  
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScanState>
  static List<dynamic> rawData =  List<dynamic>.empty(growable: true);
  static String signatureBase64 = '';
  static String storageId =       '';

  static Map<String, dynamic>? currentItem;
  static List<dynamic>? barcodeResult;
  static String? result;
  static String? getSelectedId;
 
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  NumberFormat numberFormat =   NumberFormat("###,###.00#", "hu_HU");
  final GlobalKey qrKey =       GlobalKey(debugLabel: 'QR');
  TextStyle formTextStyle =     const TextStyle(fontSize: 14);
  TaskState taskState =         TaskState.listDeliveryNotes;
  ButtonState buttonSignature = ButtonState.disabled;
  ButtonState buttonClear =     ButtonState.disabled;
  ButtonState buttonCheck =     ButtonState.disabled;
  bool isProcessIndicator =     false;

  int? _selectedIndex; int? get selectedIndex => _selectedIndex; set selectedIndex(int? value){
    if(buttonSignature == ButtonState.loading) return;
    buttonSignature = (value == null)? ButtonState.disabled : ButtonState.default0;
    _selectedIndex =  value;
    getSelectedId =   (value == null)? null : rawData[value]['id'].toString();
  }
  final SignatureController _controller = SignatureController(
    penStrokeWidth:         1,
    penColor:               Colors.black,
    exportBackgroundColor:  Colors.white,
    onDrawStart:            (){},
    onDrawEnd:              (){}
  );

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {  
    return WillPopScope(
      onWillPop:  () => _handlePop,
      child:      (){switch(taskState){
        case TaskState.listDeliveryNotes: return _drawListDeliveryNotes;
        case TaskState.signature:         return _drawSignaureCanvas;
        default: return Container();
      }}()      
    );
  }
  
  // ---------- < WidgetBuild [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawListDeliveryNotes => GestureDetector(
    onTap: () => setState(() => selectedIndex = null),
    child: Scaffold(
      appBar: AppBar(
        title:            const Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Szállítólevél átvétel'))),
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
    )
  );

  Widget get _drawSignaureCanvas =>  Scaffold(
    appBar:           AppBar(
      title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Sorszám: ${rawData[selectedIndex!]['Sorszám']}'))),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
    ),
    backgroundColor:  Colors.white,
    body:             OrientationBuilder(builder: (context, orientation) {
      return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[ //ListView(children: <Widget>[ 
        Expanded(child: Signature( //SIGNATURE CANVAS0
          controller:       _controller,                
          backgroundColor:  Colors.white,
        )),
        _drawBottomBar
      ]);
    })
  );

// ---------- < WidgetBuild [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawDataTable => (rawData.isNotEmpty)
  ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child:
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            _generateColumns,
      rows:               _generateRows,                
      showCheckboxColumn: false,                
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ))
  : const Expanded(child: Center(child: Text('Üres', style: TextStyle(fontSize: 20))));

  Widget get _drawBottomBar{ switch(taskState){

    case TaskState.listDeliveryNotes: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _drawButtonSignature
      ])
    );

    case TaskState.signature: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(),
        _drawButtonClear,
        Container(),
        _drawButtonCheck,
        Container()
      ])
    );

    default: return Container();
  }}
  
  // ---------- < WidgetBuild [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] >  ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonSignature => TextButton(
    onPressed:  () => (buttonSignature == ButtonState.default0)? _buttonSignaturePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonSignature == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading))),
      Text('Aláírás ', style: TextStyle(fontSize: 20, color: Global.getColorOfIcon(buttonSignature))),
      Icon(Icons.edit_document, color: Global.getColorOfIcon(buttonSignature))
    ])
  );

  Widget get _drawButtonClear => IconButton(
    icon:       const Icon(Icons.clear),
    color:      Global.getColorOfIcon(buttonClear),
    onPressed:  () => (buttonClear == ButtonState.default0)? setState(() => _controller.clear()) : null
  );

  Widget get _drawButtonCheck => Row(children: [
    Visibility(
      visible:  (buttonCheck == ButtonState.loading),
      child:    Padding(padding: const EdgeInsets.all(5), child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Global.getColorOfIcon(ButtonState.loading))))
    ),
    IconButton(
      icon:       const Icon(Icons.save),
      color:      Global.getColorOfIcon(buttonCheck),
      onPressed:  () => (buttonCheck == ButtonState.default0)? _checkPressed : null
    )
  ]);

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  void initState() {
    super.initState();
    _controller.addListener((){
      if(_controller.isEmpty) {setState((){
        buttonCheck = ButtonState.disabled;
        buttonClear = ButtonState.disabled;
      });}
      else {setState((){
        buttonCheck = ButtonState.default0;
        buttonClear = ButtonState.default0;
      });}
    });
  }

  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawData[0].keys) {switch(item){
      case 'ip':            
      case 'Sorszám':
      case 'Vevő':
      case 'Kelte':
      case 'Pénznem':
      case 'Bruttó érték':  columns.add(DataColumn(label: Text(item))); break;
      default:break;
    }}
    return columns;
  }

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData.length; i++) {rows.add(DataRow(
      selected:         (selectedIndex == i),
      onSelectChanged:  (value) => setState(() => selectedIndex = i),
      cells:            _getCells(rawData[i])
    ));}
    return rows;
  } 

  Future get _buttonSignaturePressed async{
    setState(() => taskState = TaskState.signature);
  }

  Future get _checkPressed async {if(_controller.isNotEmpty){
    setState(() => buttonCheck = ButtonState.loading);
    final Uint8List? data = await _controller.toPngBytes();
    if (data != null) {       
      signatureBase64 =         base64.encode(data);        
      DataManager dataManager = DataManager(quickCall: QuickCall.saveSignature);
      await dataManager.beginQuickCall;
      buttonCheck =             ButtonState.default0;
      taskState =               TaskState.listDeliveryNotes;
      await dataManager.beginProcess;
      selectedIndex =           null;
      _controller.clear();
      setState((){});
    }
  }}

  Future<bool> get _handlePop async{switch(taskState) {
    case TaskState.signature: setState(() => taskState = TaskState.listDeliveryNotes);  return false;
    default:                                                                            return true;
  }}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataCell> _getCells(Map<String, dynamic> row){
    String formatedNumber(String input) {try{return numberFormat.format(double.parse(input));} catch(e){return input;}}
    List<DataCell> cells =      List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'ip':
      case 'Sorszám':
      case 'Vevő':
      case 'Kelte':
      case 'Pénznem':       cells.add(DataCell(Text(row[item].toString()))); break;
      case 'Bruttó érték':  cells.add(DataCell(Align(
        alignment:  Alignment.centerRight,
        child:      Text(formatedNumber(row[item].toString()))
      ))); break;
      default:break;
    }}
    return cells;
  }  

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