import 'package:flutter/material.dart';
import 'produtos.dart';
import 'globals.dart' as globals;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math' as math;



DateTime date = DateTime.now();

class TelaInicial extends StatefulWidget { 
  const TelaInicial({super.key, required this.title, required this.listaprod});
  final String title;
  final List<Widget>? listaprod;
  @override
  State<TelaInicial> createState() => _TelaInicialState();
}
double staticMetaGastos = 0;
class _TelaInicialState extends State<TelaInicial> {
  final TextEditingController metaGasto = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(
          onPressed: () async {DateTime? newDate = await showMonthPicker(
            context: context, 
            initialDate: date, 
            firstDate: DateTime(1960), 
            lastDate: DateTime(2100));
            if (newDate == null) return;
            setState(() {
              date = newDate;
              if (globals.comprasMonth.containsKey(mmyy(date))==false) {
               Month month = defMonth(mmyy(date));
              globals.comprasMonth[mmyy(date)] = month; 
              }
            });

            }, icon: const Icon(
              Icons.calendar_today), 
              tooltip: "Mês selecionado: ${date.month}", 
              color: Colors.black)],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title)), 
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [SfCircularChart(
            series: [DoughnutSeries<ChartData, String>(
              dataSource: globals.comprasMonth[mmyy(date)]?.chartData,
              pointColorMapper: (ChartData data, _) => colorFromHex(data.color),
              xValueMapper: (ChartData data, _) => data.x,
               yValueMapper: (ChartData data, _) => data.y,
               dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                useSeriesColor: true),


            )],

          ),
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, 
              builder: (context) =>  AlertDialog(
                content: SingleChildScrollView(
                child: inputText(context, 'Meta de gasto R\$', metaGasto, keyboardType: TextInputType.number),
                ),
                actions: [ElevatedButton(
                  onPressed: () {
                    staticMetaGastos = double.parse(metaGasto.text);
                    if (staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal < 0) {
                      ChartData gastomaximo = ChartData(x: 'Disponível', 
                    y: 0, 
                    color: colorToHex(Colors.white));
                    setState(() {
                    globals.comprasMonth[mmyy(date)]?.listaprod[0] = ListTile(
                    title: Text(
                      "Disponível: R\$${staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal}",
                      style: const TextStyle(color: Colors.white)
                      )
                      );
                      globals.comprasMonth[mmyy(date)]?.chartData?[0] = gastomaximo;
                    });}
                    else {
                    ChartData gastomaximo = ChartData(x: 'Disponível', 
                    y: staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal, 
                    color:colorToHex(Colors.white));
                    setState(() {
                    globals.comprasMonth[mmyy(date)]?.listaprod[0] = ListTile(
                    title: Text(
                      "Disponível: R\$${staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal}",
                      style: const TextStyle(color: Colors.white)
                      )
                      );
                      globals.comprasMonth[mmyy(date)]?.chartData?[0] = gastomaximo;
                    });}
                    Navigator.pop(context);
                  }, 
                  child: const Text('Definir')
                  )
                  ],
              )
              );
            }, 
            child: const Text("Definir meta de gasto")
            ),
          Expanded(
            child: ListView(
              children: globals.comprasMonth[mmyy(date)]!.listaprod)
              ), 
          IconButton(onPressed: () {
            Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => AddProduto(
                date: date)
                )
                );
              }, 
              iconSize: 65, 
              color: Colors.blue,
              icon: const Icon(
                Icons.add_circle)),
            ],
          ), 
        );
      }
  }
double gastoTotal = 0;
String mmyy(DateTime date) {
  return "${date.month}/${date.year}";
}
Month defMonth(String date) {
  final List<Widget> listaprod = [
  const ListTile(
        title: Text("Disponível: R\$0", 
        style: TextStyle(color: Colors.white))),
        const Divider(height: 0)];
  final List<ChartData> chartData = [ChartData(x: "Meta de Gastos", y: 0, color: colorToHex(Colors.white))];
  final Month month = Month(
    date: date, 
    listaprod: listaprod, 
    chartData: chartData,
    gastoTotal: 0);
  return month;
}

class AddProduto extends StatefulWidget {
  const AddProduto({super.key, required this.date});
  final DateTime date;
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
        title: const Text('Gastos')),
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
              backgroundColor: MaterialStatePropertyAll(
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
          controller: controller));

  }
  Text textalign(String productName, String productvalue, Color? textcolor, DateTime time) {
    String data = "${time.day}/${time.month}";
    String finalstring = "$productName ${' ' * 20} $productvalue ${' ' * 20} $data"; 
    return Text(finalstring, style: TextStyle(fontSize: 20, color: textcolor));
    
  }

  ListTile produtolist(BuildContext context, Produtos produto) {
    return ListTile(
      title: textalign(produto.productName, produto.productValue, colorFromHex(produto.textcolor), produto.time)

    ); 
  }
  OutlinedButton submit(BuildContext context) {
    return OutlinedButton(style: const ButtonStyle(
      side: MaterialStatePropertyAll(
        BorderSide(
          color: Colors.black26,))),
    onPressed: () {
      Produtos produto = Produtos(productName: productName.text, productValue: productValue.text, time: DateTime.now(), textcolor: colorToHex(currentColor)); 
      ChartData chartData = ChartData(
        color: colorToHex(currentColor), 
        x: produto.productName, 
        y: double.parse(produto.productValue));
    globals.comprasMonth[mmyy(date)]!.listaprod.add(produtolist(context, produto)); 
    globals.comprasMonth[mmyy(date)]!.listaprod.add(const Divider(height: 0));
    globals.comprasMonth[mmyy(date)]!.gastoTotal += double.parse(produto.productValue);
    ChartData gastomaximo = ChartData(x: 'Disponível', y: staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal, color: colorToHex(Colors.white));
    if (staticMetaGastos>0) {
      if (staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal > 0) {
    setState(() {
      globals.comprasMonth[mmyy(date)]!.listaprod[0] = ListTile(
        title: Text("Disponível: R\$${staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal}",
        style: const TextStyle(color: Colors.white)));
      globals.comprasMonth[mmyy(date)]?.chartData?[0] = gastomaximo;
    });}
    else {
       setState(() {
      globals.comprasMonth[mmyy(date)]!.listaprod[0] = ListTile(
        title: Text("Disponível: R\$${staticMetaGastos - globals.comprasMonth[mmyy(date)]!.gastoTotal}",
        style: const TextStyle(color: Colors.white)));
      globals.comprasMonth[mmyy(date)]?.chartData?[0] = ChartData(x: 'Disponível', y: 0, color: colorToHex(Colors.white));
    });
    }}
    globals.comprasMonth[mmyy(date)]?.chartData?.add(chartData);

    Navigator.push(context, 
              MaterialPageRoute(builder:  (context) => TelaInicial(title: 'Gastos', listaprod: globals.comprasMonth[mmyy(date)]!.listaprod)));
    },
    child: const Text("Submit"));
  }}

SizedBox inputText(BuildContext context, String label, TextEditingController controller, {keyboardType}) {
    return SizedBox(
      width: 250,
      child: TextField(keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label),
          controller: controller));
}