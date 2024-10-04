// To parse this JSON data, do
//
//     final messagesList = messagesListFromJson(jsonString);

import 'dart:convert';

MessagesList messagesListFromJson(String str) => MessagesList.fromJson(json.decode(str));

String messagesListToJson(MessagesList data) => json.encode(data.toJson());

class MessagesList {
  String? status;
  String? message;
  List<MessageHistory>? data;
  String? errorMessage;

  MessagesList({
    this.status,
    this.message,
    this.data,
    this.errorMessage,
  });

  factory MessagesList.fromJson(Map<String, dynamic> json) => MessagesList(
    status: json["Status"],
    message: json["Message"],
    data: List<MessageHistory>.from(json["Data"].map((x) => MessageHistory.fromJson(x))),
    errorMessage: json["ErrorMessage"],
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
    "Data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "ErrorMessage": errorMessage,
  };
}

class MessageHistory {
  String? msguserid;
  String? msghid;
  String? msgmessageid;
  String? msgcustomercom;
  String? msgagentcom;
  String? msghcomments;
  String? msgstatus;
  String? msgunread;
  String?  msgdeleted;
  String? horoname;
  String? horonativeimage;
  String? userName;

  MessageHistory({
    this.msguserid,
    this.msghid,
    this.msgmessageid,
    this.msgcustomercom,
    this.msgagentcom,
    this.msghcomments,
    this.msgstatus,
    this.msgunread,
    this.msgdeleted,
    this.horoname,
    this.horonativeimage,
    this.userName,
  });

  factory MessageHistory.fromJson(Map<String, dynamic> json) => MessageHistory(
    msguserid: json["MSGUSERID"],
    msghid: json["MSGHID"],
    msgmessageid: json["MSGMESSAGEID"],
    msgcustomercom: json["MSGCUSTOMERCOM"],
    msgagentcom: json["MSGAGENTCOM"],
    msghcomments: json["MSGHCOMMENTS"],
    msgstatus: json["MSGSTATUS"],
    msgunread: json["MSGUNREAD"],
    msgdeleted: json["MSGDELETED"],
    horoname: json["HORONAME"],
    horonativeimage: json["HORONATIVEIMAGE"],
    userName: json["UserName"],
  );

  Map<String, dynamic> toJson() => {
    "MSGUSERID": msguserid,
    "MSGHID": msghid,
    "MSGMESSAGEID": msgmessageid,
    "MSGCUSTOMERCOM": msgcustomercom,
    "MSGAGENTCOM": msgagentcom,
    "MSGHCOMMENTS": msghcomments,
    "MSGSTATUS": msgstatus,
    "MSGUNREAD": msgunread,
    "MSGDELETED": msgdeleted,
    "HORONAME": horoname,
    "HORONATIVEIMAGE": horonativeimage,
    "UserName": userName,
  };
}
