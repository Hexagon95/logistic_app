// ignore_for_file: use_build_context_synchronously

import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/routes/incoming_deliverynote.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget{ //----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <Menu>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => MenuState();
}

class MenuState extends State<Menu>{ //--------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuState>
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> menuList =         List<dynamic>.empty();
  static String errorMessageBottomLine =  '';
  
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonPickUpList =            ButtonState.default0;
  ButtonState buttonDeliveryOut =           ButtonState.default0;
  ButtonState buttonIncomingDeliveryNote =  ButtonState.default0;
  ButtonState buttonListOrdersOut =         ButtonState.default0;
  ButtonState buttonListOrders =            ButtonState.default0;
  ButtonState buttonDeliveryNote =          ButtonState.default0;
  ButtonState buttonRevenue =               ButtonState.disabled;
  ButtonState buttonCheckStock =            ButtonState.default0;
  ButtonState buttonStockIn =               ButtonState.default0;
  ButtonState buttonInventory =             ButtonState.default0;
  late double _width;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  MenuState(){
    Global.routeNext =  NextRoute.logIn;
  }

  // ---------- < WidgetBuild [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
   Widget build(BuildContext context){
    Widget filter(int id, Widget menuOption) {for(var item in menuList) {if(item['id'] == id && item['aktiv'] == 1) return menuOption;} return Container();}

    _width = MediaQuery.of(context).size.width - 50;
    if(_width > 400) _width = 400;
    return Scaffold(
      appBar: AppBar(
        title:            Center(child: Text(DataManager.raktarMegnevezes)),
        backgroundColor:  Global.getColorOfButton(ButtonState.default0),
        foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
      ),
      backgroundColor:  Colors.white,
      body:             LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            filter(7, _drawButtonListOrdersOut),
            filter(1, _drawButtonPickUpList),
            filter(2, _drawButtonListOrders),
            filter(8, _drawDeliveryOut),
            filter(9, _drawButtonIncomingDeliveryNote),
            const SizedBox(height: 20),
            filter(3, _drawButtonDeliveryNote),
            filter(4, _drawButtonCheckStock),
            filter(5, _drawButtonStockIn),
            filter(6, _drawButtonInventory)
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
        Text((buttonPickUpList == ButtonState.loading)? 'Betöltés...' : menuList[0]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonPickUpList)))
      ])
    ))
  );

  Widget get _drawDeliveryOut => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonDeliveryOut))),
      onPressed:  (buttonDeliveryOut == ButtonState.default0)? () => _buttonDeliveryOutPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonDeliveryOut == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonDeliveryOut))))
        ),
        Text((buttonDeliveryOut == ButtonState.loading)? 'Betöltés...' : menuList[7]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonDeliveryOut)))
      ])
    ))
  );

  Widget get _drawButtonIncomingDeliveryNote => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonIncomingDeliveryNote))),
      onPressed:  (buttonIncomingDeliveryNote == ButtonState.default0)? () => _buttonIncomingDeliveryNotePressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonIncomingDeliveryNote == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonIncomingDeliveryNote))))
        ),
        Text((buttonIncomingDeliveryNote == ButtonState.loading)? 'Betöltés...' : menuList[8]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonIncomingDeliveryNote)))
      ])
    ))
  );

  Widget get _drawButtonListOrdersOut => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonListOrdersOut))),
      onPressed:  (buttonListOrdersOut == ButtonState.default0)? () => _buttonListOrdersOutPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonListOrdersOut == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonListOrdersOut))))
        ),
        Text((buttonListOrdersOut == ButtonState.loading)? 'Betöltés...' : menuList[6]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonListOrdersOut)))
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
        Text((buttonListOrders == ButtonState.loading)? 'Betöltés...' : menuList[1]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonListOrders)))
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
        Text((buttonDeliveryNote == ButtonState.loading)? 'Betöltés...' : menuList[2]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonDeliveryNote)))
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
        Text((buttonCheckStock == ButtonState.loading)? 'Betöltés...' : menuList[3]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonCheckStock)))
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
        Text((buttonStockIn == ButtonState.loading)? 'Betöltés...' : menuList[4]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonStockIn)))
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
        Text((buttonInventory == ButtonState.loading)? 'Betöltés...' : menuList[5]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonInventory)))
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

  Future get _buttonDeliveryOutPressed async{
    setState(() => buttonPickUpList = ButtonState.loading);
    Global.routeNext =        NextRoute.deliveryOut;
    await DataManager().beginProcess;
    buttonPickUpList =        ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }

  Future get _buttonIncomingDeliveryNotePressed async{
    setState(() => buttonIncomingDeliveryNote = ButtonState.loading);
    Global.routeNext =                    NextRoute.incomingDeliveryNote;
    await DataManager().beginProcess;
    buttonIncomingDeliveryNote =          ButtonState.default0;
    IncomingDeliveryNoteState.taskState = InDelNoteState.default0;
    await Navigator.pushNamed(context, '/incomingDeliveryNote');
    setState((){});
  }

  Future get _buttonListOrdersOutPressed async{
    setState(() => buttonListOrdersOut = ButtonState.loading);
    Global.routeNext =        NextRoute.orderOutList;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonListOrdersOut =     ButtonState.default0;
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