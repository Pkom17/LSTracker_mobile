// import 'dart:io';

// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:lstrackers/models/axe_models.dart';

// class DataSample {
//   static Database? _dataBase;

//   Future<Database> get dataBase async {
//     if (_dataBase != null) return _dataBase!;
//     return await createDataBase();
//   }

//   Future<Database> createDataBase() async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     final path = join(directory.path, 'database.db');
//     return await openDatabase(path, version: 1, onCreate: onCreate);
//   }

//   onCreate(Database database, int version) async {
//     await database.execute(
//         ''' CREATE TABLE axeModels (id INTEGER PRIMARY KEY AUTOINCREMENT, axetitle TEXT NOT NULL, dropdownvalue TEXT NOT NULL) ''');
//   }

//   /*
//   _initDB(String path) async {
//     final dbPath = await getDatabasesPath();
//     final dbLocation = join(dbPath, path);
//     return openDatabase(dbLocation, version: 1, onCreate: (db, verion) async {
//       await db.execute(
//           ''' CREATE TABLE axeModels (id INTEGER PRIMARY KEY AUTOINCREMENT, axetitle TEXT NOT NUL, dropdownvalue TEXT NOT NULL) ''');
//       await db.execute(
//           ''' CREATE TABLE targetModels (id INTEGER PRIMARY KEY AUTOINCREMENT, longitude TEXT NOT NULL, latitude TEXT NOT NULL) ''');
//       await db.execute(
//           ''' CREATE TABLE collectSite (idsite INTEGER PRIMARY KEY AUTOINCREMENT, site TEXT NOT NULL, kmarrive TEXT NOT NULL, axeid INTEGER NOT NULL, FOREIGN KEY (axeid) REFERENCE axeModels(id)) ''');
//     });
//   }
//    */

//   /* Obtenir une données */
//   Future<List<AxeModels>> addData() async {
//     Database db = await dataBase;
//     const query = 'SELECT * FROM axeModels ';
//     List<Map<String, dynamic>> mapList = await db.rawQuery(query);
//     return mapList.map((map) => AxeModels.formJson(map)).toList();
//   }

//   /* Ajouter des données */
//   Future<bool> addliste(String text) async {
//     Database db = await dataBase;
//     await db.insert('axeModels', {'axetitle': text, 'dropdownvalue': text});
//     return true;
//   }

//   /* Ajouter des données chatgpt */
//   Future<void> insertData(AxeModels axeModels) async {
//     final db = await dataBase;
//     await db.insert("axeModels", axeModels.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   /* Recuperer les données depuis la base de données */

//   Future<List<AxeModels>> getAllData() async {
//     final db = await dataBase;
//     final List<Map<String, dynamic>> maps = await db.query('axeModels');
//     return List.generate(maps.length, (i) {
//       return AxeModels.formJson(maps[i]);
//     });

//     /* final result = await db.query("axe");
//     return result.map((e) => AxeModels.fromMap(e)).toList();*/
//   }

//   /* Mettre à jour les données dans la base de données */

//   Future<int> updateData(AxeModels axeModels, int id) async {
//     final db = await dataBase;
//     return await db
//         .update('axeModels', axeModels.toMap(), where: 'id=?', whereArgs: [id]);

//     /*await db.delete('axe', where: 'id = ?', whereArgs: [id]);*/
//   }

//   /* Supprimer les données de la table dans la base de données */
//   Future<int> deleteData(AxeModels axeModels, int id) async {
//     final db = await dataBase;
//     return await db.delete('axeModels', where: 'id=?', whereArgs: [id]);
//   }

//   Future close() async {
//     final db = await dataBase;
//     db.close();
//   }
// }
import 'dart:async';
import 'package:lstracker/models/tour_model.dart';

import '../models/district_models.dart';
import '../models/region_models.dart';
import '../models/site_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/circuit_models.dart';

class DatabaseHelper {
  /*1- Declaration des variables */
  static const String _dbName = 'Sample.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'circuits';
  static const String _tableRegions = 'regions';
  static const String _tableDistrict = 'districts';
  static const String _tableSite = 'sites';
  static const String _tableCircuitSite = 'circiutsite ';

