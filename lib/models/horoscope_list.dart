import 'dart:convert';

List<HoroscopesList> horoscopesListFromJson(String str) => List<HoroscopesList>.from(json.decode(str)['Data'].map((x) => HoroscopesList.fromJson(x)));

String horoscopesListToJson(List<HoroscopesList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HoroscopesList {
  HoroscopesList({
    this.huserid,
    this.hid,
    this.hname,
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
});
  String? huserid;
  String? hid;
  String? hname;
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

  factory HoroscopesList.fromJson(Map<String, dynamic> json) => HoroscopesList(
    huserid: json["HUSERID"],
    hid: json["HID"],
    hname: json["HNAME"],
    hnativephoto: json["HNATIVEPHOTO"],
    hhoroscopephoto: json["HHOROSCOPEPHOTO"],
    hgender: json["HGENDER"],
    hdobnative: json["HDOBNATIVE"],
    hhours: json["HHOURS"],
    hmin: json["HMIN"],
    hss: json["HSS"],
    hampm: json["HAMPM"],
    hplace: json["HPLACE"],
    hlandmark: json["HLANDMARK"],
    hmarriagedate: json["HMARRIAGEDATE"],
    hmarriageplace: json["HMARRIAGEPLACE"],
    hmarriagetime: json["HMARRIAGETIME"],
    hmarriageampm: json["HMARRIAGEAMPM"],
    hfirstchilddate: json["HFIRSTCHILDDATE"],
    hfirstchildplace: json["HFIRSTCHILDPLACE"],
    hfirstchildtime: json["HFIRSTCHILDTIME"],
    hfirstchildtimeampm: json["HFIRSTCHILDTIMEAMPM"],
    hatdate: json["HATDATE"],
    hatplace: json["HATPLACE"],
    hattime: json["HATTIME"],
    hattampm: json["HATTAMPM"],
    haflightno: json["HAFLIGHTNO"],
    hcrdate: json["HCRDATE"],
    hcrtime: json["HCRTIME"],
    hcrplace: json["HCRPLACE"],
    hcrtampm: json["HCRTAMPM"],
    hdrr: json["HDRR"],
    hdrrd: json["HDRRD"],
    hdrrp: json["HDRRP"],
    hdrrt: json["HDRRT"],
    hdrrtampm: json["HDRRTAMPM"],
    rectifieddate: json["RECTIFIEDDATE"],
    rectifiedtime: json["RECTIFIEDTIME"],
    rectifieddst: json["RECTIFIEDDST"],
    rectifiedplace: json["RECTIFIEDPLACE"],
    rectifiedlongtitude: json["RECTIFIEDLONGTITUDE"],
    rectifiedlongtitudeew: json["RECTIFIEDLONGTITUDEEW"],
    rectifiedlatitude: json["RECTIFIEDLATITUDE"],
    rectifiedlatitudens: json["RECTIFIEDLATITUDENS"],
    hpdf: json["HPDF"],
    lastrequestid: json["LASTREQUESTID"],
    lastmessageid: json["LASTMESSAGEID"],
    lastwpdate: json["LASTWPDATE"],
    lastdpdate: json["LASTDPDATE"],
    hlocked: json["HLOCKED"],
    hstatus: json["HSTATUS"],
    hrecdeleted: json["HRECDELETED"],
    hcreationdate: json["HCREATIONDATE"],
    hrecdeletedd: json["HRECDELETEDD"],
    htotaltrue: json["HTOTALTRUE"],
    htotalfalse: json["HTOTALFALSE"],
    htotalpartial: json["HTOTALPARTIAL"],
    hunique: json["HUNIQUE"],
    repeatrequest: json["REPEATREQUEST"],
    hbirthorder: json["HBIRTHORDER"],
    nativeDateString: json["NativeDateString"],
    hmarriagedateString: json["HMARRIAGEDATEString"],
    hfirstchilddateString: json["HFIRSTCHILDDATEString"],
    hatdateString: json["HATDATEString"],
    hcrdateString: json["HCRDATEString"],
    hdrrdString: json["HDRRDString"],
    userName: json["UserName"],
    timezone: json["TIMEZONE"],
    recttifiedTImeString: json["RecttifiedTImeString"],
    senderEmail: json["senderEmail"],
  );

  Map<String, dynamic> toJson() => {
    "HUSERID": huserid,
    "HID": hid,
    "HNAME": hname,
    "HNATIVEPHOTO": hnativephoto,
    "HHOROSCOPEPHOTO": hhoroscopephoto,
    "HGENDER": hgender,
    "HDOBNATIVE": hdobnative,
    "HHOURS": hhours,
    "HMIN": hmin,
    "HSS": hss,
    "HAMPM": hampm,
    "HPLACE": hplace,
    "HLANDMARK": hlandmark,
    "HMARRIAGEDATE": hmarriagedate,
    "HMARRIAGEPLACE": hmarriageplace,
    "HMARRIAGETIME": hmarriagetime,
    "HMARRIAGEAMPM": hmarriageampm,
    "HFIRSTCHILDDATE": hfirstchilddate,
    "HFIRSTCHILDPLACE": hfirstchildplace,
    "HFIRSTCHILDTIME": hfirstchildtime,
    "HFIRSTCHILDTIMEAMPM": hfirstchildtimeampm,
    "HATDATE": hatdate,
    "HATPLACE": hatplace,
    "HATTIME": hattime,
    "HATTAMPM": hattampm,
    "HAFLIGHTNO": haflightno,
    "HCRDATE": hcrdate,
    "HCRTIME": hcrtime,
    "HCRPLACE": hcrplace,
    "HCRTAMPM": hcrtampm,
    "HDRR": hdrr,
    "HDRRD": hdrrd,
    "HDRRP": hdrrp,
    "HDRRT": hdrrt,
    "HDRRTAMPM": hdrrtampm,
    "RECTIFIEDDATE": rectifieddate,
    "RECTIFIEDTIME": rectifiedtime,
    "RECTIFIEDDST": rectifieddst,
    "RECTIFIEDPLACE": rectifiedplace,
    "RECTIFIEDLONGTITUDE": rectifiedlongtitude,
    "RECTIFIEDLONGTITUDEEW": rectifiedlongtitudeew,
    "RECTIFIEDLATITUDE": rectifiedlatitude,
    "RECTIFIEDLATITUDENS": rectifiedlatitudens,
    "HPDF": hpdf,
    "LASTREQUESTID": lastrequestid,
    "LASTMESSAGEID": lastmessageid,
    "LASTWPDATE": lastwpdate,
    "LASTDPDATE": lastdpdate,
    "HLOCKED": hlocked,
    "HSTATUS": hstatus,
    "HRECDELETED": hrecdeleted,
    "HCREATIONDATE": hcreationdate,
    "HRECDELETEDD": hrecdeletedd,
    "HTOTALTRUE": htotaltrue,
    "HTOTALFALSE": htotalfalse,
    "HTOTALPARTIAL": htotalpartial,
    "HUNIQUE": hunique,
    "REPEATREQUEST": repeatrequest,
    "HBIRTHORDER": hbirthorder,
    "NativeDateString": nativeDateString,
    "HMARRIAGEDATEString": hmarriagedateString,
    "HFIRSTCHILDDATEString": hfirstchilddateString,
    "HATDATEString": hatdateString,
    "HCRDATEString": hcrdateString,
    "HDRRDString": hdrrdString,
    "UserName": userName,
    "TIMEZONE": timezone,
    "RecttifiedTImeString": recttifiedTImeString,
    "senderEmail": senderEmail,
  };
}
