// To parse this JSON data, do
//
//     final socialLoginData = socialLoginDataFromJson(jsonString);

class SocialLoginData{
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
  });

  factory SocialLoginData.fromJson(json) {
    final userid= json["USERID"].toString();
    final username= json["USERNAME"].toString();
    final useremail= json["USEREMAIL"].toString();
    final useridd= json["USERIDD"].toString();
    final usermobile= json["USERMOBILE"].toString();
    final userphoto= json["USERPHOTO"].toString();
    final useraccountno= json["USERACCOUNTNO"].toString();
    final ucountry= json["UCOUNTRY"].toString();
    final ucurrency= json["UCURRENCY"].toString();
    final ucharge= json["UCHARGE"].toString();
    final userpdate= json["USERPDATE"].toString();
    final userpplang= json["USERPPLANG"].toString();
    final userlasthoroid= json["USERLASTHOROID"];
    final password= json["PASSWORD"].toString();
    final tokenfacebook= json["TOKENFACEBOOK"].toString();
    final tokengoogle= json["TOKENGOOGLE"].toString();
    final tokenyahoo= json["TOKENYAHOO"].toString();
    final touchid= json["TOUCHID"].toString();
    final token= json["TOKEN"].toString();
    final tcFlag= json["TCFlag"].toString();
    final tccode= json["TCCODE"].toString();
    return SocialLoginData(
        userid: userid,
        username:username,
        useremail:useremail,
        useridd:useridd,
        usermobile:usermobile,
        userphoto:userphoto,
        useraccountno:useraccountno,
        ucountry:ucountry,
        ucurrency:ucurrency,
        ucharge:ucharge,
        userpdate:userpdate,
        userpplang:userpplang,
        userlasthoroid:userlasthoroid,
        password:password,
        tokenfacebook:tokenfacebook,
        tokengoogle:tokengoogle,
        tokenyahoo:tokenyahoo,
        touchid:touchid,
        token:token,
        tcFlag:tcFlag,
        tccode: tccode,
    );
  }
}
