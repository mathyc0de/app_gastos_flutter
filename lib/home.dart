import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math' as math;
import 'db.dart' show DatabaseHelper, Month, Item, randomColor, dateForm;
import 'package:intl/intl.dart' show NumberFormat;


NumberFormat f = NumberFormat.currency(symbol: "R\$");

class ChartData {
        ChartData({required this.x, required this.y, required this.color});
            final String x;
            final double y;
            final String color;
}

class TelaInicial extends StatefulWidget { 
  const TelaInicial({super.key, required this.db});
  final DatabaseHelper db;
  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  late final DatabaseHelper _db;
  late Month _month;
  late List<Item> _data;
  bool fetching = true;
  late DateTime _date;
  TextEditingController goalController = TextEditingController();
  double totalSpent = 0.0;


  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _db = widget.db;
    getData();
  }

  Future<void> getData() async {
    _month = await _db.getMonth(_date);
    _data = await _db.getData(_month.id!);
    setState(() {
      fetching = false;
    });
  }

  double sumPrices() {
    if (_data.isEmpty) return 0.0;
    double result = 0;
    for (final Item product in _data) {
      result += product.price;
    }
    return result;
  }

  DataTable produtolist() {
    return DataTable(
      columns: const [
        DataColumn(label: Text("Despesa")),
        DataColumn(label: Text("Valor")),
        DataColumn(label: Text("Data"))
        ], 
      rows: [
        if (_data.isNotEmpty)
        for (final Item product in _data) DataRow(
          cells: [
            DataCell(Text(product.name)),
            DataCell(Text(f.format(product.price))),
            DataCell(Text(product.buydate))
        ])
      ]
    );
  }

  
List<ChartData> dataExtract() {
  if (_data.isEmpty) return [];
  return [for (Item product in _data) ChartData(x: product.name, y: product.price, color: randomColor())];
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          
          IconButton(
          onPressed: () async {DateTime? newDate = await showMonthPicker(
            context: context, 
            initialDate: _date, 
            firstDate: DateTime(1960), 
            lastDate: DateTime(2100));
            if (newDate == null) return;
            setState(() {
              fetching = true;
              _date = newDate;
            });
            await getData();
            }, icon: const Icon(
              Icons.calendar_today), 
              tooltip: "Mês selecionado: $_date", 
              color: Colors.black)],



        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Controle de Finanças")), 
        body: fetching
        ?  const Center(
              child: CircularProgressIndicator(),
            ) 
        
        : Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
            
            SfCircularChart(
            series: [DoughnutSeries<ChartData, String>(
              dataSource: dataExtract(),
              pointColorMapper: (ChartData data, _) => colorFromHex(data.color),
              xValueMapper: (ChartData data, _) => data.x,
               yValueMapper: (ChartData data, _) => data.y,
               dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                useSeriesColor: true),


            )],),

          ElevatedButton(
            child: const Text("Definir meta de gasto"),
            onPressed: () {
              
              showDialog(context: context, 
              builder: (context) =>  AlertDialog(
                content: SingleChildScrollView(
                child: inputText(context, 'Meta de gasto R\$', goalController, keyboardType: TextInputType.number)),
               actions: [
                  
                  
                ElevatedButton(
                  onPressed: () async {
                  _month.goal = double.parse(goalController.text);
                  _db.updateGoal(_month);
                  setState(() {
                  });
                  },
            child: const Text('Definir'))
            ]));}),


            produtolist(),
            IconButton(onPressed: () {
            Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => AddProduto(
                db: _db,
                month: _month,
                date: _date)
                )
                );
              }, 
              iconSize: 65, 
              color: Colors.blue,
              icon: const Icon(
                Icons.add_circle))



            // ],
          ]), 
        );
      }
//     )
//   ]
// )
// );
  }
    
SizedBox inputText(BuildContext context, String label, TextEditingController controller, {keyboardType}) {
    return SizedBox(
      width: 250,
      child: TextField(keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label),
          controller: controller));}

  
  
class AddProduto extends StatefulWidget {
  const AddProduto({super.key, required this.date, required this.db, required this.month});
  final DateTime date;
  final DatabaseHelper db;
  final Month month;
  @override
  State<AddProduto> createState() => _AddProdutoState();
}

class _AddProdutoState extends State<AddProduto> {

  final productValue = TextEditingController();
  final productName = TextEditingController();
  Color pickColor = const Color(0xff443a49);
  Color currentColor = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  void changeColor(Color color) {
  setState(() => pickColor = color);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Controle de Finanças')),
        body: Center(child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            inputText(context, 'Nome da despesa', productName),
            const SizedBox(height: 20),
            inputText(context, "Valor gasto (R\$)", productValue, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            colorSelector(context),
          submit(context),
            ],
          ), 
        ),
    );
    
  }
ElevatedButton colorSelector(context) {
    return ElevatedButton(
            onPressed: () {showDialog(context: context, builder: (context) => AlertDialog(
              title: const Text('Selecionar cor'), content: SingleChildScrollView(
              child:
            ColorPicker(
              pickerColor: pickColor, 
              onColorChanged: changeColor)
              ),
              actions: [ElevatedButton(
                child: const Text('Definir'),
        onPressed: () {
          setState(() => currentColor = pickColor);
          Navigator.of(context).pop();
          }
          )
          ],
              )
              );
              },
              style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Colors.pink)
            ),
            child: const Text('Selecionar cor'));
  }

  SizedBox inputText(BuildContext context, String label, TextEditingController controller, {keyboardType}) {
    return SizedBox(
      width: 250,
      child: TextField(keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label),
          controller: controller));}


OutlinedButton submit(BuildContext context) {
    return OutlinedButton(
      style: const ButtonStyle(
        side: WidgetStatePropertyAll(
          BorderSide(
            color: Colors.black26,))),
      onPressed: () async{
        widget.db.addItem(Item(name: productName.text, 
        price: double.parse(productValue.text), 
        monthid: widget.month.id!, 
        buydate: dateForm(DateTime.now())));
        Navigator.pop(context);
        },
    child: const Text("Submit"));
  }
}
