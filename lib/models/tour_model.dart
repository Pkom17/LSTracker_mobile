class TourModel {
  final int? idcircuitsite;
  final int? idcircuits;
  final int? idsites;

  TourModel({this.idcircuitsite, this.idcircuits, this.idsites});
  Map<String, dynamic> toMap() {
    return {
      'idcircuitsite': idcircuitsite,
      'idcircuits': idcircuits,
      'idsites': idsites
    };
  }

  factory TourModel.fromMap(Map<String, dynamic> map) {
    return TourModel(
        idcircuitsite: map['idcircuitsite'],
        idcircuits: map['idcircuits'],
        idsites: map['idsites']);
  }
}
