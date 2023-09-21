import 'package:flutter/material.dart';

// part 'produtos.g.dart';

class Produtos {
  Produtos({required this.productName, required this.productValue, required this.time, required this.textcolor});
  final String productName;
  final String productValue;
  final DateTime time;
  final String textcolor;
}


class Month {
  Month({required this.date, required this.listaprod, required this.chartData, required this.gastoTotal});
  final String? date;
  List<Widget> listaprod;
  final List<ChartData>? chartData;
  double gastoTotal;
}

class ChartData {
        ChartData({required this.x, required this.y, required this.color});
            final String x;
            final double y;
            final String color;
    }

