// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';

class ListOrders extends StatefulWidget{
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ListOrders({Key? key}) : super(key: key);

  @override
  State<ListOrders> createState() => ListOrdersState();
}

class ListOrdersState extends State<ListOrders>{
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> rawData = List<dynamic>.empty(growable: true);
  static int? getSelectedIndex;

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonState = ButtonState.disabled;
  int? _selectedIndex;
  set selectedIndex(int? value) {if(buttonState != ButtonState.loading){
    if(value == null) {buttonState = ButtonState.disabled; _selectedIndex = value; getSelectedIndex = _selectedIndex;}
    else if(rawData[value]['kesz'].toString() != '1') {buttonState = ButtonState.default0; _selectedIndex = value; getSelectedIndex = _selectedIndex;}
  }}
  String get title {switch(Global.currentRoute){
    case NextRoute.pickUpList:  return 'Kiszedési lista';
    case NextRoute.orderList:
    default:                    return 'Kitárazás';
  }}
  int? get selectedIndex => _selectedIndex;  

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  

  // ---------- < WidgetBuild > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){    
    return GestureDetector(
      onTap:  () => setState(() => selectedIndex = null),
      child:  Scaffold(
        appBar: AppBar(
          title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text(title))),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
        ),
        backgroundColor:  Colors.white,
        body:             LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return (rawData.isNotEmpty) 
            ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _drawDataTable,
              _drawNoConnection,
              _drawBottomBar
            ])
            : const Center(child: Text('Nincs adat'));
          }
        )
      )
    );
  }  
  
  // ---------- < Widgets [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawDataTable =>  Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child: 
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            _generateColumns,
      rows:               _generateRows,
      showCheckboxColumn: false,                
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ));

  Widget get _drawNoConnection => Visibility(visible: !DataManager.isServerAvailable, child: Container(height: 20, color: Colors.red, child: Row(
    mainAxisAlignment:  MainAxisAlignment.center,
    children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
  )));

  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [        
      Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
            onPressed:  () => (buttonState == ButtonState.default0)? _buttonNextPress : null,
            style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
            child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Visibility(
                visible:  (buttonState == ButtonState.loading)? true : false,
                child:    Padding(
                  padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonState)))
                )
              ),
              Icon(
                Icons.arrow_forward,
                color: Global.getColorOfIcon(buttonState),
                size:  30,
              )
            ])
          )
        ])
      )
    ])
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawData[0].keys) {switch(item){
      case 'sorszam': columns.add(const DataColumn(label: Text('Rendelés Sorszáma')));  break;
      case 'vevo':    columns.add(const DataColumn(label: Text('Vevő Megnevezése')));   break;
      case 'kesz':    columns.add(const DataColumn(label: Text('')));                   break;
      default:                                                                          break;
    }}
    return columns; 
  }

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData.length; i++) {
      rows.add(DataRow(
        cells:            _getCells(rawData[i]),
        selected:         (i == selectedIndex),
        onSelectChanged:  (bool? selected) => setState(() => selectedIndex = i)
      )); 
    }
    return rows;
  }

  Future get _buttonNextPress async {switch(Global.currentRoute){

    case NextRoute.pickUpList:
      setState(() => buttonState = ButtonState.loading);
      DataManager dataManager = DataManager();
      Global.routeNext =        NextRoute.pickUpData;
      await dataManager.beginProcess;
      if(DataManager.isServerAvailable){
        buttonState = ButtonState.default0;
        await Navigator.pushNamed(context, '/listPickUpDetails');
        setState((){});
      }
      else {setState(() {buttonState = ButtonState.default0; Global.routeNext = NextRoute.pickUpList;});}
      break;

    case NextRoute.orderList:
      setState(() => buttonState = ButtonState.loading);
      DataManager dataManager = DataManager();
      Global.routeNext =        NextRoute.scanTasks;
      await dataManager.beginProcess;
      if(DataManager.isServerAvailable){
        buttonState = ButtonState.default0;
        await Navigator.pushNamed(context, '/scanOrders');
        setState((){});
      }
      else {setState(() {buttonState = ButtonState.default0; Global.routeNext = NextRoute.orderList;});}
      break;

    default:break;
  }}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataCell> _getCells(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'sorszam':
      case 'vevo':    cells.add(DataCell(Text(row[item].toString())));  break;
      case 'kesz':    cells.add(DataCell((row[item].toString() == '1')
        ? Icon(Icons.check_circle, color: Global.getColorOfButton(ButtonState.default0), size: 30)
        : Container()));                                                break;
      default:                                                          break;
    }}
    return cells;
  }
}