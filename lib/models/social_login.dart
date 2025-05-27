class SocialLoginData {
  String? userid;
  String? username;
  String? useremail;
  String? useridd;
  String? usermobile;
  String? userphoto;
  String? useraccountno;
  String? ucountry;
  String? ucurrency;
  String? ucharge;
  String? userpdate;
  String? userpplang;
  double? userlasthoroid;
  String? password;
  String? tokenfacebook;
  String? tokengoogle;
  String? tokenyahoo;
  String? touchid;
  String? token;
  String? tcFlag;
  String? tccode;
  String? ipAddress;

  SocialLoginData({
    this.userid,
    this.username,
    this.useremail,
    this.useridd,
    this.usermobile,
    this.userphoto,
    this.useraccountno,
    this.ucountry,
    this.ucurrency,
    this.ucharge,
    this.userpdate,
    this.userpplang,
    this.userlasthoroid,
    this.password,
    this.tokenfacebook,
    this.tokengoogle,
    this.tokenyahoo,
    this.touchid,
    this.token,
    this.tcFlag,
    this.tccode,
    this.ipAddress
  });

  factory SocialLoginData.fromJson(Map<String, dynamic> json) {
    return SocialLoginData(
      userid: json["userid"]?.toString(),
      username: json["username"]?.toString(),
      useremail: json["useremail"]?.toString(),
      useridd: json["useridd"]?.toString(),
      usermobile: json["usermobile"]?.toString(),
      userphoto: json["userphoto"]?.toString(),
      useraccountno: json["useraccountno"]?.toString(),
      ucountry: json["ucountry"]?.toString(),
      ucurrency: json["ucurrency"]?.toString(),
      ucharge: json["ucharge"]?.toString(),
      userpdate: json["userpdate"]?.toString(),
      userpplang: json["userpplang"]?.toString(),
      userlasthoroid: _parseDouble(json["userlasthoroid"]),
      password: json["password"]?.toString(),
      tokenfacebook: json["tokenfacebook"]?.toString(),
      tokengoogle: json["tokengoogle"]?.toString(),
      tokenyahoo: json["tokenyahoo"]?.toString(),
      touchid: json["touchid"]?.toString(),
      token: json["token"]?.toString(),
      tcFlag: json["tcFlag"]?.toString(),
      tccode: json["tccode"]?.toString(),
      ipAddress: json["ipAddress"]?.toString()
    );
  }

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Optional: Add toJson method if you need to convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      "userid": userid,
      "username": username,
      "useremail": useremail,
      "useridd": useridd,
      "usermobile": usermobile,
      "userphoto": userphoto,
      "useraccountno": useraccountno,
      "ucountry": ucountry,
      "ucurrency": ucurrency,
      "ucharge": ucharge,
      "userpdate": userpdate,
      "userpplang": userpplang,
      "userlasthoroid": userlasthoroid,
      "password": password,
      "tokenfacebook": tokenfacebook,
      "tokengoogle": tokengoogle,
      "tokenyahoo": tokenyahoo,
      "touchid": touchid,
      "token": token,
      "tcFlag": tcFlag,
      "tccode": tccode,
      "ipAddress": ipAddress
    };
  }
}