import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const localUserId = 'local-user';

class LocalDatabase {
  LocalDatabase._();

  static final instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasesPath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasesPath, 'dukan_khata.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            photo_url TEXT,
            default_cost_price REAL NOT NULL,
            default_sale_price REAL NOT NULL,
            stock_quantity INTEGER NOT NULL DEFAULT 0,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sales (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            product_id TEXT,
            product_name_snapshot TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            cost_price REAL NOT NULL,
            sale_price REAL NOT NULL,
            revenue REAL NOT NULL,
            profit REAL NOT NULL,
            input_method TEXT NOT NULL,
            sold_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE stock_purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            purchase_price REAL NOT NULL,
            total_cost REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE inventory_adjustments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id TEXT NOT NULL,
            quantity_change INTEGER NOT NULL,
            reason TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE app_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event TEXT NOT NULL,
            details TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> initialize() async {
    await database;
  }

  Future<void> log(String event, Map<String, Object?> values) async {
    final db = await database;
    await db.insert('app_logs', {
      'event': event,
      'details': values.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(' | '),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
