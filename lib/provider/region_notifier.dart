import 'package:flutter/material.dart';
import '../data/data_sample.dart';
import '../models/region_models.dart';

class RegionNotifier extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

/*Region provider*/

  List<RegionModels> _regions = [];
  List<RegionModels> get regions => _regions;

  /*charger toutes les regions et renvoyer la liste */
  Future<List<RegionModels>> loadRegions() async {
    _regions = await _dbHelper.getRegion();
    notifyListeners();
    return _regions;
  }

  /*Ajouter une region */
  Future<void> addRegion(RegionModels regionModels) async {
    await _dbHelper.addRegion(regionModels);
    await loadRegions();
  }

  /*Mettre à jour d'une region */
  Future<void> updateRegion(RegionModels regionModels) async {
    await _dbHelper.updateRegion(regionModels);
    await loadRegions();
  }

  /*Supprimer une region*/
  Future<void> deleteRegion(int regionid) async {
    await _dbHelper.deleteRegion(regionid);
    await loadRegions();
  }
}
