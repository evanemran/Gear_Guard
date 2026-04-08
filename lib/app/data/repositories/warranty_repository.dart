import 'package:gearguard/app/data/models/warranty_item.dart';
import 'package:gearguard/app/data/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class WarrantyRepository {
  Future<List<WarrantyItem>> getAllWarranties() async {
    final Database db = await DatabaseProvider.instance.database;
    final List<Map<String, Object?>> rows = await db.query(
      DatabaseProvider.warrantyTable,
      orderBy: 'expiry_date ASC',
    );
    return rows.map(WarrantyItem.fromMap).toList();
  }

  Future<int> insertWarranty(WarrantyItem item) async {
    final Database db = await DatabaseProvider.instance.database;
    return db.insert(DatabaseProvider.warrantyTable, item.toMap());
  }

  Future<int> updateWarranty(WarrantyItem item) async {
    final Database db = await DatabaseProvider.instance.database;
    return db.update(
      DatabaseProvider.warrantyTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[item.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteWarranty(int id) async {
    final Database db = await DatabaseProvider.instance.database;
    return db.delete(
      DatabaseProvider.warrantyTable,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}
