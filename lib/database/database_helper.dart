import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static const _databaseName = 'task_manager.db';
  static const _databaseVersion = 1;
  static const table = 'tasks';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        priority TEXT NOT NULL
      )
    ''');
  }

  Future<void> initDb() async {
    await database;
  }

  // Insert a task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(table, task.toMap());
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final result = await db.query(table);
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Update a task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      table,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
