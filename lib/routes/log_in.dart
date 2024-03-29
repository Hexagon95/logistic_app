// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:ota_update/ota_update.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';

class LogInMenuFrame extends StatefulWidget{
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuFrame>
  const LogInMenuFrame({Key? key}) : super(key: key);

  @override
  State<LogInMenuFrame> createState() => LogInMenuState();
}

class LogInMenuState extends State<LogInMenuFrame>{
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuState>
  static String errorMessageBottomLine =  '';
  static bool updateNeeded =              false;
  
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonState = ButtonState.default0;
  OtaEvent? currentEvent;
  late double _width;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  LogInMenuState(){  
    Global.routeNext =  NextRoute.logIn;
  }

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){        
    return WillPopScope(
      onWillPop:  () async => false,
      child:      Scaffold(
        backgroundColor:  Colors.white,
        body:             LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) => Column(children: [
            Expanded(child: _logInMenu()),
            Visibility(visible: !DataManager.isServerAvailable, child: Container(height: 20, color: Colors.red, child: Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)))]
            )))
          ])
        )
      )
    );
  }

  Widget _logInMenu(){
    _width = MediaQuery.of(context).size.width - 50;
    if(_width > 400) _width = 400;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[
      const Padding(
        padding:  EdgeInsets.fromLTRB(0, 0, 0, 20),
        child:    Text('LogisticApp', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 180, 125, 1.0)), textAlign: TextAlign.center)
      ),
      Padding(
        padding:  const EdgeInsets.all(10),
        child:    Text('v${DataManager.thisVersion}', style: const TextStyle(fontSize: 14))
      ),
      Padding(
        padding:  const EdgeInsets.fromLTRB(20, 40, 20, 40),
        child:    SizedBox(height: 40, width: _width, child: TextButton(          
          style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonState))),
          onPressed:  (buttonState == ButtonState.default0)? () => _enterPressed : null,          
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Visibility(
              visible:  (buttonState == ButtonState.loading)? true : false,
              child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonState))))
            ),
            Text((buttonState == ButtonState.loading)? 'Betöltés...' : 'Bejelentkezés', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonState)))
          ])
        ))
      ),
      updateNeeded
        ? Text('Új verzió érhető el\n${currentEvent?.status} : ${currentEvent?.value}', style: const TextStyle(fontSize: 16))
        : Container()
    ]));
  }

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _enterPressed async{
    errorMessageBottomLine = '';
    setState(() => buttonState = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(!updateNeeded){
      await DataManager(input: {'number': 0}).beginProcess;
      if(errorMessageBottomLine.isNotEmpty){
        await Global.showAlertDialog(context, title: 'Hiba!', content: errorMessageBottomLine);
        setState(() => buttonState = ButtonState.default0);
        return;
      }
      await DataManager(input: {'number': 4}).beginProcess;
      if(errorMessageBottomLine.isNotEmpty){
        await Global.showAlertDialog(context, title: 'Hiba!', content: errorMessageBottomLine);
        setState(() => buttonState = ButtonState.default0);
        return;
      }
      await DataManager(quickCall: QuickCall.tabletBelep).beginQuickCall;
      Global.routeNext = NextRoute.menu;
      await DataManager().beginProcess;
      buttonState =             ButtonState.default0;
      if(errorMessageBottomLine.isEmpty) {await Navigator.pushNamed(context, '/menu');}
      else{
        await Global.showAlertDialog(context, title: 'Hiba', content: errorMessageBottomLine);
        Global.routeBack;
      }
      setState((){});
    }
    else{
      setState(() => buttonState = ButtonState.disabled);
      tryOtaUpdate();
    }
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> tryOtaUpdate() async {
    try {
      if(kDebugMode)print('ABI Platform: ${await OtaUpdate().getAbi()}');
      OtaUpdate().execute(
        'https://app.mosaic.hu/ota/logistic_app/${DataManager.actualVersion}/app-release.apk',
        destinationFilename: 'app-release.apk',
      ).listen(
        (OtaEvent event) {setState(() => currentEvent = event);}
      );
    } catch (e) {
      if(kDebugMode)print('Failed to make OTA update. Details: $e');
    }
  }
}