import 'package:flutter/material.dart';
import 'package:logistic_app/routes/incoming_deliverynote.dart';
import 'package:logistic_app/routes/list_pick_up_details.dart';
import 'package:logistic_app/routes/list_delivery_note.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';
import 'package:logistic_app/routes/confirm_product.dart';
import 'package:logistic_app/routes/scan_inventory.dart';
import 'package:logistic_app/routes/scan_orders.dart';
import 'package:logistic_app/routes/list_orders.dart';
import 'package:logistic_app/routes/data_form.dart';
import 'package:logistic_app/routes/log_in.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/routes/menu.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(
    MaterialApp(      
      initialRoute:   '/',
      routes: {
        '/':                      (context) => const LogInMenuFrame(),
        '/menu':                  (context) => const Menu(),
        '/dataForm':              (context) => const DataForm(),
        '/scanOrders':            (context) => const ScanOrders(),
        '/listOrders':            (context) => const ListOrders(),
        '/scanInventory':         (context) => const ScanInventory(),
        '/confirmProduct':        (context) => const ConfirmProduct(),
        '/scanCheckStock':        (context) => const ScanCheckStock(),
        '/listDeliveryNote':      (context) => const ListDeliveryNote(),
        '/listPickUpDetails':     (context) => const ListPickUpDetails(),
        '/incomingDeliveryNote':  (context) => const IncomingDeliveryNote(),
      },
    )
  );
  await DataManager.identitySQLite;
}