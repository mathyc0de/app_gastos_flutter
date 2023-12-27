import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math' as math;
import 'db.dart' as database;



DateTime date = DateTime.now();
final db = database.DatabaseHelper();

class ChartData {
        ChartData({required this.x, required this.y, required this.color});
            final String x;
            final double y;
            final String color;
}

class TelaInicial extends StatefulWidget { 
  const TelaInicial({super.key, required this.title});
  final String title;
  @override
  State<TelaInicial> createState() => _TelaInicialState();
  
}
double staticMetaGastos = 0;
class _TelaInicialState extends State<TelaInicial> {
  final TextEditingController metaGasto = TextEditingController();
  bool fetching = true;
  @override
  void initState() {
    super.initState();
    getData2();
  }

  void getData2() async {
    await db.init();
    String data = '${date.month}/${date.year}';
    List<Map<String, dynamic>> query = await db.query("SELECT * FROM meses WHERE mes = '$data'");
    if (query.isEmpty) {
            db.insert({"mes": data, "metagasto": 0.0, "gastototal": 0.0}, "meses");
            db.insert({"mes": data, "productname": "Disponível", "productvalue": 0.0, "buy": "01-01-1900", "color": "#FFFFFF"}, "gastos");
          }
    globals.dados = await dateGetter(data);
    print(globals.dados);
    setState(() {
      fetching = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          
          IconButton(
          onPressed: () async {DateTime? newDate = await showMonthPicker(
            context: context, 
            initialDate: date, 
            firstDate: DateTime(1960), 
            lastDate: DateTime(2100));
            if (newDate == null) return;
            setState(() {
              date = newDate;
              String data = '${date.month}/${date.year}';
             if (db.query("SELECT * FROM meses WHERE mes= '$data'") == [] )  {
               db.insert({"mes": data, "metagasto": 0.0, "gastototal": 0.0}, "meses");
               db.insert({
            "mes": data,
            "productname": "Disponível",
            "productvalue": 0.0,
            "buy":  data,
            "color": "#FFFFFF"}, "gastos");
              }
            });
            globals.data = await db.query("SELECT * FROM gastos WHERE mes= '${date.month}/${date.year}'");
            }, icon: const Icon(
              Icons.calendar_today), 
              tooltip: "Mês selecionado: ${date.month}", 
              color: Colors.black)],



        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title)), 
        body: fetching
        ?  const Center(
              child: CircularProgressIndicator(),
            ) 
        
        : Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
            
            SfCircularChart(
            series: [DoughnutSeries<ChartData, String>(
              dataSource: dataExtract(globals.dados),
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
                child: inputText(context, 'Meta de gasto R\$', metaGasto, keyboardType: TextInputType.number)),
               actions: [
                  
                  
                ElevatedButton(
                   onPressed: () async {
                     staticMetaGastos = double.parse(metaGasto.text);
                  db.query("UPDATE meses SET metagasto = $staticMetaGastos WHERE mes = '${date.month}/${date.year}'");
                  double result = 0.0;
                  List soma = await db.query("SELECT productvalue FROM gastos WHERE mes = '${date.month}/${date.year}' AND productname != 'Disponível'");
                  for (double values in soma) {
                    result += values;
                  }
                  setState(() {
                    db.query("UPDATE gastos SET productvalue = ${staticMetaGastos - result} WHERE mes = '${date.month}/${date.year}' AND productname = 'Disponível'");
                  });
                  print(result);
                  },
            child: const Text('Definir'))
            ]));}),


              Expanded(
                child: 
                  ListView(
                      children: produtolist(context, globals.dados))
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

  

List<Widget> produtolist(BuildContext context,  List<Map<String,dynamic>> dado) {
  List<Widget> result = [];
  for (int i=0; i<dado.length; i++) {
    String name = dado[i]["productname"];
    double value = dado[i]["productvalue"] + .0;
    String data = dado[i]["mes"];
    result.add(
      ListTile(title: Text("$name ${' ' * 20} $value ${' ' * 20} $data")));
      result.add(const Divider(height: 0));}
  return result;
  }




  Future<List<Map<String,dynamic>>> dateGetter(data) async {
    return await db.query("SELECT * FROM gastos WHERE mes= '$data'");
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
          controller: controller));}


OutlinedButton submit(BuildContext context) {
    return OutlinedButton(style: const ButtonStyle(
      side: MaterialStatePropertyAll(
        BorderSide(
          color: Colors.black26,))),
    onPressed: () async{
      db.insert({
            "mes": "${date.month}/${date.year}",
            "productname": productName.text,
            "productvalue": double.parse(productValue.text) + .0,
            "buy": "${date.month}/${date.year}",
            "color": colorToHex(currentColor)}, "gastos");
    db.query("UPDATE meses SET gastototal = $staticMetaGastos WHERE mes = '${date.month}/${date.year}'");
    Navigator.pushReplacement(context,
              MaterialPageRoute(builder:  (context) => const TelaInicial(title: 'Gastos')));
    },
    child: const Text("Submit"));
  }}



List<ChartData> dataExtract(List<Map<String, dynamic>> data) {
  List <ChartData> extractedData = [];
  for (Map<String, dynamic> x in data) {
    String name = x["productname"];
    double value = x["productvalue"] + .0;
    String color = x["color"];
    extractedData.add(ChartData(x: name, y: value, color: color));
  }
  return extractedData;
}
