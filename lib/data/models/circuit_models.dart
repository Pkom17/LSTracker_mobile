import 'package:lstracker/data/models/site_models.dart';

class CircuitModels {
  final int? idcircuit;
  final String name;
  final List<SiteModels> sites;

  CircuitModels({this.idcircuit, required this.name, required this.sites});
  /* Convertir un objet en Map pour inserer dans la base de données */
  Map<String, dynamic> toMap() {
    return {'idcircuit': idcircuit, 'name': name, 'sites': sites};
  }

  factory CircuitModels.fromMap(Map<String, dynamic> map) {
    return CircuitModels(
      idcircuit: map['idcircuit'],
      name: map['name'],
      sites: map['sites'],
    );
  }
}
