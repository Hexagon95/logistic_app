// ignore_for_file: use_build_context_synchronously
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
  
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonState = ButtonState.default0;
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
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(children: [
              Expanded(child: _logInMenu()),
              Visibility(visible: !DataManager.isServerAvailable, child: Container(height: 20, color: Colors.red, child: Row(
                mainAxisAlignment:  MainAxisAlignment.center,
                children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)))]
              )))
            ]);
          }
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
        child:    Text(DataManager.versionNumber, style: const TextStyle(fontSize: 14))
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
    ]));
  }

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _enterPressed async{
    buttonState =             ButtonState.loading;
    setState((){});
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonState =             ButtonState.default0;
    if(DataManager.isServerAvailable){
      if(errorMessageBottomLine.isEmpty){
        Global.routeNext = NextRoute.menu;
        await dataManager.beginProcess;
        if(DataManager.isServerAvailable) await Navigator.pushNamed(context, '/menu');
      }
      else {Global.showAlertDialog(context, title: 'Hiba', content: errorMessageBottomLine);}
    }
    setState((){});    
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
}