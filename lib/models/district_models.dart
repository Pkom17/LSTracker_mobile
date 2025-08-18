class DistrictModels {
  final int? iddistrict;
  final String namedistrict;

  DistrictModels({this.iddistrict, required this.namedistrict});
  /* Convertir un objet en Map pour inserer dans la base de données */
  Map<String, dynamic> toMap() {
    return {'iddistrict': iddistrict, 'namedistrict': namedistrict};
  }

  factory DistrictModels.fromMap(Map<String, dynamic> map) {
    return DistrictModels(
        iddistrict: map['iddistrict'], namedistrict: map['namedistrict']);
  }
}
