import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'expense_app.db';
  static const _dbVersion = 1;
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  static Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        manager_id INTEGER,
        email TEXT,
        phone TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        purpose TEXT,
        user_id INTEGER NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'Draft',
        submission_date TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        merchant TEXT,
        description TEXT,
        receipt_path TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE report_status_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        actor_id INTEGER NOT NULL,
        comment TEXT,
        timestamp TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER NOT NULL,
        finance_user_id INTEGER NOT NULL,
        transaction_id TEXT,
        amount REAL NOT NULL,
        date TEXT,
        status TEXT NOT NULL DEFAULT 'Pending'
      );
    ''');

    await _seedData(db);
  }

  static Future<void> _seedData(Database db) async {
    // Seed users
    await db.insert('users', {
      'name': 'Employee One',
      'role': 'employee',
      'manager_id': 2,
      'email': 'emp1@company.com',
      'phone': '9999999999'
    });

    await db.insert('users', {
      'name': 'Manager One',
      'role': 'manager',
      'email': 'mgr1@company.com',
      'phone': '8888888888'
    });

    await db.insert('users', {
      'name': 'Finance One',
      'role': 'finance',
      'email': 'fin1@company.com',
      'phone': '7777777777'
    });
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
