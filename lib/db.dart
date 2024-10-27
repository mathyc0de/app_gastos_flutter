import 'package:sqflite/sqflite.dart';
import 'dart:math' as math;


String dateForm(DateTime date) => "${date.day}/${date.month}/${date.year}";

String randomColor() {
  final color = (math.Random().nextDouble() * 0xFFFFFF).toInt();
  return color.toString();
}

class Month {
  Month({this.id, required this.goal, required this.date, required this.color});
  final int? id;
  double goal;
  final String date;
  final String color;

  @override
  String toString() {
    return "{id: $id, goal: $goal, date: $date, color $color}";
  }

  Map<String, dynamic> toMap() {
    return {
      "goal": goal,
      "date": date,
      "color": color
    };
  }

  static Month fromMap(Map<String, dynamic> map) {
    return Month(id: map["id"], goal: map["goal"], date: map["date"], color: map["color"]);
  }
}

class Item {
  Item({this.id, required this.name, required this.price, required this.monthid, required this.buydate});
  final int? id;
  final String name;
  final double price;
  final int monthid;
  final String buydate;

  @override
  String toString() {
    return "{id: $id, name: $name, price: $price, monthid: $monthid, buydate: $buydate}";
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
      "monthid": monthid,
      "buydate": buydate
    };
  }
}


class DatabaseHelper {
  DatabaseHelper({required this.db});
  final Database db;


  Future<void> addMonth(Month month) async {
    await db.insert("month", month.toMap());
  }

  Future<void> addItem(Item product) async{
    await db.insert("items", product.toMap());
  }

  Future<Month> getMonth(DateTime date) async {
    final formated = dateForm(date);
    List<Map<String, dynamic>> data = await db.query("month", where: "id = ?", whereArgs: [formated]);
    if (data.isEmpty) {
      addMonth(Month(goal: 0, date: formated, color: randomColor()));
      List<Map<String, dynamic>> data = await db.query("month", where: "id = ?", whereArgs: [formated]);
      return Month.fromMap(data.first);
      }
    return Month.fromMap(data.first);
  }

  Future<List<Item>> getData(int monthid) async {
    final rawdata = await db.query("items", where: "monthid = $monthid");
    if (rawdata.isEmpty) return [];
    return [
      for(
        final {
        "id": id as int,
        "name": name as String,
        "price": price as double,
        "monthid": _ as int,
        "buydata": buydate as String} in rawdata)
        Item(id: id, name: name, price: price, monthid: monthid, buydate: buydate)
      ];
  }

  Future<void> deleteItem(Item product) async {
    await db.delete("items", where: "id = ${product.id}");
  }

  Future<void> updateGoal(Month month) async {
    await db.rawUpdate(
    """
      UPDATE month SET goal = ${month.goal} WHERE id = ${month.id}
    """,
    );
  }

}