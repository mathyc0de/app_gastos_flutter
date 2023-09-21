import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'produtos.dart';

DateTime staticmonth = DateTime.now();
final List<Widget> listaprod = [
  const ListTile(
        title: Text("Disponível: R\$0", 
        style: TextStyle(color: Colors.white))),
        const Divider(height: 0)];
final List<ChartData> chartData = [ChartData(x: "Meta de Gastos", y: 0, color: colorToHex(Colors.white))];
final Month month = Month(
  date: "${staticmonth.month}/${staticmonth.year}", 
  listaprod: listaprod, 
  chartData: chartData,
  gastoTotal: 0);
final Map<String, Month> comprasMonth = {
  "${staticmonth.month}/${staticmonth.year}" : month
};
