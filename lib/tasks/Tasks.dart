import 'package:dayos_book_app/tasks/TasksModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'dart:core';

class TasksDBWorker {
  TasksDBWorker._();

  static final TasksDBWorker db = TasksDBWorker._();
  Database _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "tasks.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS tasks("
          "id INTEGER PRIMARY KEY,"
          "description TEXT,"
          "dueDate TEXT,"
          "completed TEXT");
    });
    return db;
  }

  Future create(Task inTask) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    int id = val.first["id"];

    if (id == null) {
      id = 1;
    }
    return await db.rawInsert(
        "INSERT INTO tasks(id, description, dueDate, completed) "
        "VALUES (?, ?, ?, ?)",
        [id, inTask.description, inTask.dueDate, inTask.completed]);
  }

  Future<Task> get(int inId) async {
    Database db = await database;
    var rec = await db.query("tasks", where: "id = ?", whereArgs: [inId]);
    return taskFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("tasks");
    var list = recs.isNotEmpty ? recs.map((e) => taskFromMap(e)).toList() : [];
    return list;
  }

  Future update(Task inTask) async {
    Database db = await database;
    return await db.update("tasks", taskToMap(inTask),
        where: "id = ?", whereArgs: [inTask.id]);
  }

  Future delete(int inID) async {
    Database db = await database;
    return await db.delete("tasks", where: "id = ?", whereArgs: [inID]);
  }

  Map<String, dynamic> taskToMap(Task inTask) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inTask.id;
    map["description"] = inTask.description;
    map["dueDate"] = inTask.dueDate;
    map["completed"] = inTask.completed;
    return map;
  }

  Task taskFromMap(Map inMap) {
    Task task = Task();
    task.id = inMap["id"];
    task.description = inMap["description"];
    task.dueDate = inMap["dueDate"];
    task.completed = inMap["completed"];
    return task;
  }
}