class PredictionDetailItem {
  final String pruserid;
  final int prhid;
  final String prrequestid;
  final double prrequestidseq;
  final String? prsignification;
  final String prdate;
  final String? prendtime;
  final String? prddasa;
  final String prdetails;
  final String? prfeedflag;
  final String? prcustomercom;
  final String? pragentcom;
  final String? prhcomments;
  final String? prrecdeleted;
  final String? prstatus;
  final String? prunread;
  final int id;

  PredictionDetailItem({
    required this.pruserid,
    required this.prhid,
    required this.prrequestid,
    required this.prrequestidseq,
    this.prsignification,
    required this.prdate,
    this.prendtime,
    this.prddasa,
    required this.prdetails,
    this.prfeedflag,
    this.prcustomercom,
    this.pragentcom,
    this.prhcomments,
    this.prrecdeleted,
    this.prstatus,
    this.prunread,
    required this.id,
  });

  factory PredictionDetailItem.fromJson(Map<String, dynamic> json) {
    return PredictionDetailItem(
      pruserid: json['pruserid'],
      prhid: json['prhid'],
      prrequestid: json['prrequestid'],
      prrequestidseq: json['prrequestidseq'],
      prsignification: json['prsignification'],
      prdate: json['prdate'],
      prendtime: json['prendtime'],
      prddasa: json['prddasa'],
      prdetails: json['prdetails'],
      prfeedflag: json['prfeedflag'],
      prcustomercom: json['prcustomercom'],
      pragentcom: json['pragentcom'],
      prhcomments: json['prhcomments'],
      prrecdeleted: json['prrecdeleted'],
      prstatus: json['prstatus'],
      prunread: json['prunread'],
      id: json['id'],
    );
  }
}