import 'package:collection/collection.dart';

class SpecialPredictionList {
  String? status;
  String? message;
  List<SpecialPredictionHistory>? data;
  String? errorMessage;

  SpecialPredictionList({
    this.status,
    this.message,
    this.data,
    this.errorMessage,
  });

  factory SpecialPredictionList.fromJson(Map<String, dynamic> json) {
    return SpecialPredictionList(
      status: json["status"],
      message: json["message"],
      data: json["data"] != null
          ? List<SpecialPredictionHistory>.from(json["data"].map((x) => SpecialPredictionHistory.fromJson(x)))
          : null,
      errorMessage: json["errorMessage"],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.map((x) => x.toJson()).toList(),
    "errorMessage": errorMessage,
  };
}

class SpecialPredictionHistory {
  String? horoname;
  String? horonativeimage;
  String? pragentcom;
  String? prcustomercom;
  String? prdate;
  String? prddasa;
  String? prdetails;
  int? predictionId;
  String? prendtime;
  String? prfeedflag;
  String? prhcomments;
  int? prhid;
  String? prrecdeleted;
  String? prrequestid;
  int? prrequestidseq;
  String? prsignification;
  String? prstatus;
  String? prunread;
  String? pruserid;
  String? requestCat;
  String? userName;

  SpecialPredictionHistory({
    this.horoname,
    this.horonativeimage,
    this.pragentcom,
    this.prcustomercom,
    this.prdate,
    this.prddasa,
    this.prdetails,
    this.predictionId,
    this.prendtime,
    this.prfeedflag,
    this.prhcomments,
    this.prhid,
    this.prrecdeleted,
    this.prrequestid,
    this.prrequestidseq,
    this.prsignification,
    this.prstatus,
    this.prunread,
    this.pruserid,
    this.requestCat,
    this.userName,
  });

  factory SpecialPredictionHistory.fromJson(Map<String, dynamic> json) {
    return SpecialPredictionHistory(
      horoname: json["horoname"],
      horonativeimage: json["horonativeimage"],
      pragentcom: json["pragentcom"],
      prcustomercom: json["prcustomercom"],
      prdate: json["prdate"],
      prddasa: json["prddasa"],
      prdetails: json["prdetails"],
      predictionId: json["predictionId"],
      prendtime: json["prendtime"],
      prfeedflag: json["prfeedflag"],
      prhcomments: json["prhcomments"],
      prhid: json["prhid"],
      prrecdeleted: json["prrecdeleted"],
      prrequestid: json["prrequestid"],
      prrequestidseq: json["prrequestidseq"],
      prsignification: json["prsignification"],
      prstatus: json["prstatus"],
      prunread: json["prunread"],
      pruserid: json["pruserid"],
      requestCat: json["requestCat"],
      userName: json["userName"],
    );
  }

  Map<String, dynamic> toJson() => {
    "horoname": horoname,
    "horonativeimage": horonativeimage,
    "pragentcom": pragentcom,
    "prcustomercom": prcustomercom,
    "prdate": prdate,
    "prddasa": prddasa,
    "prdetails": prdetails,
    "predictionId": predictionId,
    "prendtime": prendtime,
    "prfeedflag": prfeedflag,
    "prhcomments": prhcomments,
    "prhid": prhid,
    "prrecdeleted": prrecdeleted,
    "prrequestid": prrequestid,
    "prrequestidseq": prrequestidseq,
    "prsignification": prsignification,
    "prstatus": prstatus,
    "prunread": prunread,
    "pruserid": pruserid,
    "requestCat": requestCat,
    "userName": userName,
  };
}