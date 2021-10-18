import 'dart:async';
import 'dart:io';

import 'package:alarm/models/alarm.dart';
import 'package:alarm/models/respon_history.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  // static DBProvider? db;

  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "AlarmDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          Batch batch = db.batch();
          batch.execute("CREATE TABLE Alarm ("
              "id INTEGER PRIMARY KEY,"
              "time TEXT,"
              "ringtone TEXT,"
              "status INTEGER"
              ")");
          batch.execute("CREATE TABLE ResponHistory ("
              "id INTEGER PRIMARY KEY,"
              "dateStart TEXT,"
              "dateRespon TEXT,"
              "diff INTEGER"
              ")");
          List<dynamic> res = await batch.commit();
        });
  }

  newAlarm(Alarm newAlarm) async {
    print(newAlarm.time);
    final db = await database;
    //get the biggest id in the table
    var table = await db!.rawQuery("SELECT MAX(id)+1 as id FROM Alarm");
    int id = (table.first["id"] ?? 1) as int;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Alarm (id,time,ringtone,status)"
            " VALUES (?,?,?,?)",
        [id, newAlarm.time, newAlarm.ringtone, newAlarm.status]);
    return id;
  }

  updateAlarm(Alarm newAlarm) async {
    final db = await database;
    var res = await db!.update("Alarm", newAlarm.toMap(),
        where: "id = ?", whereArgs: [newAlarm.id]);
    return res;
  }

  getAlarm(int id) async {
    final db = await database;
    var res = await db!.query("Alarm", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Alarm.fromJson(res.first) : null;
  }

  Future<List<Alarm>> getBlockedAlarms() async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    var res = await db!.query("Alarm", where: "status = ? ", whereArgs: [1]);
    List<Alarm> list =
    res.isNotEmpty ? res.map((c) => Alarm.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Alarm>> getAllAlarms() async {
    final db = await database;
    var res = await db!.query("Alarm");
    List<Alarm> list =
    res.isNotEmpty ? res.map((c) => Alarm.fromJson(c)).toList() : [];
    return list;
  }

  deleteAlarm(int id) async {
    final db = await database;
    return db!.delete("Alarm", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db!.rawDelete("Delete * from Alarm");
  }

  Future<List<ResponHistory>> getAllRespons() async {
    final db = await database;
    var res = await db!.rawQuery("SELECT * FROM ResponHistory order by id desc limit 10 ");
    List<ResponHistory> list =
    res.isNotEmpty ? res.map((c) => ResponHistory.fromJson(c)).toList() : [];
    return list;
  }

  newRespon(ResponHistory newRespon) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db!.rawQuery("SELECT MAX(id)+1 as id FROM ResponHistory");
    int id = (table.first["id"] ?? 1) as int;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ResponHistory (id,dateStart,dateRespon,diff)"
            " VALUES (?,?,?,?)",
        [id, newRespon.dateStart.toString(), newRespon.dateRespon.toString(), newRespon.diff]);
    return raw;
  }

  updateRespon(ResponHistory newRespon) async {
    final db = await database;
    var res = await db!.update("ResponHistory", newRespon.toMap(),
        where: "id = ?", whereArgs: [newRespon.id]);
    return res;
  }
}