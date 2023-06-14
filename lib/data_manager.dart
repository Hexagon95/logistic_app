// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logistic_app/routes/list_delivery_note.dart';
import 'package:logistic_app/routes/scan_inventory.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/routes/log_in.dart';
import 'package:logistic_app/routes/list_orders.dart';
import 'package:logistic_app/routes/list_pick_up_details.dart';
import 'package:logistic_app/routes/scan_orders.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';
import 'package:logistic_app/routes/data_form.dart';

class DataManager{
  // ---------- < Variables [Static] > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static String versionNumber =                           'v1.9.0';
  static String getPdfUrl(String id) =>                   "https://app.mosaic.hu/pdfgenerator/bizonylat.php?kategoria_id=3&id=$id&ceg=${data[0][1]['Ugyfel_id']}";
  static String get serverErrorText =>                    (isServerAvailable)? '' : 'Nincs kapcsolat!';
  static const String urlPath =                           'https://app.mosaic.hu/android/logistic_app/';        // Live
  //static const String urlPath =                           'https://developer.mosaic.hu/android/logistic_app/';  // Test
  static List<List<dynamic>> data =                       List<List<dynamic>>.empty(growable: true);
  static List<List<dynamic>> dataQuickCall =              List<List<dynamic>>.empty(growable: true);
  static bool isServerAvailable =                         true;
  static Identity? identity;

  // ---------- < Variables [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  final Map<String,String> headers = {'Content-Type': 'application/json'};
  dynamic input;
  QuickCall? quickCall;

  // ---------- < Constructors > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  DataManager({this.quickCall, this.input});

  // ---------- < Methods [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  
  static Future get identitySQLite async {
    final database = openDatabase(
      p.join(await getDatabasesPath(), 'unique_identity.db'),         
      onCreate:(db, version) => db.execute(Global.sqlCreateTableIdentity),
      version: 1
    );
    final db =                          await database;
    List<Map<String, dynamic>> result = await db.query('identityTable');
    if(result.isEmpty){
      identity = Identity.generate();
      await db.insert('identityTable', identity!.toMap, conflictAlgorithm: ConflictAlgorithm.replace);
      result = await db.query('identityTable');
    }
    identity = Identity(id: 0, identity: result[0]['identity'].toString());    
  }
  
