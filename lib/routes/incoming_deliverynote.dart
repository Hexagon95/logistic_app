// ignore_for_file: use_build_context_synchronously
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';

class IncomingDeliveryNote extends StatefulWidget{
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const IncomingDeliveryNote({Key? key}) : super(key: key);

  @override
  State<IncomingDeliveryNote> createState() => IncomingDeliveryNoteState();
}

class IncomingDeliveryNoteState extends State<IncomingDeliveryNote>{
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static Map<String, dynamic> listOfLookupDatas = <String, dynamic>{};
  static List<TextEditingController> controller = List<TextEditingController>.empty(growable: true);
  static List<dynamic> rawDataListDeliveryNotes = List<dynamic>.empty(growable: true);
  static List<dynamic> rawDataDataForm =          List<dynamic>.empty(growable: true);
  static InDelNoteState taskState =               InDelNoteState.default0;
  static int? getSelectedIndex;

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonAdd =       ButtonState.default0;
  ButtonState buttonEdit =      ButtonState.default0;
  ButtonState buttonRemove =    ButtonState.default0;
  ButtonState buttonContinue =  ButtonState.disabled;
  int? _selectedIndex;
  set selectedIndex(int? value) {if(buttonContinue != ButtonState.loading){
    if(value == null) {buttonContinue = ButtonState.disabled; _selectedIndex = value; getSelectedIndex = _selectedIndex;}
    else if(rawDataListDeliveryNotes[value]['kesz'].toString() != '1') {buttonContinue = ButtonState.default0; _selectedIndex = value; getSelectedIndex = _selectedIndex;}
  }}
  int? get selectedIndex => _selectedIndex;
   BoxDecoration customBoxDecoration =       BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  

