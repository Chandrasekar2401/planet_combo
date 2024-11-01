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
      status: json['status'] ?? json['STATUS'],
      message: json['message'] ?? json['MESSAGE'],
      data: (json['data'] ?? json['DATA'] as List)
          .map((item) => PredictionData.fromJson(item))
          .toList(),
      errorMessage: json['errorMessage'] ?? json['ERRORMESSAGE'] ?? "Something went wrong",
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
    String getValueCaseInsensitive(Map<String, dynamic> map, String key) {
      return (map[key] ?? map[key.toUpperCase()] ?? '').toString().trim();
    }

    return PredictionData(
      prUserId: getValueCaseInsensitive(json, 'prUserId'),
      prHId: getValueCaseInsensitive(json, 'prHId'),
      prRequestId: getValueCaseInsensitive(json, 'prRequestId'),
      prRequestIdSeq: double.tryParse(getValueCaseInsensitive(json, 'prRequestIdSeq')),
      prSignification: getValueCaseInsensitive(json, 'prSignification'),
      prDate: DateTime.tryParse(getValueCaseInsensitive(json, 'prDate')),
      prEndTime: getValueCaseInsensitive(json, 'prEndTime'),
      prDDasa: getValueCaseInsensitive(json, 'prDDasa'),
      prDetails: _parsePrDetails(getValueCaseInsensitive(json, 'prDetails')),
      prFeedFlag: getValueCaseInsensitive(json, 'prFeedFlag'),
      prCustomerCom: getValueCaseInsensitive(json, 'prCustomerCom'),
      prAgentCom: getValueCaseInsensitive(json, 'prAgentCom'),
      prHComments: getValueCaseInsensitive(json, 'prHComments'),
      prRecDeleted: getValueCaseInsensitive(json, 'prRecDeleted'),
      prStatus: getValueCaseInsensitive(json, 'prStatus'),
      prUnread: getValueCaseInsensitive(json, 'prUnread'),
      horoName: getValueCaseInsensitive(json, 'horoName'),
      horoNativeImage: getValueCaseInsensitive(json, 'horoNativeImage'),
      requestCat: getValueCaseInsensitive(json, 'requestCat'),
      userName: getValueCaseInsensitive(json, 'userName'),
    );
  }

  static List<PredictionDetail> _parsePrDetails(String jsonString) {
    try {
      List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PredictionDetail.fromJson(json)).toList();
    } catch (e) {
      print("Error parsing prDetails: $e");
      return [];
    }
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
      ruleId: json['ruleId'] ?? json['RULEID'] ?? '',
      description: json['description'] ?? json['DESCRIPTION'] ?? '',
    );
  }
}