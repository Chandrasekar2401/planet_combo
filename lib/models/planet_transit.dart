class PlanetTransitModel {
  String? trplanet;
  String? trsdate;
  String? tredate;
  String? trstartkey;
  String? trendkey;
  String? trdetails;
  String? active;

  PlanetTransitModel({
    this.trplanet,
    this.trsdate,
    this.tredate,
    this.trstartkey,
    this.trendkey,
    this.trdetails,
    this.active,
  });

  factory PlanetTransitModel.fromJson(json) {
    final trplanet = json["TRPLANET"];
    final trsdate = json["TRSDATE"];
    final tredate = json["TREDATE"];
    final trstartkey = json["TRSTARTKEY"];
    final trendkey = json["TRENDKEY"];
    final trdetails = json["TRDETAILS"];
    final active = json["ACTIVE"];

    return PlanetTransitModel(
        trplanet : trplanet,
        trsdate: trsdate,
        tredate: tredate,
        trstartkey: trstartkey,
        trendkey: trendkey,
      trdetails: trdetails,
        active: active

    );
  }
}