  // ---------- < Methods [Public] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get beginQuickCall async{
    int check (int index) {while(dataQuickCall.length < index + 1) {dataQuickCall.add(List<dynamic>.empty());} return index;}
    try {
      isServerAvailable = true;
      switch(quickCall){        

        case QuickCall.askBarcode:
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'vonalkod':   ScanInventoryState.result!
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                  Uri.parse('${urlPath}ask_barcode.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);          
          dataQuickCall[check(0)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataQuickCall[0]);
          break;

        case QuickCall.deleteItem:
          var varJson = jsonDecode(data[1][0]['keszlet']);
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'cikk_id':    ScanInventoryState.rawData[ScanInventoryState.getSelectedIndex!]['kod'],
            'raktar_id':  varJson[0]['tarhely_id'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                  Uri.parse('${urlPath}delete_item.php');          
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          dataQuickCall[check(1)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataQuickCall[1]);
          break;

        case QuickCall.saveInventory:
          var varJson = jsonDecode(data[1][0]['keszlet']);
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'datum':      dataQuickCall[3][0]['leltar_van'],
            'cikk_id':    dataQuickCall[0][0]['result'][0]['id'].toString(),
            'raktar_id':  varJson[0]['tarhely_id'].toString(),
            'mennyiseg':  ScanInventoryState.currentItem!['keszlet'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                  Uri.parse('${urlPath}finish_inventory.php');          
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          dataQuickCall[check(2)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataQuickCall[2]);
          break;

        case QuickCall.askInventoryDate:
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString()
          };
          Uri uriUrl =                  Uri.parse('${urlPath}ask_inventory_date.php');          
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          dataQuickCall[check(3)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataQuickCall[3]);
          break;

        case QuickCall.checkStock:
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'tarhely_id': ScanCheckStockState.storageId
          };
          Uri uriUrl =                  Uri.parse('${urlPath}list_storage_check.php');          
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(4)] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[4].toString();
            print(varString);
          }
          break;

        case QuickCall.saveSignature:
          var queryParameters = {};
          switch(input['mode']){

            case 'signature': queryParameters = {
              'mode':     'signature',
              'customer': data[0][1]['Ugyfel_id'].toString(),
              'id':       ListDeliveryNoteState.getSelectedId,
              'alairas':  ListDeliveryNoteState.signatureBase64,
              'alairo':   ListDeliveryNoteState.signatureTextController.text
            }; break;

            case 'deliveryNote': queryParameters = {
              'mode':       'deliveryNote',
              'customer':   data[0][1]['Ugyfel_id'].toString(),
              'id':         ListDeliveryNoteState.getSelectedId,
              'fuvarlevel': ListDeliveryNoteState.signatureTextController.text
            }; break;

            default:break;
          }
          Uri uriUrl =                  Uri.parse('${urlPath}upload_signature.php');          
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(5)] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[5].toString();
            print(varString);
          }
          break;

        case QuickCall.scanDestinationStorage:
          var queryParameters =         input;
          queryParameters['customer'] = data[0][1]['Ugyfel_id'].toString();
          Uri uriUrl =                  Uri.parse('${urlPath}move_product.php');          
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(6)] =     await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[6].toString();
            print(varString);
          }
          break;

        default:break; 
      }
    }
    catch(e) {
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
    finally{
      await _decisionQuickCall;
    }
  }

  Future get beginProcess async{
    int check (int index) {while(data.length < index + 1) {data.add(List<dynamic>.empty());} return index;}
    try {
      isServerAvailable = true;
      switch(Global.currentRoute){

        case NextRoute.logIn:
          var queryParameters = {       
            'eszkoz_id':  identity.toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}login.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(0)] =          await jsonDecode(response.body);          
          if(kDebugMode){
            String varString = data[0].toString();
            print(varString);
          }
          break;

        case NextRoute.pickUpList:
          var queryParameters = {       
            'customer': data[0][1]['Ugyfel_id'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_pick_ups.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.orderList:
          var queryParameters = {       
            'customer': data[0][1]['Ugyfel_id'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_orders.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.deliveryNoteList:
          var queryParameters = {
            'customer':     data[0][1]['Ugyfel_id'].toString(),
            'dolgozo_kod':  data[0][1]['dolgozo_kod'].toString()
          };
          Uri uriUrl =              Uri.parse('${urlPath}list_delivery_notes.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode){
            String varString = data[1].toString();
            print(varString);
          }
          break;

        case NextRoute.inventory:
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'tarhely_id': ScanInventoryState.storageId,
            'datum':      dataQuickCall[3][0]['leltar_van']
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_storage.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);          
          data[check(1)] =          await jsonDecode(response.body);
          String varString = data[1].toString();
          if(kDebugMode)print(varString);
          break;

        case NextRoute.pickUpData:
          var queryParameters = {
            'customer':     data[0][1]['Ugyfel_id'].toString(),
            'bizonylat_id': data[1][ListOrdersState.getSelectedIndex!]['id']
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_pick_up_items.php');          
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(2)] =          await jsonDecode(response.body);          
          if(kDebugMode)print(data[2]);
          break;

        case NextRoute.pickUpDataFinish:          
          var queryParameters = {
            'customer':         data[0][1]['Ugyfel_id'].toString(),
            'kiszedesi_lista':  json.encode(_kiszedesiLista)
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}finish_pick_ups.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(3)] =          await jsonDecode(response.body);          
          if(kDebugMode)print(data[3]);
          break;

        case NextRoute.scanTasks:
          var queryParameters = {
            'customer':     data[0][1]['Ugyfel_id'].toString(),
            'bizonylat_id': data[1][ListOrdersState.getSelectedIndex!]['id']
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_order_items.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(2)] =          await jsonDecode(response.body);          
          if(kDebugMode)print(data[2]);
          break;

        case NextRoute.finishTasks:
          var queryParameters = {
            'customer':         data[0][1]['Ugyfel_id'].toString(),
            'completed_tasks':  json.encode({
              'id':       data[1][ListOrdersState.getSelectedIndex!]['id'],
              'tetelek':  _cropCompletedTasks
            })
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}finish_orders.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(3)] =          await jsonDecode(response.body);          
          if(kDebugMode)print(data[3]);
          break;

        default:break;
      }
    }
    catch(e) {
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
    finally{
      await _decision;        
    }
  }

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _decisionQuickCall async{
    try {
      switch(quickCall){

        case QuickCall.scanDestinationStorage:
          if(dataQuickCall[6][0]['success'] == 1){
            ScanCheckStockState.storageToExist =  true;
            ScanCheckStockState.result =          null;
            ScanCheckStockState.selectedIndex =   null;
            DataFormState.amount =                null;
          }
          else{
            ScanCheckStockState.storageToExist =  false;
          }
          break;

        case QuickCall.askBarcode:
          ScanInventoryState.barcodeResult = (dataQuickCall[0][0]['result'].isEmpty)
            ? null
            : dataQuickCall[0][0]['result'];
          break;

        case QuickCall.checkStock:
          if (dataQuickCall[4][0]['error'] == null){ 
            ScanCheckStockState.rawData =           [jsonDecode(dataQuickCall[4][0]['b'].toString())];
            ScanCheckStockState.storageFromExist =  true;
          }
          else{
            ScanCheckStockState.storageFromExist =  false;
          }
          break;

        default:break;
      }
    }
    catch(e){
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
  }

  Future get _decision async{
    try {
      switch(Global.currentRoute){

        case NextRoute.logIn:          
          LogInMenuState.errorMessageBottomLine = data[0][0]['error'];
          break;        

        case NextRoute.pickUpList:
        case NextRoute.orderList:
          ListOrdersState.rawData = data[1];
          break;

        case NextRoute.inventory:        
          var varJson =                 jsonDecode(data[1][0]['keszlet']);
          ScanInventoryState.rawData =  (varJson[0]['tetelek'] != null)? varJson[0]['tetelek'] : <dynamic>[];
          break;
        
        case NextRoute.deliveryNoteList:
          ListDeliveryNoteState.rawData = jsonDecode(data[1][0]['tetel'])['tetelek'];
          if(kDebugMode){
            String varString = ListDeliveryNoteState.rawData.toString();
            print(varString);
          }
          break;

        case NextRoute.pickUpData:          
          ListPickUpDetailsState.rawData =      (data[2][0]['tetelek'] != null)? jsonDecode(data[2][0]['tetelek']) : <dynamic>[];          
          ListPickUpDetailsState.orderNumber =  data[1][ListOrdersState.getSelectedIndex!]['sorszam'];          
          break;

        case NextRoute.scanTasks:
          ScanOrdersState.rawData =           (jsonDecode(data[2][0]['tetelek']) != null)? jsonDecode(data[2][0]['tetelek']) : <dynamic>[];
          ScanOrdersState.progressOfTasks =   List<bool>.empty(growable: true);
          Iterator iterator =                 ScanOrdersState.rawData.iterator; while(iterator.moveNext()){
            ScanOrdersState.progressOfTasks.add(false);
          }
          ScanOrdersState.currentTask = (ScanOrdersState.rawData.isNotEmpty)? 0 : null;
          break;

        case NextRoute.dataFormMonetization:
          _generateRawDataForScanCheckStockDataForm(ScanCheckStockState.rawData[0]['tetelek'][ScanCheckStockState.selectedIndex!]);
          break;

        default:break;
      }
    }
    catch(e){
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
  }

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<dynamic> get _kiszedesiLista{
    List<dynamic> result = List<dynamic>.empty(growable: true);
    for (var i = 0; i < ListPickUpDetailsState.rawData.length; i++) {if(ListPickUpDetailsState.selections[i]){
      result.add({
        'bizonylat_id': data[1][ListOrdersState.getSelectedIndex!]['id'],
        'tetel_id':     ListPickUpDetailsState.rawData[i]['tetel_id'],
        'mennyiseg':    ListPickUpDetailsState.rawData[i]['mennyiseg'],
      });
    }}
    return result;
  }

  List<dynamic> get _cropCompletedTasks{
    List<dynamic> result = List<dynamic>.empty(growable: true);
    for (var i = 0; i < ScanOrdersState.progressOfTasks.length; i++) {if(ScanOrdersState.progressOfTasks[i]) result.add(ScanOrdersState.rawData[i]);}
    return result;
  }

  void _generateRawDataForScanCheckStockDataForm(dynamic input){
    List<dynamic> varList = List<dynamic>.empty(growable: true);
    int valueInt =       int.parse(input['keszlet'].toString());
    DataFormState.title =   'ip kód:   ${input['ip'].toString()}';
    varList.add({
      'input_field':  'text',
      'name':         'cikknév',
      'value':        input['cikknev'].toString(),
      'editable':     '0',
    });
    varList.add({
      'input_field':  'integer',
      'name':         'készlet',
      'value':        valueInt,
      'limit':        valueInt,
      'editable':     '1',
    });
    DataFormState.rawData = varList;
  }
}


class Identity{
  // ---------- < Variables > ---------- ---------- ---------- ----------
  int id =            0;
  String identity =   '';

  // ---------- < Constructors > ------- ---------- ---------- ----------
  Identity({required this.id, required this.identity});
  Identity.generate(){
    identity = generateRandomString();
  }

  // ---------- < Methods [1] > -------- ---------- ---------- ----------
  Map<String, dynamic> get toMap => {
    'id':         id,
    'identity':   identity
  };

  String generateRandomString({int length = 32}){
    final random =    Random();
    const charList =  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';    

    return List.generate(length,
      (index) => charList[random.nextInt(charList.length)]
    ).join();
  }
  @override
  String toString() => identity;
}