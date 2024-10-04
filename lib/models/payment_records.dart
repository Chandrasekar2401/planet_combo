// To parse this JSON data, do
//
//     final messagesList = messagesListFromJson(jsonString);

import 'dart:convert';

PaymentRecords paymentListFromJson(String str) => PaymentRecords.fromJson(json.decode(str));

String paymentListToJson(PaymentRecords data) => json.encode(data.toJson());

class PaymentRecords {
  String? status;
  String? message;
  List<PaymentHistory>? data;
  String? errorMessage;

  PaymentRecords({
    this.status,
    this.message,
    this.data,
    this.errorMessage,
  });

  factory PaymentRecords.fromJson(Map<String, dynamic> json) => PaymentRecords(
    status: json["Status"],
    message: json["Message"],
    data: List<PaymentHistory>.from(json["Data"]['PrimaryList'].map((x) => PaymentHistory.fromJson(x))),
    errorMessage: json["ErrorMessage"],
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
    "Data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "ErrorMessage": errorMessage,
  };
}

class PaymentHistory {
  String? uid;
  String? hid;
  String? paymentrequest;
  String? invoice;
  String? invoicedate;
  String? paymentlinkrefnumber;
  double? totalinvocieamount;
  String? pprefnumber;
  String?  currency;
  String? paiddate;
  double? paidamount;
  String? paidstatus;

  PaymentHistory({
    this.uid,
    this.hid,
    this.paymentrequest,
    this.invoice,
    this.invoicedate,
    this.paymentlinkrefnumber,
    this.totalinvocieamount,
    this.pprefnumber,
    this.currency,
    this.paiddate,
    this.paidamount,
    this.paidstatus,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => PaymentHistory(
    uid: json["UID"],
    hid: json["HID"],
    paymentrequest: json["PAYMENTREQUEST"],
    invoice: json["INVOICE"],
    invoicedate: json["INVOICEDATE"],
    paymentlinkrefnumber: json["PAYMENTLINKREFNUMBER"],
    totalinvocieamount: json["TOTALINVOICEAMOUNT"],
    pprefnumber: json["PPREFNUMBER"],
    currency: json["CURRENCY"],
    paiddate: json["PAIDDATE"],
    paidamount: json["PAIDAMOUNT"],
    paidstatus: json["PAIDSTATUS"],
  );

  Map<String, dynamic> toJson() => {
    "UID": uid,
    "HID": hid,
    "PAYMENTREQUEST": paymentrequest,
    "INVOICE": invoice,
    "INVOICEDATE": invoicedate,
    "PAYMENTLINKREFNUMBER": paymentlinkrefnumber,
    "TOTALINVOICEAMOUNT": totalinvocieamount,
    "PPREFNUMBER": pprefnumber,
    "CURRENCY": currency,
    "PAIDDATE": paiddate,
    "PAIDAMOUNT": paidamount,
    "PAIDSTATUS": paidstatus,
  };
}
