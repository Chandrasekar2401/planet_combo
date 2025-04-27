import 'dart:convert';

List<PaymentRecord> paymentRecordsFromJson(String str) =>
    List<PaymentRecord>.from(json.decode(str).map((x) => PaymentRecord.fromJson(x)));

String paymentRecordsToJson(List<PaymentRecord> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaymentRecord {
  String? name;
  int? id;
  int? requestId;
  String? userId;
  int? hid;
  String? tax1Code;
  double? tax1Amount;
  String? tax2Code;
  double? tax2Amount;
  String? tax3Code;
  double? tax3Amount;
  int? requestType;
  double? amount;
  bool? isPaid;
  String? gatewayReference;
  String? paymentReference;
  int? paymentChanel;
  String? invoiceNumber;
  String? invoiceUrl;
  DateTime? creationDate;
  DateTime? paidDate;
  double? totalAmount;
  String? currency;
  String? paidStatus;
  String? unifiedRef;

  PaymentRecord({
    this.name,
    this.id,
    this.requestId,
    this.userId,
    this.hid,
    this.tax1Code,
    this.tax1Amount,
    this.tax2Code,
    this.tax2Amount,
    this.tax3Code,
    this.tax3Amount,
    this.requestType,
    this.amount,
    this.isPaid,
    this.gatewayReference,
    this.paymentReference,
    this.paymentChanel,
    this.invoiceNumber,
    this.invoiceUrl,
    this.creationDate,
    this.paidDate,
    this.totalAmount,
    this.currency,
    this.paidStatus,
    this.unifiedRef
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    name: json["userName"],
    id: json["id"],
    requestId: json["requestId"],
    userId: json["userId"],
    hid: json["hid"],
    tax1Code: json["tax1_Code"],
    tax1Amount: json["tax1_amount"]?.toDouble(),
    tax2Code: json["tax2_Code"],
    tax2Amount: json["tax2_amount"]?.toDouble(),
    tax3Code: json["tax3_Code"],
    tax3Amount: json["tax3_amount"]?.toDouble(),
    requestType: json["requestType"],
    amount: json["amount"]?.toDouble(),
    isPaid: json["isPaid"],
    gatewayReference: json["gatewayReference"] ?? "",
    paymentReference: json["paymentReference"],
    paymentChanel: json["paymentChanel"],
    invoiceNumber: json["invoiceNumber"],
    invoiceUrl: json["invoiceUrl"],
    creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
    paidDate: json["paidDate"] == null ? null : DateTime.parse(json["paidDate"]),
    totalAmount: json["total_amount"]?.toDouble(),
    currency: json["currency"],
    paidStatus: json["paid_status"],
    unifiedRef: json["unifiedRef"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "requestId": requestId,
    "userId": userId,
    "hid": hid,
    "tax1_Code": tax1Code,
    "tax1_amount": tax1Amount,
    "tax2_Code": tax2Code,
    "tax2_amount": tax2Amount,
    "tax3_Code": tax3Code,
    "tax3_amount": tax3Amount,
    "requestType": requestType,
    "amount": amount,
    "isPaid": isPaid,
    "gatewayReference": gatewayReference,
    "paymentReference": paymentReference,
    "paymentChanel": paymentChanel,
    "invoiceNumber": invoiceNumber,
    "invoiceUrl": invoiceUrl,
    "creationDate": creationDate?.toIso8601String(),
    "paidDate": paidDate?.toIso8601String(),
    "total_amount": totalAmount,
    "currency": currency,
    "paid_status": paidStatus,
    "unifiedRef":unifiedRef
  };
}