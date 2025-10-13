class SiteModels {
  final int? idsite;
  final String namesite;

  SiteModels({this.idsite, required this.namesite});
  /* Convertir un objet en Map pour inserer dans la base de données */
  Map<String, dynamic> toMap() {
    return {'idsite': idsite, 'namesite': namesite};
  }

  factory SiteModels.fromMap(Map<String, dynamic> map) {
    return SiteModels(idsite: map['idsite'], namesite: map['namesite']);
  }
}
