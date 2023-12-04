import 'package:flutter/material.dart';
import 'home.dart';


void main() {
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
        home: const TelaInicial(
          title: 'Gastos')
        );
  }
}