import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/ClientModel.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "DBToDo.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Client ("
              "id INTEGER PRIMARY KEY,"
              "toDo TEXT,"
              "done INTEGER"
              ")");
        });
  }

  newToDo(Client newClient) async {
    final db = await database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Client");
    int id = table.first["id"];
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Client (id,toDo,done)"
            " VALUES (?,?,?)",
        [id, newClient.toDo,  newClient.done]);
    return raw;
  }

  update(Client newClient) async {
    final db = await database;
    var res = await db.rawUpdate("UPDATE Client SET toDo = ?, done = ? WHERE id = ?",
      //(id,toDo,done)"
        [newClient.toDo, newClient.done, newClient.id]);
//    var res = await db.update("Client", newClient.toMap(),
  //      where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  get(int id) async {
    final db = await database;
    var res = await db.query("Client", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Client.fromMap(res.first) : null;
  }

  Future<List<Client>> getSearch(String str) async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Client WHERE toDo LIKE ? ORDER BY done, toDo", [str]);

    List<Client> list =
    res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Client>> getAll() async {
    final db = await database;
    var res = await db.query("Client", orderBy: "done, toDo");
    List<Client> list =
    res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  delete(int id) async {
    final db = await database;
    return db.delete("Client", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Client");
  }
}