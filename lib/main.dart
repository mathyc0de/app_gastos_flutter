import 'package:app_gastos/db.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late final Database db;
late final DatabaseHelper databaseHelper;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';
  db = await openDatabase(
  join(await getDatabasesPath(),'data.db'),
  onCreate: (db, version) {
    db.execute(
      """
      CREATE TABLE month(id INTEGER PRIMARY KEY, goal FLOAT, date TEXT, color TEXT);
      """
    );
    db.execute(
      """
      CREATE TABLE items(id INTEGER PRIMARY KEY, name TEXT, price FLOAT, monthid INTEGER, buydata TEXT)
      """
    );
  },
  version: 1
  );
  databaseHelper = DatabaseHelper(db: db);
  runApp(const GastosApp());
}

class GastosApp extends StatelessWidget {
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
        home: TelaInicial(db: databaseHelper)
        );
  }
}