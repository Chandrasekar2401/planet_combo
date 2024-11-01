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

  factory MessagesList.fromJson(Map<String, dynamic> json) {
    final lowercaseJson = json.map((key, value) => MapEntry(key.toLowerCase(), value));
    return MessagesList(
      status: lowercaseJson["status"],
      message: lowercaseJson["message"],
      data: lowercaseJson["data"] != null
          ? List<MessageHistory>.from(lowercaseJson["data"].map((x) => MessageHistory.fromJson(x)))
          : null,
      errorMessage: lowercaseJson["errormessage"],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.map((x) => x.toJson()).toList(),
    "errorMessage": errorMessage,
  };
}

class MessageHistory {
  String? msguserid;
  dynamic? msghid;
  String? msgmessageid;
  String? msgcustomercom;
  String? msgagentcom;
  String? msghcomments;
  String? msgstatus;
  String? msgunread;
  String? msgdeleted;
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

  factory MessageHistory.fromJson(Map<String, dynamic> json) {
    final lowercaseJson = json.map((key, value) => MapEntry(key.toLowerCase(), value));
    return MessageHistory(
      msguserid: lowercaseJson["msguserid"],
      msghid: lowercaseJson["msghid"],
      msgmessageid: lowercaseJson["msgmessageid"],
      msgcustomercom: lowercaseJson["msgcustomercom"],
      msgagentcom: lowercaseJson["msgagentcom"],
      msghcomments: lowercaseJson["msghcomments"],
      msgstatus: lowercaseJson["msgstatus"],
      msgunread: lowercaseJson["msgunread"],
      msgdeleted: lowercaseJson["msgdeleted"],
      horoname: lowercaseJson["horoname"],
      horonativeimage: lowercaseJson["horonativeimage"],
      userName: lowercaseJson["username"],
    );
  }

  Map<String, dynamic> toJson() => {
    "msguserid": msguserid,
    "msghid": msghid,
    "msgmessageid": msgmessageid,
    "msgcustomercom": msgcustomercom,
    "msgagentcom": msgagentcom,
    "msghcomments": msghcomments,
    "msgstatus": msgstatus,
    "msgunread": msgunread,
    "msgdeleted": msgdeleted,
    "horoname": horoname,
    "horonativeimage": horonativeimage,
    "username": userName,
  };
}