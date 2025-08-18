import 'package:flutter/material.dart';
import '../data/data_sample.dart';
import '../models/district_models.dart';

class DistrictNotifier extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  /* District provider */

  List<DistrictModels> _districts = [];
  List<DistrictModels> get districts => _districts;

  /*charger tous les districts et renvoyer la liste */
  Future<List<DistrictModels>> loadDistricts() async {
    _districts = await _dbHelper.getDistrict();
    notifyListeners();
    return _districts;
  }

  /*Ajouter un district */
  Future<void> addDistricts(DistrictModels districtModels) async {
    await _dbHelper.addDistrict(districtModels);
    await loadDistricts();
  }

  /*Mettre à jour de un district */
  Future<void> updateDistricts(DistrictModels districtModels) async {
    await _dbHelper.updateDistrict(districtModels);
    await loadDistricts();
  }

  /*Supprimer un district*/
  Future<void> deleteDistrict(int iddistrict) async {
    await _dbHelper.deleteDistrict(iddistrict);
    await loadDistricts();
  }
}
