import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'sample_tracker.db';
  static const _dbVersion = 3; // v3: ajout table circuit_site (many-to-many)

  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await _createMetadataTables(db);
        }
        if (oldV < 3) {
          // v3: ajoute la table circuit_site et hydrate depuis site.circuit_id si présent
          await _createCircuitSiteTable(db);
          // Hydratation initiale depuis l'ancien lien 1-N (si existait)
          // (ignore les doublons et les NULL)
          await db.execute('''
INSERT OR IGNORE INTO circuit_site (circuit_id, site_id)
SELECT circuit_id, id FROM site WHERE circuit_id IS NOT NULL;
''');
        }
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
CREATE TABLE metadata_version (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  version INTEGER NOT NULL,
  updated_at TEXT NOT NULL
);
''');
    await db.insert('metadata_version', {
      'id': 1,
      'version': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _createMetadataTables(db);

    await db.execute('''
CREATE TABLE sample (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  external_id TEXT,
  uuid TEXT UNIQUE NOT NULL,
  sample_conveyor INTEGER,
  referring_sample_id INTEGER,
  from_site_code TEXT,
  from_site_name TEXT,
  from_site_id INTEGER,
  destination_lab_id INTEGER,
  delivered_lab_id INTEGER,
  sample_identifier TEXT,
  patient_identifier TEXT,
  sample_type TEXT,
  sample_nature TEXT,
  start_mileage REAL,
  end_mileage REAL,
  result_start_mileage REAL,
  result_end_mileage REAL,
  collection_date TEXT,
  pickup_date TEXT,
  delivered_date TEXT,
  accepted_date TEXT,
  lab_number TEXT,
  sample_status TEXT,
  analysis_started_date TEXT,
  analysis_completed_date TEXT,
  analysis_released_date TEXT,
  result_collection_date TEXT,
  result_delivered_date TEXT,
  result_collector INTEGER,
  rejection_type_id INTEGER,
  rejection_comment TEXT,
  rejection_date TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  lastupdated_at TEXT,
  dirty INTEGER DEFAULT 1
);
''');

    await db.execute(
      'CREATE INDEX idx_sample_status ON sample(sample_status);',
    );
    await db.execute('CREATE INDEX idx_sample_type ON sample(sample_type);');
    await db.execute(
      'CREATE INDEX idx_sample_delivered_lab ON sample(delivered_lab_id);',
    );
    await db.execute(
      'CREATE INDEX idx_sample_destination_lab ON sample(destination_lab_id);',
    );
    await db.execute(
      'CREATE INDEX idx_sample_from_site ON sample(from_site_id);',
    );
    await db.execute('CREATE INDEX idx_sample_dirty ON sample(dirty);');
  }

  Future<void> _createMetadataTables(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS lab (
  id INTEGER PRIMARY KEY,
  name TEXT,
  lab_type TEXT
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS circuit (
  id INTEGER PRIMARY KEY,
  name TEXT
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS site (
  id INTEGER PRIMARY KEY,
  name TEXT,
  dhis_code TEXT,
  circuit_id INTEGER
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS rejection_type (
  id INTEGER PRIMARY KEY,
  name TEXT
);
''');

    await _createCircuitSiteTable(db);

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_site_circuit ON site(circuit_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lab_type ON lab(lab_type);',
    );
  }

  Future<void> _createCircuitSiteTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS circuit_site (
  circuit_id INTEGER NOT NULL,
  site_id INTEGER NOT NULL,
  PRIMARY KEY (circuit_id, site_id)
);
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_circuit_site_c ON circuit_site(circuit_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_circuit_site_s ON circuit_site(site_id);',
    );
  }
}

Future<void> ensureMetadataSchema() async {
  final db = await AppDatabase.instance.database;
  // idempotent calls already in _createMetadataTables; ensure version row exists
  final cur = await db.query('metadata_version', where: 'id = 1', limit: 1);
  if (cur.isEmpty) {
    await db.insert('metadata_version', {
      'id': 1,
      'version': 0,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