  // ---------- < WidgetBuild > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){    
    return WillPopScope(onWillPop: _handlePop, child: GestureDetector(
      //onTap:  () => setState(() => selectedIndex = null),
      child:  Scaffold(
        appBar: AppBar(
          title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text((){switch(taskState){
            case InDelNoteState.addNew:     return  'Új bizonylat';
            case InDelNoteState.listItems:  return  'Tételek';
            case InDelNoteState.addItem:    return  'Új cikk';
            default:                        return  'Bejövő szállítólevelek';
          }}()))),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
          foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
        ),
        backgroundColor:  Colors.white,
        body:             LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              (){switch(taskState){
                case InDelNoteState.default0: return  _drawListDeliveryNotes;
                case InDelNoteState.addItem:
                case InDelNoteState.addNew:   return  _drawDataForm;
                default:                      return  Container();
              }}(),
              _drawNoConnection,
              _drawBottomBar
            ]);
          }
        )
      )
    ));
  }  
  
  // ---------- < Widgets [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawListDeliveryNotes => rawDataListDeliveryNotes.isNotEmpty
    ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child: 
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
          columns:            _generateColumns,
          rows:               _generateRows,
          showCheckboxColumn: false,                
          border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
        ))
      ))
    : Container()
  ;

  Widget get _drawDataForm{
    int maxSor() {int maxSor = 1; for(var item in rawDataDataForm) {if(item['sor'] > maxSor) maxSor = item['sor'];} return maxSor;}

    List<Widget> varListWidget = List<Widget>.empty(growable: true);
    for(int sor = 1; sor <= maxSor(); sor++) {
      List<Widget> row = List<Widget>.empty(growable: true);
      for(int i = 0; i < rawDataDataForm.length; i++) {if(rawDataDataForm[i]['sor'] == sor){
        row.add(Padding(
          padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child:    Container(decoration: customBoxDecoration, child: Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawDataDataForm[i], i)))
        ));
      }}
      varListWidget.add(SizedBox(width: MediaQuery.of(context).size.width, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: row)));
    }
    return Expanded(child: SingleChildScrollView(child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:           varListWidget
    )));
  }

  Widget get _drawNoConnection => Visibility(visible: !DataManager.isServerAvailable, child: Container(height: 20, color: Colors.red, child: Row(
    mainAxisAlignment:  MainAxisAlignment.center,
    children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
  )));

  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child: (){switch(taskState){
    case InDelNoteState.default0:   return  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_drawButtonAdd,_drawButtonContinue]);
    case InDelNoteState.addNew:     return  Row(mainAxisAlignment: MainAxisAlignment.end, children: [_drawButtonContinue]);
    case InDelNoteState.listItems:  return  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_drawButtonAdd, _drawButtonEdit, _drawButtonRemove]);
    case InDelNoteState.addItem:    return  Row(mainAxisAlignment: MainAxisAlignment.end, children: [_drawButtonContinue]);
    default:                        return  Container();
  }}());

  // ---------- < Buttons > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonAdd => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonAdd == ButtonState.default0)? _buttonAddPressed : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonAdd == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonAdd)))
            )
          ),
          Icon(
            Icons.add,
            color: Global.getColorOfIcon(buttonAdd),
            size:  30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonEdit => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonEdit == ButtonState.default0)? _buttonAddPressed : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonEdit == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonEdit)))
            )
          ),
          Icon(
            Icons.edit_document,
            color: Global.getColorOfIcon(buttonEdit),
            size:  30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonRemove => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonRemove == ButtonState.default0)? _buttonAddPressed : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonRemove == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonRemove)))
            )
          ),
          Icon(
            Icons.remove,
            color: Global.getColorOfIcon(buttonRemove),
            size:  30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonContinue => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonContinue == ButtonState.default0)? _buttonContinuePressed : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonContinue == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonContinue)))
            )
          ),
          Icon(
            Icons.arrow_forward,
            color: Global.getColorOfIcon(buttonContinue),
            size:  30,
          )
        ])
      )
    ])
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawDataListDeliveryNotes[0].keys) {switch(item){
      case 'sorszam':   columns.add(const DataColumn(label: Text('Sorszám')));          break;
      case 'kesz':      columns.add(const DataColumn(label: Text('')));                 break;
      case 'vevo':
      case 'szallito':  columns.add(const DataColumn(label: Text('Megnevezés')));       break;
      default:                                                                          break;
    }}
    return columns; 
  }

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawDataListDeliveryNotes.length; i++) {
      rows.add(DataRow(
        cells:            _getCells(rawDataListDeliveryNotes[i]),
        selected:         (i == selectedIndex),
        onSelectChanged:  (bool? selected) => setState(() => selectedIndex = i)
      )); 
    }
    return rows;
  }

  Future get _buttonAddPressed async{ switch(taskState){

    case InDelNoteState.default0:
      setState(() => buttonAdd = ButtonState.loading);
      await DataManager(quickCall: QuickCall.addNewDeliveryNote).beginQuickCall;
      setState((){
        buttonAdd = ButtonState.default0;
        taskState = InDelNoteState.addNew;
      });
      break;

    case InDelNoteState.listItems:
      setState(() => buttonAdd = ButtonState.loading);
      await DataManager(quickCall: QuickCall.addDeliveryNoteItem).beginQuickCall;
      setState((){
        buttonAdd = ButtonState.default0;
        taskState = InDelNoteState.addItem;
      });
      break;

    default: break;
  }}

  Future get _buttonContinuePressed async {switch(taskState){

    case InDelNoteState.default0:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
      setState((){
        taskState =       InDelNoteState.listItems;
        buttonContinue =  ButtonState.default0;
      });
      break;

    case InDelNoteState.addNew:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(quickCall: QuickCall.addNewDeliveryNoteFinished).beginQuickCall;
      await DataManager().beginProcess;
      setState((){
        taskState =       InDelNoteState.default0;
        buttonContinue =  ButtonState.default0;
      });
      break;

    case InDelNoteState.addItem:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(quickCall: QuickCall.addItemFinished).beginQuickCall;
      await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
      setState((){
        taskState =       InDelNoteState.listItems;
        buttonContinue =  ButtonState.default0;
      });

      break;

    default:break;
  }}

  Future<bool>_handlePop() async{ switch(taskState){

    case InDelNoteState.addNew:
      setState(() => taskState = InDelNoteState.default0);
      return false;

    case InDelNoteState.listItems:
      setState(() => taskState = InDelNoteState.default0);
      return false;

    case InDelNoteState.addItem:
      setState(() => taskState = InDelNoteState.listItems);
      return false;

    default: setState((){}); return true;
  }}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _getWidget(dynamic input, int index){
    bool editable =           (input['editable'].toString() == '1');
    controller[index].text =  (rawDataDataForm[index]['value'] == null)? '' : rawDataDataForm[index]['value'].toString();
    double getWidth(int index) {int sorDB = 0; for(var item in rawDataDataForm) {if(item['sor'] == rawDataDataForm[index]['sor']) sorDB++;} return MediaQuery.of(context).size.width / sorDB - 22;}
    TextInputType? getKeyboard(String? keyboardType) {if(keyboardType == null) return null; switch(keyboardType){
      case 'number':  return TextInputType.number;
      default:        return null;
    }}

    switch(input['input_field']){

      case 'search':
        List<String> items =    List<String>.empty(growable: true);
        for(var item in listOfLookupDatas[input['id']]) {items.add(item['megnevezes'].toString());}
        return (items.isNotEmpty && editable)
        ? Stack(alignment: AlignmentDirectional.centerStart, children: [
            Visibility(visible: (rawDataDataForm[index]['value'] == null), child: Padding(padding: const EdgeInsets.all(10), child: Text(
              rawDataDataForm[index]['name'],
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ))),
            SizedBox(height: 55, width: getWidth(index), child: DropdownSearch<String>(
              items:                  items,
              selectedItem:           controller[index].text,
              popupProps:             const PopupProps.menu(showSearchBox: true),
              onChanged:              (String? newValue) => _handleSelectChange(newValue, index),
              dropdownButtonProps:    const DropdownButtonProps(
                icon:                     Row(mainAxisSize: MainAxisSize.min, children:[Icon(Icons.search), Icon(Icons.arrow_downward)]),
                padding:                  EdgeInsets.symmetric(vertical: 16),
              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                baseStyle:                TextStyle(color: Colors.black),
                textAlign:                TextAlign.start,
                textAlignVertical:        TextAlignVertical.center,
                dropdownSearchDecoration: InputDecoration(border: InputBorder.none)
              ),
            ))
          ])
        : SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:      false,          
          controller:   controller[index],
          decoration:   InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      rawDataDataForm[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      case 'select':
        bool isInLookupData(String input, List<dynamic>? list) {if(list != null)for(var item in list) {if(item['id'].toString() == input) return true;} return false;}
        String getItem(dynamic varList, String id) {for(dynamic item in varList) {if(item['id'] == id) return item['megnevezes'];} return '';}

        List<DropdownMenuItem<String>> items =  List<DropdownMenuItem<String>>.empty(growable: true);
        List<dynamic>? lookupData =             listOfLookupDatas[input['id']];
        if(lookupData != null) for(var item in lookupData) {items.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['megnevezes'], textAlign: TextAlign.start)));}
        String? selectedItem =    (isInLookupData(rawDataDataForm[index]['value'].toString(), lookupData))? rawDataDataForm[index]['value'].toString() : null;
        return (lookupData != null && lookupData.isNotEmpty && editable)
        ? Stack(children: [
            SizedBox(height: 55, width: getWidth(index), child: Padding(padding: const EdgeInsets.all(15), child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value:            selectedItem,
            hint:             Text(rawDataDataForm[index]['name'].toString(), textAlign: TextAlign.start),
            icon:             const Icon(Icons.arrow_downward),
            iconSize:         24,
            elevation:        16,
            isExpanded:       false,
            alignment:        AlignmentDirectional.centerStart,
            dropdownColor:    const Color.fromRGBO(230, 230, 230, 1),
            menuMaxHeight:    MediaQuery.of(context).size.height / 3,
            onChanged:        (String? newValue) async => await _handleSelectChange(newValue, index),
            items:            items
          )))),
          (selectedItem != null)
          ? Text(rawDataDataForm[index]['name'].toString(), style: const TextStyle(color: Colors.grey))
          : Container()
        ])
        : SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:      false,
          initialValue: (selectedItem != null)? getItem(lookupData, selectedItem) : null,
          controller:   (selectedItem != null)? null : controller[index],
          decoration:   InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      rawDataDataForm[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      default: return SizedBox(height: 55, width: getWidth(index), child: TextFormField(
        enabled:          editable,
        controller:       controller[index],
        keyboardType:     getKeyboard(input['keyboard_type']),
        decoration:       InputDecoration(
          contentPadding:   const EdgeInsets.all(10),
          labelText:        input['name'],
          border:           InputBorder.none,
        ),
        onChanged:    (value) => setState((){rawDataDataForm[index]['value'] = value;}),
        style:        TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
      ));
    }
  }

  List<DataCell> _getCells(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'sorszam':
      case 'szallito':
      case 'vevo':    cells.add(DataCell(Text(row[item].toString())));  break;
      case 'kesz':    cells.add(DataCell((row[item].toString() == '1')
        ? Icon(Icons.check_circle, color: Global.getColorOfButton(ButtonState.default0), size: 30)
        : Container()));                                                break;
      default:                                                          break;
    }}
    return cells;
  }

  // ---------- < Methods [3] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future _handleSelectChange(String? newValue, int index) async{
    ButtonState setButton(){
      for(var item in rawDataDataForm) {if(item['value'] == null || item['value'].toString().isEmpty) {return ButtonState.disabled;}}
      return ButtonState.default0;
    }
    if(newValue == null) {rawDataDataForm[index]['kod'] = null;}
    else {for(dynamic item in listOfLookupDatas[rawDataDataForm[index]['id']]) {if(item['megnevezes'] == newValue) rawDataDataForm[index]['kod'] = item['id'];}}
    DataManager dataManager = DataManager(quickCall: QuickCall.chainGiveDatasDeliveryNote, input: {'index': index});
    await dataManager.beginQuickCall;
    setState((){
      rawDataDataForm[index]['value'] = newValue;
      buttonContinue =                  setButton();
    });
  }
}