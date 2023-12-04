import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;



  late Database _db;

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE meses (
            mes TEXT NOT NULL,
            metagasto INTEGER
            gastototal INTEGER
          )
          ''');
    await db.execute('''
          CREATE TABLE gastos (
            _id INTEGER PRIMARY KEY IDENTITY(1,1),
            mes TEXT NOT NULL,
            productname TEXT NOT NULL,
            productvalue INTEGER NOT NULL,
            buy DATA
            color TEXT
          )
''');
  }

 Future<int> queryRowCount(table) async {
    final results =  await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
}

    query(String query) async{
      final result = await _db.rawQuery(query);
    return result;
  }

  // Future<int> delete(int id) async {
  //   return await _db.delete(
  //     table,
  //     where: '$columnId = ?',
  //     whereArgs: [id],
  //   );
  // }

Future<int> insert(Map<String, dynamic> row, String table) async {
    return await _db.insert(table, row);
  }
}