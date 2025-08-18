import 'package:flutter/material.dart';

import '../../models/circuit_models.dart';
import '../data/data_sample.dart';

class CircuitNotifier extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /*Liste des circuits */
  List<CircuitModels> _circuits = [];
  List<CircuitModels> get circuits => _circuits;

  /*charger tous des circuits et renvoyer la liste */
  Future<List<CircuitModels>> loadCircuits() async {
    _circuits = await _dbHelper.getCircuits();
    notifyListeners();
    return _circuits;
  }

  /*Ajouter un circuit */
  Future<void> addCircuit(CircuitModels circuitModels) async {
    await _dbHelper.addCircuit(circuitModels);
    await loadCircuits();
  }

  /*Mettre à jour un circuit */
  Future<void> updateCircuit(CircuitModels circuitModels) async {
    await _dbHelper.updateCircuit(circuitModels);
    await loadCircuits();
  }

  /*Supprimer un circuit*/
  Future<void> deleteCircuit(int idcircuit) async {
    await _dbHelper.deleteCircuit(idcircuit);
    await loadCircuits();
  }

  /* site provider*/
}
