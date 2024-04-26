// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// ---------- < Enums > --- ---------- ---------- ---------- ----------
enum NextRoute{               logIn,                menu,               orderList,            orderOutList,       pickUpList,               deliveryNoteList,
  checkStock,                 inventory,            pickUpData,         default0,             pickUpDataFinish,   scanTasks,                finishTasks,
  dataFormMonetization,       dataFormGiveDatas,    deliveryOut,        incomingDeliveryNote 
}
enum ButtonState{             hidden,               loading,            disabled,             error,              default0}
enum TaskState{               askStorage,           scanStorage,        askProduct,           scanProduct,        barcodeManual,            inventory,
  listDeliveryNotes,          itemData,             default0,           wrongItem,            handleProduct,      scanDestinationStorage,   showPDF,
  signature,                  dataForm,             dataList
}
enum QuickCall{               askBarcode,           deleteItem,         saveInventory,        askInventoryDate,   checkCode,                checkStock,
  addItem,                    saveSignature,        savePdf,            giveDatas,            chainGiveDatas,     finishGiveDatas,          scanDestinationStorage,
  askAbroncs,                 print,                checkArticle,       newEntry,             verzio,             tabletBelep,              addNewDeliveryNote,
  addNewDeliveryNoteFinished, askDeliveryNotesScan, addDeliveryNoteItem, chainGiveDatasDeliveryNote, addItemFinished, plateNumberCheck, printBarcodeDeliveryNote, selectAddItemDeliveryNote, finishSelectAddItemDeliveryNote
}
enum DialogResult{            cancel,               back,               mainMenu}
enum StockState{              checkStock,           stockIn,            default0}
enum ScannedCodeIs{           storage,              article,            unknown}
enum InDelNoteState{          addItem,              listItems,          addNew,               default0, listSelectAddItemDeliveryNote}

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
      case NextRoute.deliveryOut:           _routes[check(2)] =   value;  break;
      case NextRoute.incomingDeliveryNote:  _routes[check(2)] =   value;  break;
      case NextRoute.orderOutList:          _routes[check(2)] =   value;  break;
      case NextRoute.pickUpList:            _routes[check(2)] =   value;  break;
      case NextRoute.deliveryNoteList:      _routes[check(2)] =   value;  break;
      case NextRoute.checkStock:            _routes[check(2)] =   value;  break;
      case NextRoute.inventory:             _routes[check(2)] =   value;  break;
      case NextRoute.pickUpData:            _routes[check(3)] =   value;  break;
      case NextRoute.scanTasks:             _routes[check(3)] =   value;  break;
      case NextRoute.finishTasks:           _routes[check(3)] =   value;  break;
      case NextRoute.dataFormMonetization:  _routes[check(3)] =   value;  break;
      case NextRoute.dataFormGiveDatas:     _routes[check(3)] =   value;  break;
      case NextRoute.pickUpDataFinish:      _routes[check(4)] =   value;  break;
      default:  throw Exception('Default rout has been thrown!!!!');
    }
    _printRoutes;
  }
  static bool isScannerDevice = false;

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

  static Future<int?> integerDialog(BuildContext context, {String title = '', String content = ''}) async{
    // --------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    int? varInt;
    BoxDecoration customBoxDecoration =       BoxDecoration(            
      border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color:        Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8))
    );

    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget okButton = TextButton(child: const Text('Ok'),     onPressed: () => Navigator.pop(context, varInt));
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //

    // --------- < Display > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        onChanged:    (value) => varInt = double.parse(value).toInt(),
        decoration:   InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      content,
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
        keyboardType: TextInputType.number,
      )),
      actions:  [okButton, cancel]
    );

    // --------- < Return > ---- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<String?> plateNuberDialog(BuildContext context, {String title = '', String content = ''}) async{
    // --------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    String? varString;
    BoxDecoration customBoxDecoration =       BoxDecoration(            
      border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color:        Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8))
    );

    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget okButton = TextButton(child: const Text('Ok'),     onPressed: () => Navigator.pop(context, varString));
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //

    // --------- < Display > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        onChanged:    (value) => varString = value,
        decoration:   InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      content,
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      actions:  [okButton, cancel]
    );

    // --------- < Return > ---- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  } 

  // ---------- < Global Methods > ----- ---------- ---------- ----------
  static Color invertColor(Color input) => Color.fromRGBO((input.red - 255).abs(), (input.green - 255).abs(), (input.blue - 255).abs(), 1.0);

  static Map<ButtonState, Color> customColor = {
    ButtonState.default0: const Color.fromRGBO(0, 180, 125, 1.0),
    ButtonState.disabled: const Color.fromRGBO(75, 255, 200, 1.0),
    ButtonState.loading:  const Color.fromRGBO(0, 225, 0, 1.0),
    ButtonState.hidden:   Colors.transparent,
    ButtonState.error:    Colors.red
  };
  static Color getColorOfButton(ButtonState buttonState) => customColor[buttonState]!;

  static Color getColorOfIcon(ButtonState buttonState){    
    switch(buttonState){
      case ButtonState.default0:  return Colors.white;
      case ButtonState.disabled:  return const Color.fromRGBO(255, 255, 255, 0.3);
      case ButtonState.loading:   return const Color.fromRGBO(255, 255, 0, 1.0);
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

  static dynamic where(List<dynamic> input, String entry, String value) {for(dynamic item in input){
    if(item[entry] == value) return item;
  }}

  // ---------- < Methods [1] > -------- ---------- ---------- ----------
  static void get _printRoutes{
    String varString = 'IIIII: ';
    for (var item in _routes) {varString += '$item, ';}
    if(kDebugMode)print(varString);
  }
}
