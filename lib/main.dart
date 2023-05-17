import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/routes/list_delivery_note.dart';
import 'package:logistic_app/routes/log_in.dart';
import 'package:logistic_app/routes/menu.dart';
import 'package:logistic_app/routes/list_orders.dart';
import 'package:logistic_app/routes/list_pick_up_details.dart';
import 'package:logistic_app/routes/scan_orders.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';
import 'package:logistic_app/routes/scan_inventory.dart';
import 'package:logistic_app/routes/confirm_product.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(
    MaterialApp(      
      initialRoute:   '/',
      routes: {
        '/':                  (context) => const LogInMenuFrame(),
        '/menu':              (context) => const Menu(),
        '/listOrders':        (context) => const ListOrders(),
        '/listPickUpDetails': (context) => const ListPickUpDetails(),
        '/listDeliveryNote':  (context) => const ListDeliveryNote(),
        '/scanOrders':        (context) => const ScanOrders(),
        '/scanCheckStock':    (context) => const ScanCheckStock(),
        '/scanInventory':     (context) => const ScanInventory(),
        '/confirmProduct':    (context) => const ConfirmProduct(),
      },
    )
  );
  await DataManager.identitySQLite;
}