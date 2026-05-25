import 'package:lstracker/data/db/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialise une base SQLite **en mémoire** prête à être utilisée par
/// les DAOs via le singleton [AppDatabase].
///
/// Stratégie :
///   1. Active `sqflite_common_ffi` comme factory globale.
///   2. Ouvre une DB en mémoire (`inMemoryDatabasePath`).
///   3. Crée tout le schéma via [AppDatabase.createSchemaForTesting].
///   4. Injecte la DB dans le singleton (`databaseForTests=`).
///
/// Couplé à [tearDownTestDb] dans `tearDown()`.
Future<void> setUpTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
  await AppDatabase.instance.createSchemaForTesting(db);
  AppDatabase.instance.databaseForTests = db;
}

/// Ferme la DB de test et nettoie le singleton.
Future<void> tearDownTestDb() async {
  await AppDatabase.instance.resetForTests();
}
