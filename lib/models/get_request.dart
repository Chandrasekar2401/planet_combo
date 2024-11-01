import 'package:collection/collection.dart';

class RequestList {
  String? status;
  String? message;
  List<RequestHistory>? data;
  String? errorMessage;

  RequestList({
    this.status,
    this.message,
    this.data,
    this.errorMessage,
  });

  factory RequestList.fromJson(Map<String, dynamic> json) {
    final lowercaseJson = json.map((key, value) => MapEntry(key.toLowerCase(), value));

    return RequestList(
      status: lowercaseJson["status"],
      message: lowercaseJson["message"],
      data: lowercaseJson["data"] != null
          ? List<RequestHistory>.from(lowercaseJson["data"].map((x) => RequestHistory.fromJson(x)))
          : null,
      errorMessage: lowercaseJson["errormessage"],
    );
  }

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
    "Data": data?.map((x) => x.toJson()).toList(),
    "ErrorMessage": errorMessage,
  };
}

class RequestHistory {
  String? rquserid;
  dynamic rqhid;
  String? rqid;
  String? reqcat;
  String? rqspecialdetails;
  String? rqsdate;
  String? rqedate;
  String? rqlongtidue;
  String? rqlongtitudeew;
  String? rqlatitude;
  String? rqlatitudens;
  String? rqdst;
  String? rqrecdeleted;
  String? rqprstatus;
  String? rqunread;
  String? rqcharge;
  String? horoname;
  String? predictiondetail;
  String? horonativeimage;
  String? repeat;
  dynamic timestamp;
  String? username;
  String? reqcredate;
  String? creatdate;
  String? completedatetime;

  RequestHistory({
    this.rquserid,
    this.rqhid,
    this.rqid,
    this.reqcat,
    this.rqspecialdetails,
    this.rqsdate,
    this.rqedate,
    this.rqlongtidue,
    this.rqlongtitudeew,
    this.rqlatitude,
    this.rqlatitudens,
    this.rqdst,
    this.rqrecdeleted,
    this.rqprstatus,
    this.rqunread,
    this.rqcharge,
    this.horoname,
    this.predictiondetail,
    this.horonativeimage,
    this.repeat,
    this.timestamp,
    this.username,
    this.reqcredate,
    this.creatdate,
    this.completedatetime,
  });

  factory RequestHistory.fromJson(Map<String, dynamic> json) {
    final lowercaseJson = json.map((key, value) => MapEntry(key.toLowerCase(), value));

    return RequestHistory(
      rquserid: lowercaseJson["rquserid"],
      rqhid: lowercaseJson["rqhid"],
      rqid: lowercaseJson["rqid"],
      reqcat: lowercaseJson["reqcat"],
      rqspecialdetails: lowercaseJson["rqspecialdetails"],
      rqsdate: lowercaseJson["rqsdate"],
      rqedate: lowercaseJson["rqedate"],
      rqlongtidue: lowercaseJson["rqlongtidue"],
      rqlongtitudeew: lowercaseJson["rqlongtitudeew"],
      rqlatitude: lowercaseJson["rqlatitude"],
      rqlatitudens: lowercaseJson["rqlatitudens"],
      rqdst: lowercaseJson["rqdst"],
      rqrecdeleted: lowercaseJson["rqrecdeleted"],
      rqprstatus: lowercaseJson["rqprstatus"],
      rqunread: lowercaseJson["rqunread"],
      rqcharge: lowercaseJson["rqcharge"],
      horoname: lowercaseJson["horoname"],
      predictiondetail: (lowercaseJson["predictiondetail"]),
      horonativeimage: lowercaseJson["horonativeimage"],
      repeat: lowercaseJson["repeat"],
      timestamp: lowercaseJson["timestamp"],
      username: lowercaseJson["username"],
      reqcredate: lowercaseJson["reqcredate"],
      creatdate: lowercaseJson["creatdate"],
      completedatetime: lowercaseJson["completedatetime"],
    );
  }

  Map<String, dynamic> toJson() => {
    "RQUSERID": rquserid,
    "RQHID": rqhid,
    "RQID": rqid,
    "REQCAT": reqcat,
    "RQSPECIALDETAILS": rqspecialdetails,
    "RQSDATE": rqsdate,
    "RQEDATE": rqedate,
    "RQLONGTIDUE": rqlongtidue,
    "RQLONGTITUDEEW": rqlongtitudeew,
    "RQLATITUDE": rqlatitude,
    "RQLATITUDENS": rqlatitudens,
    "RQDST": rqdst,
    "RQRECDELETED": rqrecdeleted,
    "RQPRSTATUS": rqprstatus,
    "RQUNREAD": rqunread,
    "RQCHARGE": rqcharge,
    "HORONAME": horoname,
    "PredictionDetail": predictiondetail,
    "HORONATIVEIMAGE": horonativeimage,
    "REPEAT": repeat,
    "TIMESTAMP": timestamp,
    "UserName": username,
    "REQCREDATE": reqcredate,
    "CREATDATE": creatdate,
    "COMPLETEDATETIME": completedatetime,
  };
}