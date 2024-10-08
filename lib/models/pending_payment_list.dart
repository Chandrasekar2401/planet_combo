import 'dart:convert';

List<PendingPaymentList> pendingPaymentListFromJson(String str) =>
    List<PendingPaymentList>.from(json.decode(str).map((x) => PendingPaymentList.fromJson(x)));

String pendingPaymentListToJson(List<PendingPaymentList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PendingPaymentList {
  PendingPaymentList({
    this.name,
    this.amount,
    this.creationDate,
    this.currency,
    this.hid,
    this.id,
    this.invoiceNumber,
    this.invoiceUrl,
    this.isPaid,
    this.paidDate,
    this.paidStatus,
    this.paymentChanel,
    this.paymentReference,
    this.requestId,
    this.requestType,
    this.tax1Code,
    this.tax1Amount,
    this.tax2Code,
    this.tax2Amount,
    this.tax3Code,
    this.tax3Amount,
    this.totalAmount,
    this.userId,
  });

  String? name;
  double? amount;
  DateTime? creationDate;
  String? currency;
  int? hid;
  int? id;
  String? invoiceNumber;
  String? invoiceUrl;
  bool? isPaid;
  DateTime? paidDate;
  String? paidStatus;
  String? paymentChanel;
  String? paymentReference;
  int? requestId;
  int? requestType;
  String? tax1Code;
  double? tax1Amount;
  String? tax2Code;
  double? tax2Amount;
  String? tax3Code;
  double? tax3Amount;
  double? totalAmount;
  String? userId;

  factory PendingPaymentList.fromJson(Map<String, dynamic> json) => PendingPaymentList(
    name: _parseString(json["userName"]),
    amount: _parseDouble(json["amount"]),
    creationDate: _parseDateTime(json["creationDate"]),
    currency: _parseString(json["currency"]),
    hid: _parseInt(json["hid"]),
    id: _parseInt(json["id"]),
    invoiceNumber: _parseString(json["invoiceNumber"]),
    invoiceUrl: _parseString(json["invoiceUrl"]),
    isPaid: _parseBool(json["isPaid"]),
    paidDate: _parseDateTime(json["paidDate"]),
    paidStatus: _parseString(json["paid_status"]),
    paymentChanel: _parseString(json["paymentChanel"]),
    paymentReference: _parseString(json["paymentReference"]),
    requestId: _parseInt(json["requestId"]),
    requestType: _parseInt(json["requestType"]),
    tax1Code: _parseString(json["tax1_Code"]),
    tax1Amount: _parseDouble(json["tax1_amount"]),
    tax2Code: _parseString(json["tax2_Code"]),
    tax2Amount: _parseDouble(json["tax2_amount"]),
    tax3Code: _parseString(json["tax3_Code"]),
    tax3Amount: _parseDouble(json["tax3_amount"]),
    totalAmount: _parseDouble(json["total_amount"]),
    userId: _parseString(json["userId"]),
  );

  Map<String, dynamic> toJson() => {
    "name" : name,
    "amount": amount,
    "creationDate": creationDate?.toIso8601String(),
    "currency": currency,
    "hid": hid,
    "id": id,
    "invoiceNumber": invoiceNumber,
    "invoiceUrl": invoiceUrl,
    "isPaid": isPaid,
    "paidDate": paidDate?.toIso8601String(),
    "paid_status": paidStatus,
    "paymentChanel": paymentChanel,
    "paymentReference": paymentReference,
    "requestId": requestId,
    "requestType": requestType,
    "tax1_Code": tax1Code,
    "tax1_amount": tax1Amount,
    "tax2_Code": tax2Code,
    "tax2_amount": tax2Amount,
    "tax3_Code": tax3Code,
    "tax3_amount": tax3Amount,
    "total_amount": totalAmount,
    "userId": userId,
  };

  // Helper methods to parse different types
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}