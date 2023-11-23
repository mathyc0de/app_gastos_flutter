import 'package:flutter/material.dart';
import 'tela_inicial.dart';
import 'globals.dart' as globals;


void main() async {
  runApp(const GastosApp());
}

class GastosApp extends StatelessWidget { /// Inicia o [key] para criar subclasses.
  const GastosApp({super.key});
//Widget raiz

  @override  
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gastos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow),
        useMaterial3: true),
        darkTheme: ThemeData.dark(
          useMaterial3: true),
        home: TelaInicial(
          title: 'Gastos', 
          listaprod: globals.listaprod)
        );
  }
}