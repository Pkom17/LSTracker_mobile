import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class LabDao {
  Future<Database> get _db async => AppDatabase.instance.database;

  /// Retourne un map { id -> name } pour les IDs fournis
  Future<Map<int, String>> namesByIds(Set<int> ids) async {
    if (ids.isEmpty) return {};
    final db = await _db;

    // placeholders: "?, ?, ?"
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT id, name FROM lab WHERE id IN ($placeholders)',
      ids.toList(),
    );

    final map = <int, String>{};
    for (final r in rows) {
      final id = (r['id'] as num).toInt();
      final name = (r['name'] as String?)?.trim() ?? '';
      map[id] = name.isEmpty ? 'Laboratoire $id' : name;
    }
    return map;
  }

  /// Optionnel : récupérer un seul nom par id
  Future<String?> nameById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'lab',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (rows.first['name'] as String?)?.trim();
  }
}
