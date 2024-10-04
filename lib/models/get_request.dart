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

  factory RequestList.fromJson(Map<String, dynamic> json) => RequestList(
    status: json["Status"],
    message: json["Message"],
    data: List<RequestHistory>.from(json["Data"].map((x) => RequestHistory.fromJson(x))),
    errorMessage: json["ErrorMessage"],
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
    "Data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "ErrorMessage": errorMessage,
  };
}

// Step 2: Define RequestHistory class
class RequestHistory {
  String? rquserid;
  String? rqhid;
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

  factory RequestHistory.fromJson(Map<String, dynamic> json) => RequestHistory(
    rquserid: json["RQUSERID"],
    rqhid: json["RQHID"],
    rqid: json["RQID"],
    reqcat: json["REQCAT"],
    rqspecialdetails: json["RQSPECIALDETAILS"],
    rqsdate: json["RQSDATE"],
    rqedate: json["RQEDATE"],
    rqlongtidue: json["RQLONGTIDUE"],
    rqlongtitudeew: json["RQLONGTITUDEEW"],
    rqlatitude: json["RQLATITUDE"],
    rqlatitudens: json["RQLATITUDENS"],
    rqdst: json["RQDST"],
    rqrecdeleted: json["RQRECDELETED"],
    rqprstatus: json["RQPRSTATUS"],
    rqunread: json["RQUNREAD"],
    rqcharge: json["RQCHARGE"],
    horoname: json["HORONAME"],
    predictiondetail: json["PredictionDetail"],
    horonativeimage: json["HORONATIVEIMAGE"],
    repeat: json["REPEAT"],
    timestamp: json["TIMESTAMP"],
    username: json["UserName"],
    reqcredate: json["REQCREDATE"],
    creatdate: json["CREATDATE"],
    completedatetime: json["COMPLETEDATETIME"],
  );

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
