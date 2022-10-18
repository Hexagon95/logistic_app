// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logistic_app/routes/scan_inventory.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/routes/log_in.dart';
import 'package:logistic_app/routes/list_orders.dart';
import 'package:logistic_app/routes/list_pick_up_details.dart';
import 'package:logistic_app/routes/scan_orders.dart';

class DataManager{
  // ---------- < Variables [Static] > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static String versionNumber =                 'v1.7.0';
  static List<List<dynamic>> data =             List<List<dynamic>>.empty(growable: true);
  static List<List<dynamic>> dataInterMission = List<List<dynamic>>.empty(growable: true);
  static bool isServerAvailable =               true;
  static const String urlPath =                 'https://app.mosaic.hu/android/logistic_app/';    // Live
  //static const String urlPath =                 'http://app.mosaic.hu:81/android/logistic_app/';  // Test
  static String get serverErrorText =>          (isServerAvailable)? '' : 'Nincs kapcsolat!';
  static Identity? identity;  

  // ---------- < Variables [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  
  final Map<String,String> headers =  {'Content-Type': 'application/json'};
  InterMission? interMission;

  // ---------- < Constructors > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  DataManager({this.interMission});

  // ---------- < Methods [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  
  
  // ---------- < Methods [Public] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get beginInterMission async{
    int check (int index) {while(dataInterMission.length < index + 1) {dataInterMission.add(List<dynamic>.empty());} return index;}
    try {
      isServerAvailable = true;
      switch(interMission){        

        case InterMission.askBarcode:
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'vonalkod':   ScanInventoryState.result!
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                  Uri.parse('${urlPath}ask_barcode.php');
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);          
          dataInterMission[check(0)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataInterMission[0]);
          break;

        case InterMission.deleteItem:
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
          dataInterMission[check(1)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataInterMission[1]);
          break;

        case InterMission.saveInventory:
          var varJson = jsonDecode(data[1][0]['keszlet']);
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'cikk_id':    dataInterMission[0][0]['result'][0]['id'].toString(),
            'raktar_id':  varJson[0]['tarhely_id'].toString(),
            'mennyiseg':  ScanInventoryState.currentItem!['keszlet'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                  Uri.parse('${urlPath}finish_inventory.php');          
          http.Response response =      await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          dataInterMission[check(2)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataInterMission[2]);
          break;

        default:break; 
      }
    }
    catch(e) {
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
    finally{
      await _decisionInterMission;
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
          if(kDebugMode)print(data[0]);
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

        case NextRoute.listOrders:
          var queryParameters = {       
            'customer': data[0][1]['Ugyfel_id'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_orders.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.inventory:
          var queryParameters = {
            'customer':   data[0][1]['Ugyfel_id'].toString(),
            'tarhely_id': ScanInventoryState.storageId
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_storage.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);          
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
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

  Future get _decisionInterMission async{
    try {
      switch(interMission){

        case InterMission.askBarcode:
          ScanInventoryState.barcodeResult = (dataInterMission[0][0]['result'].isEmpty)
            ? null
            : dataInterMission[0][0]['result'];
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
        case NextRoute.listOrders:
          ListOrdersState.rawData = data[1];
          break;

        case NextRoute.inventory:        
          var varJson =                 jsonDecode(data[1][0]['keszlet']);
          ScanInventoryState.rawData =  (varJson[0]['tetelek'] != null)? varJson[0]['tetelek'] : <dynamic>[];
          break;

        case NextRoute.pickUpData:
          ListPickUpDetailsState.rawData =      (data[2][0]['tetelek'] != null)? jsonDecode(data[2][0]['tetelek']) : <dynamic>[];
          ListPickUpDetailsState.orderNumber =  data[1][ListOrdersState.getSelectedIndex!]['sorszam'];          
          break;

        case NextRoute.scanTasks:
          ScanOrdersState.rawData =          (jsonDecode(data[2][0]['tetelek']) != null)? jsonDecode(data[2][0]['tetelek']) : <dynamic>[];
          ScanOrdersState.progressOfTasks =  List<bool>.empty(growable: true);
          Iterator iterator = ScanOrdersState.rawData.iterator; while(iterator.moveNext()){
            ScanOrdersState.progressOfTasks.add(false);
          }
          ScanOrdersState.currentTask = (ScanOrdersState.rawData.isNotEmpty)? 0 : null;
          break;

        default:break;
      }
    }
    catch(e){
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
  }

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

  // ---------- < Methods [2] > -------- ---------- ---------- ----------  
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