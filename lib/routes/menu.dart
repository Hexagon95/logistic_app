// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';

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
  ButtonState buttonPickUpList =    ButtonState.default0;
  ButtonState buttonListOrders =    ButtonState.default0;
  ButtonState buttonDeliveryNote =  ButtonState.default0;
  ButtonState buttonRevenue =       ButtonState.disabled;
  ButtonState buttonCheckStock =    ButtonState.default0;
  ButtonState buttonStockIn =       ButtonState.default0;
  ButtonState buttonInventory =     ButtonState.default0;
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
            _drawButtonListOrders,
            Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 40), child: _drawButtonDeliveryNote),
            //_drawButtonRevenue,
            _drawButtonCheckStock,
            Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 40), child: _drawButtonStockIn),
            _drawButtonInventory
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

  Widget get _drawButtonDeliveryNote => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonDeliveryNote))),
      onPressed:  (buttonDeliveryNote == ButtonState.default0)? () => _buttonDeliveryNotePressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonDeliveryNote == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonDeliveryNote))))
        ),
        Text((buttonDeliveryNote == ButtonState.loading)? 'Betöltés...' : 'Szállítólevél Átvétel', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonDeliveryNote)))
      ])
    ))
  );  

  /*Widget get _drawButtonRevenue => Padding(
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
  );*/

  Widget get _drawButtonCheckStock => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonCheckStock))),
      onPressed:  (buttonCheckStock == ButtonState.default0)? () => _buttonCheckStockPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonCheckStock == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonCheckStock))))
        ),
        Text((buttonCheckStock == ButtonState.loading)? 'Betöltés...' : 'Készlet Ellenörzése', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonCheckStock)))
      ])
    ))
  );

  Widget get _drawButtonStockIn => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonStockIn))),
      onPressed:  (buttonStockIn == ButtonState.default0)? () => _buttonStockInPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonStockIn == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonStockIn))))
        ),
        Text((buttonStockIn == ButtonState.loading)? 'Betöltés...' : 'Betárolás', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonStockIn)))
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
    Global.routeNext =        NextRoute.orderList;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonListOrders =        ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }

  Future get _buttonDeliveryNotePressed async{
    buttonDeliveryNote =      ButtonState.loading;
    Global.routeNext =        NextRoute.deliveryNoteList;
    setState((){});
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonDeliveryNote =      ButtonState.default0;
    if(DataManager.isServerAvailable){
      await Navigator.pushNamed(context, '/listDeliveryNote');
      setState((){});
    }
  }

  //void get _buttonRevenuePressed {}

  Future get _buttonCheckStockPressed async{
    setState(() => buttonCheckStock = ButtonState.loading);
    Global.routeNext =                NextRoute.checkStock;
    buttonCheckStock =                ButtonState.default0;
    ScanCheckStockState.stockState =  StockState.checkStock;
    await Navigator.pushNamed(context, '/scanCheckStock');
  }

  Future get _buttonStockInPressed async{
    setState(() => buttonStockIn = ButtonState.loading);
    Global.routeNext =                NextRoute.checkStock;
    buttonStockIn =                   ButtonState.default0;
    ScanCheckStockState.stockState =  StockState.stockIn;
    await Navigator.pushNamed(context, '/scanCheckStock');
  }

  Future get _buttonInventoryPressed async{
    setState(() => buttonInventory = ButtonState.loading);
    if(await _isInventoryDate){
      Global.routeNext =  NextRoute.inventory;
      buttonInventory =   ButtonState.default0;
      await Navigator.pushNamed(context, '/scanInventory');
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
    DataManager dataManager = DataManager(quickCall: QuickCall.askInventoryDate);
    await dataManager.beginQuickCall;
    return (DataManager.dataQuickCall[3][0]['leltar_van'] != null);
  }
}