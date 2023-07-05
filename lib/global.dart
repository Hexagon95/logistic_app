// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ---------- < Enums > --- ---------- ---------- ---------- ----------
enum NextRoute    {logIn,           menu,           orderList,              pickUpList,           deliveryNoteList, checkStock,     inventory,              pickUpData,
                  pickUpDataFinish, scanTasks,      finishTasks,            dataFormMonetization, default0}
enum ButtonState  {hidden,          loading,        disabled,               error,                default0}
enum TaskState    {askStorage,      scanStorage,    askProduct,             scanProduct,          barcodeManual,    inventory,      listDeliveryNotes,      itemData,
                  wrongItem,        handleProduct,  scanDestinationStorage, showPDF,              signature,        default0}
enum QuickCall    {askBarcode,      deleteItem,     saveInventory,          askInventoryDate,     checkStock,       saveSignature,  scanDestinationStorage, savePdf}
enum DialogResult {cancel,          back,           mainMenu}

class Global{
  // ---------- < Variables [Static] > - ---------- ---------- ----------
  static List<NextRoute> _routes =      List<NextRoute>.empty(growable: true);
  static NextRoute get currentRoute =>  _routes.last;
  static void get routeBack             {_routes.removeLast(); _printRoutes;}
  static set routeNext (NextRoute value){
    int check(int i)  {while(_routes.length > i){_routes.removeLast();} while(_routes.length <= i){_routes.add(NextRoute.default0);} return i; }
    switch (value) {
      case NextRoute.logIn:                 _routes[check(0)] =   value;  break;
      case NextRoute.menu:                  _routes[check(1)] =   value;  break;
      case NextRoute.orderList:             _routes[check(2)] =   value;  break;
      case NextRoute.pickUpList:            _routes[check(2)] =   value;  break;
      case NextRoute.deliveryNoteList:      _routes[check(2)] =   value;  break;
      case NextRoute.checkStock:            _routes[check(2)] =   value;  break;
      case NextRoute.inventory:             _routes[check(2)] =   value;  break;
      case NextRoute.pickUpData:            _routes[check(3)] =   value;  break;
      case NextRoute.scanTasks:             _routes[check(3)] =   value;  break;
      case NextRoute.finishTasks:           _routes[check(3)] =   value;  break;
      case NextRoute.dataFormMonetization:  _routes[check(3)] =   value;  break;
      case NextRoute.pickUpDataFinish:      _routes[check(4)] =   value;  break;
      default:  throw Exception('Default rout has been thrown!!!!');
    }
    _printRoutes;
  }  

  // ---------- < SQL Commands > ------- ---------- ---------- ----------
  static const String sqlCreateTableIdentity = "CREATE TABLE identityTable(id INTEGER PRIMARY KEY, identity TEXT)";
  
  // ---------- < Global Dialogs > ----- ---------- ---------- ----------
  static Future showAlertDialog(BuildContext context, {String title = 'Figyelmeztetés', required String content}) async{
    
    Widget okButton = TextButton(
      child: const Text('Ok'),
      onPressed: () => Navigator.pop(context, true)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title,   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 12)),
      actions:  [okButton]
    ); 

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<bool> yesNoDialog(BuildContext context, {String title = '', String content = ''}) async{
    Widget leftButton = TextButton(
      child: const Text('Igen'),
      onPressed: () => Navigator.pop(context, true)
    );
    Widget rightButton = TextButton(
      child: const Text('Nem'),
      onPressed: () => Navigator.pop(context, false)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 12)),
      actions:  [leftButton, rightButton]
    );

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  } 

  // ---------- < Global Methods > ----- ---------- ---------- ----------
  static Color getColorOfButton(ButtonState buttonState){    
    switch(buttonState){
      case ButtonState.default0:  return const Color.fromRGBO(0, 180, 125, 1.0);
      case ButtonState.disabled:  return const Color.fromRGBO(75, 255, 200, 1.0);
      case ButtonState.loading:   return const Color.fromRGBO(0, 225, 0, 1.0);
      case ButtonState.hidden:    return Colors.transparent;
      default:                    return Colors.red;
    }
  }

  static Color getColorOfIcon(ButtonState buttonState){    
    switch(buttonState){
      case ButtonState.default0:  return Colors.white;
      case ButtonState.disabled:  return const Color.fromRGBO(255, 255, 255, 0.3);
      case ButtonState.loading:   return const Color.fromRGBO(0, 80, 0, 1.0);
      case ButtonState.hidden:    return Colors.transparent;
      default:                    return Colors.red;
    }
  }

  static List<String> filterSearchResults({required List<String> input, String query = ''}) {    
    List<String> items = List<String>.empty(growable: true);
    items.addAll([...input]);    
    if(query.isNotEmpty){      
      for (var i = 0; i < items.length; i++) {
        if(!items[i].toString().toUpperCase().contains(query.toUpperCase())){
          items.removeAt(i);
          i--;
        }        
      }
    }
    return items;
  }
  
  static List<DataRow> filterSearchResultsRows({required List<DataRow> input, String query = ''}) {    
    List<DataRow> items = List<DataRow>.empty(growable: true);
    items.addAll([...input]);    
    if(query.isNotEmpty){      
      for (var i = 0; i < items.length; i++) {
        if(!items[i].cells[0].child.toString().toUpperCase().contains(query.toUpperCase())){
          items.removeAt(i);
          i--;
        }        
      }
    }
    return items;
  }

  // ---------- < Methods [1] > -------- ---------- ---------- ----------
  static void get _printRoutes{
    String varString = 'IIIII: ';
    for (var item in _routes) {varString += '$item, ';}
    if(kDebugMode)print(varString);
  }
}