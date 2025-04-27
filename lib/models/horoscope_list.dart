import 'dart:convert';

List<HoroscopesList> horoscopesListFromJson(String str) => List<HoroscopesList>.from(json.decode(str)['data'].map((x) => HoroscopesList.fromJson(x)));

String horoscopesListToJson(List<HoroscopesList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HoroscopesList {
  HoroscopesList({
    this.huserid,
    this.hid,
    this.hname,
    this.isPaid,
    this.hnativephoto,
    this.hhoroscopephoto,
    this.hgender,
    this.hdobnative,
    this.hhours,
    this.hmin,
    this.hss,
    this.hampm,
    this.hplace,
    this.hlandmark,
    this.hmarriagedate,
    this.hmarriageplace,
    this.hmarriagetime,
    this.hmarriageampm,
    this.hfirstchilddate,
    this.hfirstchildplace,
    this.hfirstchildtime,
    this.hfirstchildtimeampm,
    this.hatdate,
    this.hatplace,
    this.hattime,
    this.hattampm,
    this.haflightno,
    this.hcrdate,
    this.hcrtime,
    this.hcrplace,
    this.hcrtampm,
    this.hdrr,
    this.hdrrd,
    this.hdrrp,
    this.hdrrt,
    this.hdrrtampm,
    this.rectifieddate,
    this.rectifiedtime,
    this.rectifieddst,
    this.rectifiedplace,
    this.rectifiedlongtitude,
    this.rectifiedlongtitudeew,
    this.rectifiedlatitude,
    this.rectifiedlatitudens,
    this.hpdf,
    this.lastrequestid,
    this.lastmessageid,
    this.lastwpdate,
    this.lastdpdate,
    this.hlocked,
    this.hstatus,
    this.hrecdeleted,
    this.hcreationdate,
    this.hrecdeletedd,
    this.htotaltrue,
    this.htotalfalse,
    this.htotalpartial,
    this.hunique,
    this.repeatrequest,
    this.hbirthorder,
    this.nativeDateString,
    this.hmarriagedateString,
    this.hfirstchilddateString,
    this.hatdateString,
    this.hcrdateString,
    this.hdrrdString,
    this.userName,
    this.timezone,
    this.recttifiedTImeString,
    this.senderEmail,
    this.requestId,
    this.amount
});
  String? huserid;
  String? hid;
  String? hname;
  String? isPaid;
  String? hnativephoto;
  String? hhoroscopephoto;
  String? hgender;
  String? hdobnative;
  double? hhours;
  double? hmin;
  double? hss;
  String? hampm;
  String? hplace;
  String? hlandmark;
  String? hmarriagedate;
  String? hmarriageplace;
  String? hmarriagetime;
  String? hmarriageampm;
  String? hfirstchilddate;
  String? hfirstchildplace;
  String? hfirstchildtime;
  String? hfirstchildtimeampm;
  String? hatdate;
  String? hatplace;
  String? hattime;
  String? hattampm;
  String? haflightno;
  String? hcrdate;
  String? hcrtime;
  String? hcrplace;
  String? hcrtampm;
  String? hdrr;
  String? hdrrd;
  String? hdrrp;
  String? hdrrt;
  String? hdrrtampm;
  String? rectifieddate;
  String? rectifiedtime;
  double? rectifieddst;
  String? rectifiedplace;
  String? rectifiedlongtitude;
  String? rectifiedlongtitudeew;
  String? rectifiedlatitude;
  String? rectifiedlatitudens;
  String? hpdf;
  double? lastrequestid;
  double? lastmessageid;
  String? lastwpdate;
  String? lastdpdate;
  String? hlocked;
  String? hstatus;
  String? hrecdeleted;
  String? hcreationdate;
  String? hrecdeletedd;
  double? htotaltrue;
  double? htotalfalse;
  double? htotalpartial;
  double? hunique;
  String? repeatrequest;
  String? hbirthorder;
  String? nativeDateString;
  String? hmarriagedateString;
  String? hfirstchilddateString;
  String? hatdateString;
  String? hcrdateString;
  String? hdrrdString;
  String? userName;
  String? timezone;
  String? recttifiedTImeString;
  String? senderEmail;
  int? requestId;
  double? amount;
  factory HoroscopesList.fromJson(Map<String, dynamic> json) => HoroscopesList(
    huserid: _parseString(json["huserid"] ?? json["HUSERID"]),
    hid: _parseString(json["hid"] ?? json["HID"]),
    hname: _parseString(json["hname"] ?? json["HNAME"]),
    isPaid: _parseString(json["isPaid"]),
    hnativephoto: _parseString(json["hnativephoto"] ?? json["HNATIVEPHOTO"]),
    hhoroscopephoto: _parseString(json["hhoroscopephoto"] ?? json["HHOROSCOPEPHOTO"]),
    hgender: _parseString(json["hgender"] ?? json["HGENDER"]),
    hdobnative: _parseString(json["hdobnative"] ?? json["HDOBNATIVE"]),
    hhours: _parseDouble(json["hhours"] ?? json["HHOURS"]),
    hmin: _parseDouble(json["hmin"] ?? json["HMIN"]),
    hss: _parseDouble(json["hss"] ?? json["HSS"]),
    hampm: _parseString(json["hampm"] ?? json["HAMPM"]),
    hplace: _parseString(json["hplace"] ?? json["HPLACE"]),
    hlandmark: _parseString(json["hlandmark"] ?? json["HLANDMARK"]),
    hmarriagedate: _parseString(json["hmarriagedate"] ?? json["HMARRIAGEDATE"]),
    hmarriageplace: _parseString(json["hmarriageplace"] ?? json["HMARRIAGEPLACE"]),
    hmarriagetime: _parseString(json["hmarriagetime"] ?? json["HMARRIAGETIME"]),
    hmarriageampm: _parseString(json["hmarriageampm"] ?? json["HMARRIAGEAMPM"]),
    hfirstchilddate: _parseString(json["hfirstchilddate"] ?? json["HFIRSTCHILDDATE"]),
    hfirstchildplace: _parseString(json["hfirstchildplace"] ?? json["HFIRSTCHILDPLACE"]),
    hfirstchildtime: _parseString(json["hfirstchildtime"] ?? json["HFIRSTCHILDTIME"]),
    hfirstchildtimeampm: _parseString(json["hfirstchildtimeampm"] ?? json["HFIRSTCHILDTIMEAMPM"]),
    hatdate: _parseString(json["hatdate"] ?? json["HATDATE"]),
    hatplace: _parseString(json["hatplace"] ?? json["HATPLACE"]),
    hattime: _parseString(json["hattime"] ?? json["HATTIME"]),
    hattampm: _parseString(json["hattampm"] ?? json["HATTAMPM"]),
    haflightno: _parseString(json["haflightno"] ?? json["HAFLIGHTNO"]),
    hcrdate: _parseString(json["hcrdate"] ?? json["HCRDATE"]),
    hcrtime: _parseString(json["hcrtime"] ?? json["HCRTIME"]),
    hcrplace: _parseString(json["hcrplace"] ?? json["HCRPLACE"]),
    hcrtampm: _parseString(json["hcrtampm"] ?? json["HCRTAMPM"]),
    hdrr: _parseString(json["hdrr"] ?? json["HDRR"]),
    hdrrd: _parseString(json["hdrrd"] ?? json["HDRRD"]),
    hdrrp: _parseString(json["hdrrp"] ?? json["HDRRP"]),
    hdrrt: _parseString(json["hdrrt"] ?? json["HDRRT"]),
    hdrrtampm: _parseString(json["hdrrtampm"] ?? json["HDRRTAMPM"]),
    rectifieddate: _parseString(json["rectifieddate"] ?? json["RECTIFIEDDATE"]),
    rectifiedtime: _parseString(json["rectifiedtime"] ?? json["RECTIFIEDTIME"]),
    rectifieddst: _parseDouble(json["rectifieddst"] ?? json["RECTIFIEDDST"]),
    rectifiedplace: _parseString(json["rectifiedplace"] ?? json["RECTIFIEDPLACE"]),
    rectifiedlongtitude: _parseString(json["rectifiedlongtitude"] ?? json["RECTIFIEDLONGTITUDE"]),
    rectifiedlongtitudeew: _parseString(json["rectifiedlongtitudeew"] ?? json["RECTIFIEDLONGTITUDEEW"]),
    rectifiedlatitude: _parseString(json["rectifiedlatitude"] ?? json["RECTIFIEDLATITUDE"]),
    rectifiedlatitudens: _parseString(json["rectifiedlatitudens"] ?? json["RECTIFIEDLATITUDENS"]),
    hpdf: _parseString(json["hpdf"] ?? json["HPDF"]),
    lastrequestid: _parseDouble(json["lastrequestid"] ?? json["LASTREQUESTID"]),
    lastmessageid: _parseDouble(json["lastmessageid"] ?? json["LASTMESSAGEID"]),
    lastwpdate: _parseString(json["lastwpdate"] ?? json["LASTWPDATE"]),
    lastdpdate: _parseString(json["lastdpdate"] ?? json["LASTDPDATE"]),
    hlocked: _parseString(json["hlocked"] ?? json["HLOCKED"]),
    hstatus: _parseString(json["hstatus"] ?? json["HSTATUS"]),
    hrecdeleted: _parseString(json["hrecdeleted"] ?? json["HRECDELETED"]),
    hcreationdate: _parseString(json["hcreationdate"] ?? json["HCREATIONDATE"]),
    hrecdeletedd: _parseString(json["hrecdeletedd"] ?? json["HRECDELETEDD"]),
    htotaltrue: _parseDouble(json["htotaltrue"] ?? json["HTOTALTRUE"]),
    htotalfalse: _parseDouble(json["htotalfalse"] ?? json["HTOTALFALSE"]),
    htotalpartial: _parseDouble(json["htotalpartial"] ?? json["HTOTALPARTIAL"]),
    hunique: _parseDouble(json["hunique"] ?? json["HUNIQUE"]),
    repeatrequest: _parseString(json["repeatrequest"] ?? json["REPEATREQUEST"]),
    hbirthorder: _parseString(json["hbirthorder"] ?? json["HBIRTHORDER"]),
    nativeDateString: _parseString(json["nativedatestring"] ?? json["NativeDateString"]),
    hmarriagedateString: _parseString(json["hmarriagedatestring"] ?? json["HMARRIAGEDATEString"]),
    hfirstchilddateString: _parseString(json["hfirstchilddatestring"] ?? json["HFIRSTCHILDDATEString"]),
    hatdateString: _parseString(json["hatdatestring"] ?? json["HATDATEString"]),
    hcrdateString: _parseString(json["hcrdatestring"] ?? json["HCRDATEString"]),
    hdrrdString: _parseString(json["hdrrdstring"] ?? json["HDRRDString"]),
    userName: _parseString(json["username"] ?? json["UserName"]),
    timezone: _parseString(json["timezone"] ?? json["TIMEZONE"]),
    recttifiedTImeString: _parseString(json["recttifiedtimestring"] ?? json["RecttifiedTImeString"]),
    senderEmail: _parseString(json["senderemail"] ?? json["senderEmail"]),
    requestId: json["requestId"] ?? 0,
    amount: json["amount"] ?? 0,
  );

  // Helper methods to parse different types to String or double
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


  Map<String, dynamic> toJson() => {
    "huserid": huserid,
    "hid": hid,
    "hname": hname,
    "isPaid" : isPaid,
    "hnativephoto": hnativephoto,
    "hhoroscopephoto": hhoroscopephoto,
    "hgender": hgender,
    "hdobnative": hdobnative,
    "hhours": hhours,
    "hmin": hmin,
    "hss": hss,
    "hampm": hampm,
    "hplace": hplace,
    "hlandmark": hlandmark,
    "hmarriagedate": hmarriagedate,
    "hmarriageplace": hmarriageplace,
    "hmarriagetime": hmarriagetime,
    "hmarriageampm": hmarriageampm,
    "hfirstchilddate": hfirstchilddate,
    "hfirstchildplace": hfirstchildplace,
    "hfirstchildtime": hfirstchildtime,
    "hfirstchildtimeampm": hfirstchildtimeampm,
    "hatdate": hatdate,
    "hatplace": hatplace,
    "hattime": hattime,
    "hattampm": hattampm,
    "haflightno": haflightno,
    "hcrdate": hcrdate,
    "hcrtime": hcrtime,
    "hcrplace": hcrplace,
    "hcrtampm": hcrtampm,
    "hdrr": hdrr,
    "hdrrd": hdrrd,
    "hdrrp": hdrrp,
    "hdrrt": hdrrt,
    "hdrrtampm": hdrrtampm,
    "rectifieddate": rectifieddate,
    "rectifiedtime": rectifiedtime,
    "rectifieddst": rectifieddst,
    "rectifiedplace": rectifiedplace,
    "rectifiedlongtitude": rectifiedlongtitude,
    "rectifiedlongtitudeew": rectifiedlongtitudeew,
    "rectifiedlatitude": rectifiedlatitude,
    "rectifiedlatitudens": rectifiedlatitudens,
    "hpdf": hpdf,
    "lastrequestid": lastrequestid,
    "lastmessageid": lastmessageid,
    "lastwpdate": lastwpdate,
    "lastdpdate": lastdpdate,
    "hlocked": hlocked,
    "hstatus": hstatus,
    "hrecdeleted": hrecdeleted,
    "hcreationdate": hcreationdate,
    "hrecdeletedd": hrecdeletedd,
    "htotaltrue": htotaltrue,
    "htotalfalse": htotalfalse,
    "htotalpartial": htotalpartial,
    "hunique": hunique,
    "repeatrequest": repeatrequest,
    "hbirthorder": hbirthorder,
    "nativedatestring": nativeDateString,
    "hmarriagedatestring": hmarriagedateString,
    "hfirstchilddatestring": hfirstchilddateString,
    "hatdatestring": hatdateString,
    "hcrdatestring": hcrdateString,
    "hdrrdstring": hdrrdString,
    "username": userName,
    "timezone": timezone,
    "recttifiedtimestring": recttifiedTImeString,
    "senderemail": senderEmail,
    "requestId":requestId,
    "amount": amount
  };
}
