class RegionModels {
  final int? regionid;
  final String region;

  RegionModels({this.regionid, required this.region});
  /* Convertir un objet en Map pour inserer dans la base de données */
  Map<String, dynamic> toMap() {
    return {'regionid': regionid, 'region': region};
  }

  factory RegionModels.fromMap(Map<String, dynamic> map) {
    return RegionModels(regionid: map['regionid'], region: map['region']);
  }
}
