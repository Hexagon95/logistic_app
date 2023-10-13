import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScannerHardware{
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ----------
  static const EventChannel scanChannel =     EventChannel('com.darryncampbell.datawedgeflutter/scan');
  static const MethodChannel methodChannel =  MethodChannel('com.darryncampbell.datawedgeflutter/command');

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
  String symbology =  "";
  String scanData =   "";
  String dateTime =   "";
  String? errorMessage;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ScannerHardware({required String profileName}){
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _createProfile(profileName);
  }

  // ---------- < Methods [Public] > ----- ---------- ---------- ---------- ---------- ---------- ----------
  Future get startScan async => await _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
  Future get stopScan async =>  await _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> _createProfile(String profileName) async {
    try {await methodChannel.invokeMethod('createDataWedgeProfile', profileName);}
    catch(e) {if(kDebugMode)print(e);}
  }

  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson = jsonEncode({"command": command, "parameter": parameter});
      await methodChannel.invokeMethod('sendDataWedgeCommandStringParameter', argumentAsJson);
    }
    catch(e) {if(kDebugMode)print(e);}
  }

  void _onEvent(event){
    Map barcodeScan = jsonDecode(event);
    scanData =        barcodeScan['scanData'].toString();
    symbology =       barcodeScan['symbology'].toString();
    dateTime =        barcodeScan['dateTime'].toString();
    if(kDebugMode)print(barcodeScan.toString());
  }

  void _onError(Object error){
    scanData =      "";
    symbology =     "";
    dateTime =      "";
    errorMessage =  error.toString();
  }
}
