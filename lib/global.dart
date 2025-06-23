// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ---------- < Enums > --- ---------- ---------- ---------- ----------
enum NextRoute{                 logIn,                      menu,                             orderList,                                orderOutList,
  pickUpList,                   deliveryNoteList,           checkStock,                       inventory,                                pickUpData, 
  default0,                     pickUpDataFinish,           scanTasks,                        finishTasks,                              dataFormMonetization,
  dataFormGiveDatas,            deliveryOut,                incomingDeliveryNote
}
enum ButtonState{               hidden,                     loading,                          disabled,                                 error,
  default0
}
enum TaskState{                 askStorage,                 scanStorage,                      askProduct,                               scanProduct,
  barcodeManual,                inventory,                  listDeliveryNotes,                itemData,                                 default0,
  wrongItem,                    handleProduct,              scanDestinationStorage,           showPDF,                                  signature,
  dataForm,                     dataList
}
enum QuickCall{                 askBarcode,                 deleteItem,                       saveInventory,                            askInventoryDate,
  checkCode,                    checkStock,                 addItem,                          saveSignature,                            savePdf,
  giveDatas,                    chainGiveDatas,             finishGiveDatas,                  scanDestinationStorage,                   askAbroncs,
  print,                        checkArticle,               newEntry,                         verzio,                                   tabletBelep,
  addNewDeliveryNote,           addNewDeliveryNoteFinished, askDeliveryNotesScan,             addDeliveryNoteItem,                      chainGiveDatasDeliveryNote,
  addItemFinished,              plateNumberCheck,           printBarcodeDeliveryNote,         selectAddItemDeliveryNote,                finishSelectAddItemDeliveryNote,
  editSelectedItemDeliveryNote, askEditItemDeliveryNote,    finishSelectEditItemDeliveryNote, removeDeliveryNoteItemlogInNamePassword,  forgottenPassword,
  removeDeliveryNoteItem,       logInNamePassword,          changePassword, kiszedesFelviteleTarhely, logIn, saveDeliveryNoteItem
}
enum InDelNoteState{            addItem,                    listItems,                        addNew,                                   listSelectEditItemDeliveryNote,
  default0,                     editItem,                   listSelectAddItemDeliveryNote,
}
enum DialogResult{              cancel,                     back,                             mainMenu}
enum StockState{                checkStock,                 stockIn,                          default0}
enum ScannedCodeIs{             storage,                    article,                          unknown}
enum MainMenuState{                  default0,                   editPassword}
enum Work{incomingDeliveryNote, localMaintenance}


class Global{
  // ---------- < Variables [Static] > - ---------- ---------- ----------
  static List<NextRoute> _routes =          List<NextRoute>.empty(growable: true);
  static NextRoute get currentRoute =>      _routes.last;
  static NextRoute get previousRoute =>     (_routes.length >= 2)? _routes[_routes.length - 2] : _routes.first;
  static void get routeBack                 {_routes.removeLast(); _printRoutes;}
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
  
  // ---------- < Global Dialogs > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
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

  static Future<dynamic> logInDialog(BuildContext context, {String? userNameInput}) async{
    // --------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    String userName =                     (userNameInput != null)? userNameInput : '';
    String userPassword =                 '';
    bool isTextObscure =                  true;
    ButtonState buttonForgottenPassword = ButtonState.default0;
    BoxDecoration customBoxDecoration =       BoxDecoration(            
      border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color:        Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8))
    );

    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget okButton = TextButton(child: const Text('Ok'),     onPressed: () => Navigator.pop(context, {'userName': userName, 'userPassword': userPassword, 'buttonState': buttonForgottenPassword}));
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    
    // --------- < Display [2] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget drawContent() => StatefulBuilder(builder: (context, setState) => SingleChildScrollView(child: Column(children: (buttonForgottenPassword != ButtonState.loading)
    ?[
      Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        initialValue: userName,
        onChanged:    (value) => userName = value,
        decoration:   const InputDecoration(
          contentPadding: EdgeInsets.all(10),
          labelText:      'Felhasználónév',
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      const SizedBox(height: 4),
      Container(height: 65, decoration: customBoxDecoration, child: TextFormField(
        onChanged:    (value) => userPassword = value,
        obscureText:  isTextObscure,
        decoration:   InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      'Jelszó',
          border:         InputBorder.none,
          suffix:         TextButton(
            onPressed:  () => setState(() => isTextObscure = !isTextObscure),
            child:      Icon(
              Icons.remove_red_eye,
              size:   26,
              color:  (isTextObscure)? Global.getColorOfButton(ButtonState.default0) : Global.getColorOfButton(ButtonState.disabled),
            )
          )
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        TextButton(
          onPressed:  () => setState(() => buttonForgottenPassword = ButtonState.loading),
          child:      const Text('Elfelejtett jelszó', style: TextStyle(decoration: TextDecoration.underline)),
        )
      ])
    ]
    : [
      const Text('Elfelejtette jelszavát?', style: TextStyle(fontWeight: FontWeight.bold)),
      const Text('Kérjük adja meg regisztrált felhasználói nevét'),
      Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        initialValue: userName,
        onChanged:    (value) => userName = value,
        decoration:   const InputDecoration(
          contentPadding: EdgeInsets.all(10),
          labelText:      'Felhasználónév',
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      const SizedBox(height: 4),
    ])));

    // --------- < Display [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      title:    const Text('Bejelentkezés', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  drawContent(),
      actions:  [okButton, cancel]
    );

    // --------- < Return > ---- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  // ---------- < Global Methods > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
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
      case ButtonState.disabled:  return const Color.fromRGBO(0, 0, 0, 0.3);
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

  static String getErtek(List<dynamic> input, String entry, String value){
    for(dynamic item in input){
      if(item[entry] == value && item['ertek'] != null) return item['ertek'];
    }
    return '';
  }

  static String? getStringOrNullFromString(String value){
    if(['NULL', 'Null', 'null'].contains(value)) return null;
    return value;
  }

  static int getIntBoolFromString(String value) {switch(value){
    case '':
    case ' ':
    case 'FALSE':
    case 'False':
    case 'false':
    case '0':     return 0;
    default:      return 1;
  }}

  // ---------- < Methods [1] > -------- ---------- ---------- ----------
  static void get _printRoutes{
    String varString = 'IIIII: ';
    for (var item in _routes) {varString += '$item, ';}
    if(kDebugMode)print(varString);
  }
}