  /* 2- Singleton de la base de données */

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  Database? _database;
  /* 3- Connexion de la base de données */
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  /* 4- Connexion de la base de données */

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  /* 5- Creation des tables dans la base de données */
  Future<void> _onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute("PRAGMA foreign_keys= ON");
    batch.execute(
      ''' CREATE TABLE $_tableName (idcircuit INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)''',
    );
    batch.execute(
      ''' CREATE TABLE $_tableRegions (regionid INTEGER PRIMARY KEY AUTOINCREMENT, region TEXT NOT NULL)''',
    );
    batch.execute(
      ''' CREATE TABLE $_tableDistrict (iddistrict INTEGER PRIMARY KEY AUTOINCREMENT, namedistrict TEXT NOT NULL)''',
    );
    batch.execute(
      ''' CREATE TABLE $_tableSite (idsite INTEGER PRIMARY KEY AUTOINCREMENT, namesite TEXT NOT NULL)''',
    );
    batch.execute(
      ''' CREATE TABLE $_tableCircuitSite (idcircuitsite INTEGER PRIMARY KEY, idsites INTEGER NOT NULL ,idcircuits INTEGER NOT NULL, 
                  FOREIGN KEY (idcircuits) REFERENCES $_tableName(idcircuit) ON DELETE CASCADE,
                  FOREIGN KEY (idsites) REFERENCES $_tableSite(idsites) ON DELETE CASCADE)  ''',
    );
    await batch.commit();
  }

  /* 6- Ajouter un circuit */
  Future<int> addCircuit(CircuitModels circuitModels) async {
    Database db = await database;
    int circuitid = await db.insert(
      _tableName,
      circuitModels.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var site in circuitModels.sites) {
      TourModel tourModel = TourModel(
        idcircuits: circuitid,
        idsites: site.idsite,
      );
      await db.insert(_tableCircuitSite, tourModel.toMap());
    }

    return circuitid;
  }

  /* 7- Récuperer un circuit*/
  Future<List<CircuitModels>> getCircuits() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return maps.map((map) => CircuitModels.fromMap(map)).toList();
  }

  /* 8- Mettre à jour un circuit*/
  Future<int> updateCircuit(CircuitModels circuitsModels) async {
    Database db = await database;
    return await db.rawUpdate(
      'UPDATE $_tableName SET name = "${circuitsModels.name}" WHERE idcircuit= ${circuitsModels.idcircuit}',
    );
  }

  /* 9- Supprimer un circuit*/
  Future<int> deleteCircuit(int idcircuit) async {
    Database db = await database;
    return await db.rawDelete(
      'DELETE FROM $_tableName WHERE idcircuit= ${idcircuit}',
    );
  }

  /* Region*/

  /* 1- Ajouter une region */
  Future<int> addRegion(RegionModels regionModels) async {
    Database db = await database;
    return await db.insert(
      _tableRegions,
      regionModels.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /* 2- Récuperer une region*/
  Future<List<RegionModels>> getRegion() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableRegions);
    return maps.map((map) => RegionModels.fromMap(map)).toList();
  }

  /* 3- Mettre à jour la region*/
  Future<int> updateRegion(RegionModels regionModels) async {
    Database db = await database;
    return await db.rawUpdate(
      'UPDATE $_tableRegions SET region = "${regionModels.region}" WHERE regionid= ${regionModels.regionid}',
    );
  }

  /* 4- Supprimer une region*/
  Future<int> deleteRegion(int regionid) async {
    Database db = await database;
    return await db.rawDelete(
      'DELETE FROM $_tableRegions WHERE regionid= ${regionid}',
    );
  }

  /* District*/

  /* 1- Ajouter un district */
  Future<int> addDistrict(DistrictModels districtModels) async {
    Database db = await database;
    return await db.insert(
      _tableDistrict,
      districtModels.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /* 2- Récuperer un district*/
  Future<List<DistrictModels>> getDistrict() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableDistrict);
    return maps.map((map) => DistrictModels.fromMap(map)).toList();
  }

  /* 3- Mettre à jour un circuit*/
  Future<int> updateDistrict(DistrictModels districtModels) async {
    Database db = await database;
    return await db.rawUpdate(
      'UPDATE $_tableDistrict SET namedistrict = "${districtModels.namedistrict}" WHERE iddistrict= ${districtModels.iddistrict}',
    );
  }

  /* 4- Supprimer un circuit*/
  Future<int> deleteDistrict(int iddistrict) async {
    Database db = await database;
    return await db.rawDelete(
      'DELETE FROM $_tableDistrict WHERE iddistrict= ${iddistrict}',
    );
  }

  /* Etablissement*/

  /* 1- Ajouter un site */
  Future<int> addSite(SiteModels siteModels) async {
    Database db = await database;
    return await db.insert(
      _tableSite,
      siteModels.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /* 2- Récuperer un site*/
  Future<List<SiteModels>> getSite() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableSite);
    return maps.map((map) => SiteModels.fromMap(map)).toList();
  }

  /* 3- Mettre à jour un site*/
  Future<int> updateSite(SiteModels siteModels) async {
    Database db = await database;
    return await db.rawUpdate(
      'UPDATE $_tableSite SET namesite = "${siteModels.namesite}" WHERE idsite= ${siteModels.idsite}',
    );
  }

  /* 4- Supprimer un site*/
  Future<int> deleteSite(int idsite) async {
    Database db = await database;
    return await db.rawDelete(
      'DELETE FROM $_tableSite WHERE idsite= ${idsite}',
    );
  }

  /* circuit site*/
  /* 1- Ajouter un circuitsite */
  Future<int> addTour(TourModel tourModels) async {
    Database db = await database;
    return await db.insert(
      _tableCircuitSite,
      tourModels.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /* 2- Récuperer un circuitsite*/
  Future<List<TourModel>> getTour() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableCircuitSite);
    return maps.map((map) => TourModel.fromMap(map)).toList();
  }

  /* 3- Mettre à jour un circuitsite*/
  Future<int> updateTour(TourModel tourModels) async {
    Database db = await database;
    return await db.rawUpdate(
      'UPDATE $_tableCircuitSite SET idcircuitsite = "${tourModels.idcircuits}, ${tourModels.idsites}" WHERE idcircuisite= ${tourModels.idcircuitsite}',
    );
  }

  /* 4- Supprimer un cicuitsite*/
  Future<int> deleteTour(int idcircuitsite) async {
    Database db = await database;
    return await db.rawDelete(
      'DELETE FROM $_tableCircuitSite WHERE idcircuitsite= ${idcircuitsite}',
    );
  }
}
