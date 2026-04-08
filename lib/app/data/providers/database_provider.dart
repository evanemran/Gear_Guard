import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider instance = DatabaseProvider._();

  static const String _databaseName = 'gearguard.db';
  static const int _databaseVersion = 2;

  static const String warrantyTable = 'warranties';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $warrantyTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT NOT NULL,
            brand TEXT NOT NULL,
            shop_name TEXT NOT NULL DEFAULT '',
            serial_number TEXT NOT NULL,
            purchase_date TEXT NOT NULL,
            expiry_date TEXT NOT NULL,
            price REAL NOT NULL,
            notes TEXT NOT NULL,
            has_receipt INTEGER NOT NULL,
            product_image_path TEXT,
            invoice_image_path TEXT
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE $warrantyTable ADD COLUMN shop_name TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE $warrantyTable ADD COLUMN product_image_path TEXT',
          );
          await db.execute(
            'ALTER TABLE $warrantyTable ADD COLUMN invoice_image_path TEXT',
          );
        }
      },
    );
  }
}
