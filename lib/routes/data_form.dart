import 'package:flutter/material.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';
import '../global.dart';

class DataForm extends StatefulWidget {//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataForm>
  const DataForm({super.key});

  @override
  State<DataForm> createState() => DataFormState();
}

class DataFormState extends State<DataForm> {//-- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataFormState>
  // ---------- < Wariables [Static] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> rawData =  List<dynamic>.empty();
  static String title =           '';
  static int? amount;

  // ---------- < Wariables [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<TextEditingController> controller =  List<TextEditingController>.empty(growable: true);
  ButtonState buttonContinue =              ButtonState.default0;
  BoxDecoration customBoxDecoration =       BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  // ---------- < Constructor > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  DataFormState() {for(int i = 0; i < rawData.length; i++) {controller.add(TextEditingController(text: ''));}}

  // ---------- < WidgetBuild [1] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
   Widget build(BuildContext context){
    return GestureDetector(
      onTap:  () => setState((){}),
      child:  Scaffold(
        appBar: AppBar(
          title:            const Center(child: Text('Adja meg a mennyiséget')),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
        ),
        backgroundColor:  Colors.white,
        body:             LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _drawFormList,
              _drawBottomBar
            ]);
          }
        )
      )
    );
  }

  // ---------- < WidgetBuild [2] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawFormList{
    List<Widget> varListWidget = List<Widget>.empty(growable: true);
    for(int i = 0; i < rawData.length; i++) {varListWidget.add(Padding(
      padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child:    Container(decoration: customBoxDecoration, child: Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawData[i], i)))
    ));}
    return Expanded(child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.start, children: varListWidget)));
  }

  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      _drawButtonQRCode
    ])
  );

  // ---------- < WidgetBuild [3] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonQRCode => TextButton(
    onPressed:  () => (buttonContinue == ButtonState.default0)? _buttonContinuePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonContinue == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonContinue)) : Container(),
      Text(' Cél tárhelyhez ', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonContinue))),
      Icon(Icons.arrow_forward_ios, color: Global.getColorOfIcon(buttonContinue), size: 30)
    ]))
  );

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _getWidget(dynamic input, int index) {bool editable = (input['editable'].toString() == '1'); switch(input['input_field']){

    case 'integer': controller[index].text = input['value'].toString(); return SizedBox(height: 55, child: TextFormField(
      enabled:            editable,          
      controller:         controller[index],
      onChanged:          (value) => _checkInteger(value, input, index),
      decoration:         InputDecoration(
        contentPadding:     const EdgeInsets.all(10),
        labelText:          input['name'],
        border:             InputBorder.none,
      ),
      style:        TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
      keyboardType: TextInputType.number,
    ));

    default: return SizedBox(height: 55, child: TextFormField(
      enabled:      editable,
      initialValue: input['value'].toString(),
      decoration:   InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        labelText:      input['name'],
        border:         InputBorder.none,
      ),
      onChanged:    (value) {},
      style:        TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
    ));
  }}

  Future get _buttonContinuePressed async {
    setState(() => buttonContinue = ButtonState.loading);
    amount =                              rawData[1]['value'];
    ScanCheckStockState.taskStateStatic = TaskState.scanDestinationStorage;
    buttonContinue =                      ButtonState.default0;
    Navigator.popUntil(context, ModalRoute.withName('/scanCheckStock'));
    await Navigator.pushReplacementNamed(context, '/scanCheckStock');
  }

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  void _checkInteger(String value, dynamic input, int index){ //Check if integer and is between 0 and limit.
    int? varInt;
    try{varInt = int.parse(value);}
    // ignore: empty_catches
    catch(e){}
    finally{
      if(varInt != null) {
        if(varInt < 1) {controller[index].text = '1'; input['value'] = 1;}
        else if(varInt > input['limit']) {
          controller[index].text =  input['limit'].toString();
          input['value'] =          input['limit'];
        }
        else {input['value'] = varInt;}
      }
      else if(value != '') {controller[index].text = input['value'].toString();}
    }
  }
}