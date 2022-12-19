// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';

class Menu extends StatefulWidget{ //----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <Menu>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => LogInMenuState();
}

class LogInMenuState extends State<Menu>{ //--------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuState>
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static String errorMessageBottomLine =  '';  
  
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonPickUpList =  ButtonState.default0;
  ButtonState buttonListOrders =  ButtonState.default0;
  ButtonState buttonRevenue =     ButtonState.disabled;
  ButtonState buttonInventory =   ButtonState.default0;
  late double _width;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  LogInMenuState(){
    Global.routeNext =  NextRoute.logIn;
  }

  // ---------- < WidgetBuild [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
   Widget build(BuildContext context){
    _width = MediaQuery.of(context).size.width - 50;
    if(_width > 400) _width = 400;
    return Scaffold(
      appBar: AppBar(
        title:            const Center(child: Text('Logistic App')),
        backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      ),
      backgroundColor:  Colors.white,
      body:             LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _drawButtonPickUpList,
            Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 40), child: _drawButtonListOrders),
            _drawButtonRevenue,
            _drawButtonInventory,
          ]));
        }
      )
    );
  }

  // ---------- < WidgetBuild [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonPickUpList => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonPickUpList))),
      onPressed:  (buttonPickUpList == ButtonState.default0)? () => _buttonPickUpListPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonPickUpList == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonPickUpList))))
        ),
        Text((buttonPickUpList == ButtonState.loading)? 'Betöltés...' : 'Kiszedési lista', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonPickUpList)))
      ])
    ))
  );

  Widget get _drawButtonListOrders => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonListOrders))),
      onPressed:  (buttonListOrders == ButtonState.default0)? () => _buttonListOrdersPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonListOrders == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonListOrders))))
        ),
        Text((buttonListOrders == ButtonState.loading)? 'Betöltés...' : 'Rendelések összeszedése', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonListOrders)))
      ])
    ))
  );

  Widget get _drawButtonRevenue => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonRevenue))),
      onPressed:  (buttonRevenue == ButtonState.default0)? () => _buttonRevenuePressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonRevenue == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonRevenue))))
        ),
        Text((buttonRevenue == ButtonState.loading)? 'Betöltés...' : 'Bevételezés', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonRevenue)))
      ])
    ))
  );

  Widget get _drawButtonInventory => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonInventory))),
      onPressed:  (buttonInventory == ButtonState.default0)? () => _buttonInventoryPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonInventory == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonInventory))))
        ),
        Text((buttonInventory == ButtonState.loading)? 'Betöltés...' : 'Leltár', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonInventory)))
      ])
    ))
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _buttonPickUpListPressed async{
    setState(() => buttonPickUpList = ButtonState.loading);
    Global.routeNext =        NextRoute.pickUpList;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonPickUpList =        ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }

  Future get _buttonListOrdersPressed async{
    setState(() => buttonListOrders = ButtonState.loading);
    Global.routeNext =        NextRoute.listOrders;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonListOrders =        ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }

  void get _buttonRevenuePressed {}  

  Future get _buttonInventoryPressed async{
    setState(() => buttonInventory = ButtonState.loading);
    if(await _isInventoryDate){
      Global.routeNext =  NextRoute.inventory;
      buttonInventory =   ButtonState.default0;
      Navigator.pushNamed(context, '/scanInventory');
      setState((){});
    }
    else{
      setState(() => buttonInventory = ButtonState.default0);
      await Global.showAlertDialog(context,
        title:    "Leltár hiba",
        content:  "A main napra nincs kiírva leltár."
      );
    }
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<bool> get _isInventoryDate async{
    DataManager dataManager = DataManager(interMission: InterMission.askInventoryDate);
    await dataManager.beginInterMission;
    return (DataManager.dataInterMission[3][0]['leltar_van'] != null);
  }
}