import 'package:nodex/models/task.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableName = "tasks";

  static Future<void> initDB() async {
    if (_db != null) {
      return;
    }
    try {
      String _path = await getDatabasesPath() + 'tasks.db';
      _db =
          await openDatabase(_path, version: _version, onCreate: (db, version) {
        print("creating a new one");
        return db.execute(
          "CREATE TABLE $_tableName("
          "id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "title STRING, note TEXT, date STRING, "
          "startTime STRING, endTime STRING,"
          "remind INTEGER, repeat STRING, "
          "color INTEGER, "
          "isCompleted INTEGER)",
        );
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<int> insert(Task? task) async {
    return await _db?.insert(_tableName, task!.toJson()) ?? 1;
  }

  static updateTask(Task? task, int taskId) async {
    //print("UPDATE $_tableName SET title = ${task!.title},note = ${task.note},date = ${task.date},startTime = ${task.startTime},remind = ${task.remind},repeat = ${task.repeat},color = ${task.color} WHERE id = ?");
    return await _db!.rawUpdate('''
    UPDATE $_tableName
    SET title = ?,
    note = ?,
    date = ?,
    startTime = ?,
    endTime = ?,
    remind = ?,
    repeat = ?,
    color = ?
    WHERE id = ?
    ''', [
      task!.title,
      task.note,
      task.date,
      task.startTime,
      task.endTime,
      task.remind,
      task.repeat,
      task.color,
      taskId
    ]);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    //print("query function called");
    return await _db!.query(_tableName);
  }

  static delete(Task task) async {
    return await _db!.delete(_tableName, where: 'id=?', whereArgs: [task.id]);
  }

  static taskCompleted(int id) async {
    return await _db!.rawUpdate('''
    UPDATE $_tableName
    SET isCompleted = ?
    WHERE id = ?
    ''', [1, id]);
  }

  static taskIncomplete(int id) async {
    return await _db!.rawUpdate('''
    UPDATE $_tableName
    SET isCompleted = ?
    WHERE id = ?
    ''', [0, id]);
  }
}
