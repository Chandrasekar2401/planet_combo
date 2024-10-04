import 'dart:convert';

class PredictionResponse {
  final String status;
  final String message;
  final List<PredictionData> data;
  final String? errorMessage;

  PredictionResponse({
    required this.status,
    required this.message,
    required this.data,
    this.errorMessage,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      status: json['Status'],
      message: json['Message'],
      data: (json['Data'] as List)
          .map((item) => PredictionData.fromJson(item))
          .toList(),
      errorMessage: json['ErrorMessage'],
    );
  }
}

class PredictionData {
  String? prUserId;
  String? prHId;
  String? prRequestId;
  double? prRequestIdSeq;
  String? prSignification;
  DateTime? prDate;
  String? prEndTime;
  String? prDDasa;
  List<PredictionDetail>? prDetails;
  String? prFeedFlag;
  String? prCustomerCom;
  String? prAgentCom;
  String? prHComments;
  String? prRecDeleted;
  String? prStatus;
  String? prUnread;
  String? horoName;
  String? horoNativeImage;
  String? requestCat;
  String? userName;

  PredictionData({
    required this.prUserId,
    required this.prHId,
    required this.prRequestId,
    required this.prRequestIdSeq,
    required this.prSignification,
    required this.prDate,
    required this.prEndTime,
    required this.prDDasa,
    required this.prDetails,
    required this.prFeedFlag,
    required this.prCustomerCom,
    required this.prAgentCom,
    required this.prHComments,
    required this.prRecDeleted,
    required this.prStatus,
    required this.prUnread,
    required this.horoName,
    required this.horoNativeImage,
    required this.requestCat,
    required this.userName,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      prUserId: json['PRUSERID'],
      prHId: json['PRHID'].trim(),
      prRequestId: json['PRREQUESTID'].trim(),
      prRequestIdSeq: json['PRREQUESTIDSEQ'],
      prSignification: json['PRSIGNIFICATION'],
      prDate: DateTime.parse(json['PRDATE']),
      prEndTime: json['PRENDTIME'],
      prDDasa: json['PRDDASA'],
      prDetails: _parsePrDetails(json['PRDETAILS']),
      prFeedFlag: json['PRFEEDFLAG'],
      prCustomerCom: json['PRCUSTOMERCOM'],
      prAgentCom: json['PRAGENTCOM'],
      prHComments: json['PRHCOMMENTS'],
      prRecDeleted: json['PRRECDELETED'],
      prStatus: json['PRSTATUS'],
      prUnread: json['PRUNREAD'],
      horoName: json['HORONAME'],
      horoNativeImage: json['HORONATIVEIMAGE'],
      requestCat: json['RequestCat'].trim(),
      userName: json['UserName'],
    );
  }

  static List<PredictionDetail> _parsePrDetails(String jsonString) {
    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => PredictionDetail.fromJson(json)).toList();
  }
}

class PredictionDetail {
  final String ruleId;
  final String description;

  PredictionDetail({
    required this.ruleId,
    required this.description,
  });

  factory PredictionDetail.fromJson(Map<String, dynamic> json) {
    return PredictionDetail(
      ruleId: json['ruleId'],
      description: json['description'],
    );
  }
}