import 'package:flutter/material.dart';
import 'package:logistic_app/global.dart';

class InventoryMezAndMol extends StatefulWidget {
  const InventoryMezAndMol({super.key});

  @override
  State<InventoryMezAndMol> createState() => InventoryMezAndMolState();
}

class InventoryMezAndMolState extends State<InventoryMezAndMol> {
  // ---------- < Variables [Static] > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> rawData = [];

  // ---------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  InventoryMState inventoryMState = InventoryMState.scanSotrageCode;
  int _index = 0; int get index => _index; set index(int value){
    if(value < rawData.length) _index = value;
  }
  
  // ---------- < WidgetBuild [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Leltár')),
        backgroundColor: Global.getColorOfButton(ButtonState.default0),
        foregroundColor: Global.getColorOfIcon(ButtonState.default0),
      ),
      body: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Padding(padding: const EdgeInsets.all(10), child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: Global.getColorOfButton(ButtonState.default0), width: 4),
          ),
          child: ((){switch(inventoryMState){
            case InventoryMState.scanSotrageCode:     return _drawScanStorageCode;
            case InventoryMState.scanItemsInStorage:  return _drawScanItemsInStorage;
            default:                                  return Container();
          }})()
        ))),
        _drawBottomBar
      ])
    );
  }

  // ---------- < WidgetBuild [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0));
  
  Widget get _drawScanStorageCode => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(rawData[0]['tarhely_megnevezes'], style: TextStyle(color: Global.getColorOfButton(ButtonState.default0), fontSize: 26, fontWeight: FontWeight.bold)),
    Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.shelves, size: 160, color: Global.getColorOfButton(ButtonState.default0))),
    Container(
      padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Color.fromARGB(255, 60, 60, 60), borderRadius: BorderRadius.circular(100)),
      child:      const Text('Kérem olvassa be a tárhely QR-kódját!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14))
    )
  ])]);

  Widget get _drawScanItemsInStorage => Container();

  // ---------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //

}