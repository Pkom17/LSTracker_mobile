import 'package:flutter/material.dart';

import '../data/data_sample.dart';
import '../models/site_models.dart';

class SiteNotifier extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<SiteModels> _sites = [];
  List<SiteModels> get sites => _sites;

  /*charger tous les sites et renvoyer la liste */
  Future<List<SiteModels>> loadSites() async {
    _sites = await _dbHelper.getSite();
    notifyListeners();
    return _sites;
  }

  /*Ajouter un site */
  Future<void> addSite(SiteModels siteModels) async {
    await _dbHelper.addSite(siteModels);
    await loadSites();
  }

  /*Mettre à jour un site */
  Future<void> updateSites(SiteModels siteModels) async {
    await _dbHelper.updateSite(siteModels);
    await loadSites();
  }

  /*Supprimer un site*/
  Future<void> deleteSite(int idsite) async {
    await _dbHelper.deleteSite(idsite);
    await loadSites();
  }
}
