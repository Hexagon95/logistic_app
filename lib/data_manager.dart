// ignore_for_file: depend_on_referenced_packages, avoid_print
import 'package:flutter/material.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/routes/incoming_deliverynote.dart';
import 'package:logistic_app/routes/menu.dart';
import 'package:logistic_app/routes/log_in.dart';
import 'package:logistic_app/routes/data_form.dart';
import 'package:logistic_app/routes/scan_orders.dart';
import 'package:logistic_app/routes/list_orders.dart';
import 'package:logistic_app/routes/scan_inventory.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';
import 'package:logistic_app/routes/list_delivery_note.dart';
import 'package:logistic_app/routes/list_pick_up_details.dart';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DataManager{
  // ---------- < Variables [Static] > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static String thisVersion =                             '1.23';
  static String actualVersion =                           thisVersion;
  static const String newEntryId =                        '0';
  static String customer =                                'mosaic';
  static String raktarMegnevezes=                         '';
  static String raktarId =                                '';
  static String getPdfUrl(String id) =>                   "https://app.mosaic.hu/pdfgenerator/bizonylat.php?kategoria_id=3&id=$id&ceg=${data[0][1]['Ugyfel_id']}";
  static String get serverErrorText =>                    (isServerAvailable)? '' : 'Nincs kapcsolat!';
  static String get sqlUrlLink =>                         'https://app.mosaic.hu/sql/ExternalInputChangeSQL.php?ceg=mezandmol&SQL=';
  //static const String urlPath =                           'https://app.mosaic.hu/android/logistic_app/';        // Live
  static const String urlPath =                           'https://developer.mosaic.hu/android/logistic_app/';  // Test
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

  static ButtonState get setButtonSave {
    for(var item in DataFormState.rawData){
      if(item['mandatory'].toString() == '1' && (item['value'] == null || item['value'].toString().isEmpty)){
        return ButtonState.disabled;
      }
    }
    return ButtonState.default0;
  }
  
  // ---------- < Methods [Public] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get beginQuickCall async{
    int check (int index) {while(dataQuickCall.length < index + 1) {dataQuickCall.add(List<dynamic>.empty());} return index;}
    try {
      isServerAvailable = true;
      switch(quickCall){

        case QuickCall.verzio:
          var queryParameters = {
            'customer':   customer,
          };
          Uri uriUrl =                    Uri.parse('${urlPath}verzio.php');
          http.Response response =        await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          actualVersion =                 jsonDecode(response.body)[0]['verzio_logistic_app'].toString();
          LogInMenuState.updateNeeded =   (thisVersion != actualVersion);
          break;

        case QuickCall.tabletBelep:
          var queryParameters = {
            'customer':   customer,
            'eszkoz_id':  identity.toString(),
            'verzio':     thisVersion
          };
          Uri uriUrl = Uri.parse('${urlPath}tablet_belep.php');
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(30)] =  [response.reasonPhrase];
          break;

        case QuickCall.askBarcode:
          var queryParameters = {
            'customer':   customer,
            'vonalkod':   ScanInventoryState.result!
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}ask_barcode.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(0)] = await jsonDecode(response.body);
          if(kDebugMode)print(dataQuickCall[0]);
          break;

        case QuickCall.deleteItem:
          var varJson = jsonDecode(data[1][0]['keszlet']);
          var queryParameters = {
            'customer':   customer,
            'cikk_id':    ScanInventoryState.rawData[ScanInventoryState.getSelectedIndex!]['kod'],
            'raktar_id':  varJson[0]['tarhely_id'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =               Uri.parse('${urlPath}delete_item.php');
          http.Response response =   await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          dataQuickCall[check(1)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataQuickCall[1]);
          break;

        case QuickCall.saveInventory:
          var varJson = jsonDecode(data[1][0]['keszlet']);
          var queryParameters = {
            'customer':   customer,
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
            'customer':   customer
          };
          Uri uriUrl =               Uri.parse('${urlPath}ask_inventory_date.php');
          http.Response response =   await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          dataQuickCall[check(3)] =  await jsonDecode(response.body);
          if(kDebugMode)print(dataQuickCall[3]);
          break;

        case QuickCall.checkStock:
          ScanCheckStockState.storageId = ScanCheckStockState.savedStorageId;
          var queryParameters = {
            'customer':   customer,
            'tarhely_id': ScanCheckStockState.storageId.toString(),
            'raktar_id':  raktarId
          };
          Uri uriUrl =              Uri.parse('${urlPath}list_storage_check.php');          
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(4)] = [await jsonDecode(await jsonDecode(response.body)[0]['b'])];
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
              'customer': customer,
              'id':       ListDeliveryNoteState.getSelectedId,
              'alairas':  ListDeliveryNoteState.signatureBase64,
              'alairo':   ListDeliveryNoteState.signatureTextController.text
            }; break;

            case 'deliveryNote': queryParameters = {
              'mode':       'deliveryNote',
              'customer':   customer,
              'id':         ListDeliveryNoteState.getSelectedId,
              'fuvarlevel': ListDeliveryNoteState.signatureTextController.text
            }; break;

            default:break;
          }
          Uri uriUrl =               Uri.parse('${urlPath}upload_signature.php');          
          http.Response response =   await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(5)] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[5].toString();
            print(varString);
          }
          break;

        case QuickCall.scanDestinationStorage:
          var queryParameters =           input;
          queryParameters['customer'] =   customer;
          queryParameters['raktar_id'] =  raktarId;
          Uri uriUrl =                    Uri.parse('${urlPath}move_product.php');
          http.Response response =        await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(6)] =       await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[6].toString();
            print(varString);
          }
          break;

        case QuickCall.savePdf:
          var queryParameters = {
            'customer':   customer,
            'id':         ListDeliveryNoteState.getSelectedId,
            'pdf':        base64Encode(File(ListDeliveryNoteState.pdfPath!).readAsBytesSync())
          };
          Uri uriUrl =              Uri.parse('${urlPath}upload_pdf.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(queryParameters);
          dataQuickCall[check(7)] = await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[7].toString();
            print(varString);
          }
          break;

        case QuickCall.addItem:
          var queryParameters = {
            'customer':   customer,
            'tarhely_id': ScanCheckStockState.storageId.toString(),
            'cikk_id':    ScanCheckStockState.itemId.toString(),
            'mennyiseg':  1,
            'user_id':    1
          };
          Uri uriUrl =              Uri.parse('${urlPath}add_item.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(8)] = await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[8].toString();
            print(varString);
          }
          break;

        case QuickCall.giveDatas:
          var queryParameters = {
            'customer':   customer,
            'id':         (ScanCheckStockState.scannedCode == ScannedCodeIs.storage)
              ? ScanCheckStockState.rawData[0]['tetelek'][ScanCheckStockState.selectedIndex]['id']
              : ScanCheckStockState.storageId.toString()
            ,
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}give_datas.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(9)] = await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[9].toString();
            print(varString);
          }
          break;

        case QuickCall.newEntry:
          ScanCheckStockState.storageId = newEntryId;
          var queryParameters = {
            'customer':   customer,
            'id':         newEntryId,
            'tarhely_id': dataQuickCall[13][0]['id'].toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}new_entry.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(9)] = await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[9].toString();
            print(varString);
          }
          quickCall = QuickCall.giveDatas;
          break;

        case QuickCall.finishGiveDatas:
          var queryParameters = {
            'customer':   customer,
            'parameter':  jsonEncode([DataFormState.rawData, DataFormState.rawData2])
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('$urlPath${(ScanCheckStockState.storageId == newEntryId)? 'finish_new_entry.php' :'finish_give_datas.php'}');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(10)] = await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[10].toString();
            print(varString);
          }
          break;

        case QuickCall.askAbroncs:
          bool isNewEntry = (ScanCheckStockState.storageId == newEntryId);
          var queryParameters = {
            'customer': customer,
            'id':       !isNewEntry
              ? (ScanCheckStockState.scannedCode == ScannedCodeIs.storage)
                ? ScanCheckStockState.rawData[0]['tetelek'][ScanCheckStockState.selectedIndex]['id']
                : ScanCheckStockState.storageId.toString()
              : DataFormState.carId.toString()
            ,
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('$urlPath${isNewEntry ? 'ask_abroncs_new_entry.php' : 'ask_abroncs.php'}');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(11)] = await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[11].toString();
            print(varString);
          }
          break;

        case QuickCall.print:
          var queryParameters = {
            'customer': customer,
            'tarhely':  ScanCheckStockState.storageId,
            'idk':      jsonEncode(ScanCheckStockState.selectedIds),
            'type':     (ScanCheckStockState.scannedCode == ScannedCodeIs.article)? 'article' : 'storage'
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}print.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(12)] = await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[12].toString();
            print(varString);
          }
          break;

        case QuickCall.checkCode:
          var queryParameters = {
            'customer':   customer,
            'code':       ScanCheckStockState.storageId.toString(),
            'raktar_id':  raktarId
          };
          Uri uriUrl =                Uri.parse('${urlPath}check_code.php');          
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(13)] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[13].toString();
            print(varString);
          }
          break;

        case QuickCall.checkArticle:
          var queryParameters = {
            'customer':   customer,
            'id':         dataQuickCall[13][0]['id'].toString(),
            'raktar_id':  raktarId
          };
          Uri uriUrl =                Uri.parse('${urlPath}check_article.php');
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(14)] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = dataQuickCall[14].toString();
            print(varString);
          }
          break;

        case QuickCall.addNewDeliveryNote:
          var queryParameters = {
            'customer':   customer,
            'raktar_id':  raktarId
          };
          Uri uriUrl =                Uri.parse('${urlPath}add_new_delivery_note.php');          
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(15)] =  await jsonDecode(response.body);
          break;

        case QuickCall.addNewDeliveryNoteFinished:
          var queryParameters = {
            'customer':   customer,
            'parameter':  json.encode(IncomingDeliveryNoteState.rawDataDataForm)
          };
          Uri uriUrl =                Uri.parse('${urlPath}add_new_delivery_note_finish.php');          
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode){
            print(response.body);
          }
          break;

        case QuickCall.askDeliveryNotesScan:
          var queryParameters = {
            'customer':     customer,
            'bizonylat_id': IncomingDeliveryNoteState.rawDataListDeliveryNotes[IncomingDeliveryNoteState.getSelectedIndex!]['id'].toString()
          };
          Uri uriUrl =                Uri.parse('${urlPath}ask_delivery_notes_scan.php');          
          http.Response response =    await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          dataQuickCall[check(16)] =  await jsonDecode(response.body);
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
    int check(int index) {while(data.length < index + 1) {data.add(List<dynamic>.empty());} return index;}
    try {
      isServerAvailable = true;
      switch(Global.currentRoute){

        case NextRoute.logIn:
          var queryParameters = {
            'customer':   customer,
            'eszkoz_id':  identity.toString()
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =                    Uri.parse('${urlPath}login.php');
          http.Response response =        await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(input['number'])] =  await jsonDecode(response.body);
          if(kDebugMode){
            String varString = data[input['number']].toString();
            print(varString);
          }
          break;

        case NextRoute.pickUpList:
          var queryParameters = {       
            'customer': customer
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_pick_ups.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          if(kDebugMode)print(response.body);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.orderOutList:
          var queryParameters = {
            'customer':   customer,
            'raktar_id':  raktarId
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_orders_out.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.deliveryOut:
          var queryParameters = {
            'customer':   customer,
            'raktar_id':  raktarId
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_delivery_out.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.incomingDeliveryNote:
          var queryParameters = {
            'customer':   customer,
            'raktar_id':  raktarId
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}incoming_delivery_note.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.orderList:
          var queryParameters = {       
            'customer':   customer,
            'raktar_id':  raktarId
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}list_orders.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(1)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[1]);
          break;

        case NextRoute.deliveryNoteList:
          var queryParameters = {
            'customer':     customer,
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
            'customer':   customer,
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
            'customer':     customer,
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
            'customer':         customer,
            'kiszedesi_lista':  json.encode(_kiszedesiLista)
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('${urlPath}finish_pick_ups.php');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(3)] =          await jsonDecode(response.body);          
          if(kDebugMode)print(data[3]);
          break;

        case NextRoute.scanTasks:
          String phpFileName() {switch(input['route']){
            case NextRoute.orderList:     return 'list_order_items.php';
            case NextRoute.deliveryOut:   return 'list_delivery_out_items.php';
            case NextRoute.orderOutList:  return 'list_order_out_items.php';
            default: return '';
          }}
          var queryParameters = {
            'customer':     customer,
            'bizonylat_id': data[1][ListOrdersState.getSelectedIndex!]['id']
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('$urlPath${phpFileName()}');
          http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
          data[check(2)] =          await jsonDecode(response.body);
          if(kDebugMode)print(data[2]);
          break;

        case NextRoute.finishTasks:
          String phpFileName() {switch(input['route']){
            case NextRoute.orderList:     return 'finish_orders.php';
            case NextRoute.deliveryOut:   return 'finish_delivery_out_items.php';
            case NextRoute.orderOutList:  return 'finish_orders_out.php';
            default: return '';
          }}
          var queryParameters = {
            'customer':         customer,
            'completed_tasks':  json.encode({
              'id':       data[1][ListOrdersState.getSelectedIndex!]['id'],
              'tetelek':  _cropCompletedTasks
            })
          };
          if(kDebugMode)print(queryParameters);
          Uri uriUrl =              Uri.parse('$urlPath${phpFileName()}');
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
            DataFormState.amount =                null;
            for(int i = 0; i < ScanCheckStockState.selectionList.length; i++) {ScanCheckStockState.selectionList[i] = false;}
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
            ScanCheckStockState.rawData =           dataQuickCall[4];
            ScanCheckStockState.selectionList =     List.filled(dataQuickCall[4][0]['tetelek'].length, false);
            ScanCheckStockState.storageFromExist =  true;
          }
          else{
            ScanCheckStockState.storageFromExist =  false;
          }
          break;

        case QuickCall.addItem:
          ScanCheckStockState.messageData = {};
          if(isServerAvailable && dataQuickCall[8].isNotEmpty) {
            List<dynamic> result = json.decode(dataQuickCall[8][0]['result']);
            ScanCheckStockState.messageData = {
              'title':    result[0]['name'],
              'content':  (result[0]['row'].toString().isNotEmpty)? result[0]['row'] : result[0]['message']
            };
          }
          break;

        case QuickCall.giveDatas:
          DataFormState.rawData =           jsonDecode(dataQuickCall[9][0]['b'])['adatok'];
          DataFormState.listOfLookupDatas = <String, dynamic>{};
          for(dynamic item in DataFormState.rawData){
            if(!['select','search'].contains(item['input_field'])) continue;
            DataFormState.listOfLookupDatas[item['id']] = await _getLookupData(input: item['lookup_data'], isPhp: (item['php'].toString() == '1'));
          }
          if(kDebugMode)print(DataFormState.listOfLookupDatas);
          break;

        case QuickCall.chainGiveDatas:
          int getIndexFromId({required String id}) {for(int i = 0; i < DataFormState.rawData.length; i++) {if(DataFormState.rawData[i]['id'] == id) return i;} throw Exception('No such id in rawData: $id');}

          for(dynamic item in DataFormState.rawData[input['index']]['update_items']) {
            switch(item['callback']){

              case 'refresh':
                dynamic result = await _getLookupData(input: item['lookup_data'], isPhp: (item['php'].toString() == '1'));
                if(result.isNotEmpty){
                  DataFormState.rawData[getIndexFromId(id: item['id'])]['value'] =  result[0]['megnevezes'];
                  DataFormState.rawData[getIndexFromId(id: item['id'])]['kod'] =    result[0]['id'];
                }
                else{
                  DataFormState.rawData[getIndexFromId(id: item['id'])]['value'] =  null;
                  DataFormState.rawData[getIndexFromId(id: item['id'])]['kod'] =    null;
                }
                break;

              default:
                DataFormState.listOfLookupDatas[item['id']] = await _getLookupData(input: item['lookup_data'], isPhp: (item['php'].toString() == '1'));
                DataFormState.rawData[getIndexFromId(id: item['id'])]['value'] =  null;
                break;
            }
            if(DataFormState.rawData[input['index']]['value'].toString() == 'Igen') DataFormState.carId = '';
          }
          for(MapEntry<String, dynamic> item in DataFormState.listOfLookupDatas.entries) {for(int i = 0; i < DataFormState.rawData.length; i++){
            try{
              if(DataFormState.rawData[i]['id'] == item.key){
                if(DataFormState.rawData[i]['input_field'] == 'text'){
                  DataFormState.rawData[i]['value'] = (item.value[0]['id'] == null)? '' : item.value[0]['id'].toString();
                  break;
                }
                if(['select','search'].contains(DataFormState.rawData[i]['input_field'])){
                  if(item.value.isEmpty || item.value[0]['id'] == null){
                    DataFormState.listOfLookupDatas[item.key] = List<dynamic>.empty();
                  }
                  else {for(var item in item.value){
                    if(item['selected'] != null && item['selected'].toString() == '1') {DataFormState.rawData[i]['value'] = item['id']; break;}
                  }}
                  break;
                }
              }
            }
            catch(e){
              if(kDebugMode) print('${item.key}\n$e');
            }
          }}
          break;

        case QuickCall.askAbroncs:
          DataFormState.rawData2 =            [json.decode(dataQuickCall[11][0]['result'][0]['b'])];
          if(DataFormState.carId.isNotEmpty || ScanCheckStockState.storageId != newEntryId)  DataFormState.taskState = TaskState.dataList;
          break;

        case QuickCall.checkCode:
          ScanCheckStockState.scannedCode =
            (dataQuickCall[13][0]['tarhely'].toString() == '1')?  ScannedCodeIs.storage
            : (dataQuickCall[13][0]['cikk'].toString() == '1')?   ScannedCodeIs.article
            : ScannedCodeIs.unknown;
          break;

        case QuickCall.checkArticle:
          ScanCheckStockState.rawData = jsonDecode(dataQuickCall[14][0]['tetelek']);
          break;

        case QuickCall.addNewDeliveryNote:
          IncomingDeliveryNoteState.rawDataDataForm = json.decode(dataQuickCall[15][0]['b'])['adatok'];
          IncomingDeliveryNoteState.controller =      List<TextEditingController>.empty(growable: true);
          for(int i = 0; i < IncomingDeliveryNoteState.rawDataDataForm.length; i++){
            IncomingDeliveryNoteState.controller.add(TextEditingController(text: ''));
          }
          IncomingDeliveryNoteState.listOfLookupDatas = <String, dynamic>{};
          for(dynamic item in IncomingDeliveryNoteState.rawDataDataForm){
            if(!['select','search'].contains(item['input_field'])) continue;
            IncomingDeliveryNoteState.listOfLookupDatas[item['id']] = await _getLookupDataDeliveryNote(input: item['lookup_data'], isPhp: (item['php'].toString() == '1'));
          }
          if(kDebugMode)print(IncomingDeliveryNoteState.listOfLookupDatas);
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
          LogInMenuState.errorMessageBottomLine = data[input['number']][0]['error'].toString();
          if(LogInMenuState.errorMessageBottomLine.isEmpty && data[input['number']].isNotEmpty) {switch(input['number']){

            case 0:
              customer = data[0][1]['Ugyfel_id'].toString();
              if(data[0][1]['scanner'] != null) Global.isScannerDevice = (data[0][1]['scanner'].toString() == '1');
              MenuState.menuList = jsonDecode(data[0][1]['menu']);
              if(data[0][1]['szin'] != null){
                List<int> inputColor = data[0][1]['szin'].toString().split(',').map(int.parse).toList();
                Global.customColor[ButtonState.default0] = Color.fromRGBO(inputColor[0], inputColor[1], inputColor[2], 1.0);
                Global.customColor[ButtonState.disabled] = Color.fromRGBO(inputColor[0], inputColor[1], inputColor[2], 0.25);
                Global.customColor[ButtonState.loading] =  Global.invertColor(Global.getColorOfButton(ButtonState.default0));
              }
              break;

            case 4:
              raktarMegnevezes =  data[4][1]['raktar_megnevezes'].toString();
              raktarId =          data[4][1]['raktar_id'].toString();
              break;

            default:break;
          }}
          break;

        case NextRoute.pickUpList:
        case NextRoute.orderOutList:
        case NextRoute.deliveryOut:
        case NextRoute.orderList:
          ListOrdersState.rawData = data[1];
          break;
        
        case NextRoute.incomingDeliveryNote:
          IncomingDeliveryNoteState.rawDataListDeliveryNotes = data[1];
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

        case NextRoute.scanTasks: switch(Global.isScannerDevice){

          case true:
            ScanOrdersState.rawData =         (jsonDecode(data[2][0]['tetelek']) != null)? jsonDecode(data[2][0]['tetelek']) : <dynamic>[];
            ScanOrdersState.listOfStorages =  List<String>.empty(growable: true);
            for(var item in ScanOrdersState.rawData){
              if(!ScanOrdersState.listOfStorages.contains(item['tarhely'].toString())) ScanOrdersState.listOfStorages.add(item['tarhely'].toString());
            }
            if(kDebugMode)print(ScanOrdersState.listOfStorages);
            ScanOrdersState.currentStorage =  0;
            break;

          case false: 
            ScanOrdersState.rawData =         (jsonDecode(data[2][0]['tetelek']) != null)? jsonDecode(data[2][0]['tetelek']) : <dynamic>[];
            ScanOrdersState.progressOfTasks = List<bool>.empty(growable: true);
            Iterator iterator =               ScanOrdersState.rawData.iterator; while(iterator.moveNext()){
              ScanOrdersState.progressOfTasks.add(false);
            }
            ScanOrdersState.currentTask =     (ScanOrdersState.rawData.isNotEmpty)? 0 : null;
            break;

          default: break;
        } break;

        default:break;
      }
    }
    catch(e){
      if(kDebugMode)print('$e');
      isServerAvailable = false;
    }
  }

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<dynamic> _getLookupData({required String input, required bool isPhp}) async{
    String sqlCommand = input.replaceAll(
      "[id]",
      (ScanCheckStockState.scannedCode == ScannedCodeIs.storage && ScanCheckStockState.selectedIndex != null)
        ? ScanCheckStockState.rawData[0]['tetelek'][ScanCheckStockState.selectedIndex]['id'].toString()
        : ScanCheckStockState.storageId.toString()
      ,
    );
    for(var item in DataFormState.rawData){
      String pattern =  '[${item['id'].toString()}]';
      sqlCommand =      sqlCommand.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
      pattern =         '[jellemzo_${item['jellemzo_id'].toString()}]';
      sqlCommand =      sqlCommand.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
    }
        
    try {if(isPhp){
      Uri uriUrl =              Uri.parse(Uri.encodeFull('$sqlUrlLink$sqlCommand').replaceAll('+', '%2b'));
      if(kDebugMode)print(uriUrl.toString());
      http.Response response =  await http.post(uriUrl);
      dynamic result =          await jsonDecode(response.body);
      if(kDebugMode)print(result);
      return result;
    }
    else{
      if(sqlCommand.isEmpty) return [];
      var queryParameters = {
        'customer': customer,
        'sql':      sqlCommand
      };
      if(kDebugMode)print(sqlCommand);
      Uri uriUrl =              Uri.parse('${urlPath}select_sql.php');          
      http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
      if(kDebugMode)print(response.body);
      dynamic result =          await jsonDecode(response.body)[0]['result'];
      if(kDebugMode)print(result);
      return result;
    }}
    catch(e) {print(e); return [];}
  }

  Future<dynamic> _getLookupDataDeliveryNote({required String input, required bool isPhp}) async{
    for(var item in DataFormState.rawData){
      String pattern =  '[${item['id'].toString()}]';
      input =           input.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
      pattern =         '[jellemzo_${item['jellemzo_id'].toString()}]';
      input =           input.replaceAll(pattern, '\'${(item['kod'] == null)? item['value'].toString() : item['kod'].toString()}\'');
    }
        
    try {if(isPhp){
      Uri uriUrl =              Uri.parse(Uri.encodeFull('$sqlUrlLink$input').replaceAll('+', '%2b'));
      if(kDebugMode)print(uriUrl.toString());
      http.Response response =  await http.post(uriUrl);
      dynamic result =          await jsonDecode(response.body);
      if(kDebugMode)print(result);
      return result;
    }
    else{
      if(input.isEmpty) return [];
      var queryParameters = {
        'customer': customer,
        'sql':      input
      };
      if(kDebugMode)print(input);
      Uri uriUrl =              Uri.parse('${urlPath}select_sql.php');          
      http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
      if(kDebugMode)print(response.body);
      dynamic result =          await jsonDecode(response.body)[0]['result'];
      if(kDebugMode)print(result);
      return result;
    }}
    catch(e) {print(e); return [];}
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

  List<dynamic> get _cropCompletedTasks {switch(Global.isScannerDevice){

    case false:
      List<dynamic> result = List<dynamic>.empty(growable: true);
      for (int i = 0; i < ScanOrdersState.progressOfTasks.length; i++) {if(ScanOrdersState.progressOfTasks[i]) result.add(ScanOrdersState.rawData[i]);}
      return result;

    case true:  return ScanOrdersState.completedTasks;
    default:    return List<dynamic>.empty();
  }} 
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

    if(kDebugMode) {return 'b3bxs9or8CVlpdBlDGSflNwqWdz9tfz3';}
    else{
      return List.generate(length,
        (index) => charList[random.nextInt(charList.length)]
      ).join();
    }
  }
  
  @override
  String toString() => identity;
}