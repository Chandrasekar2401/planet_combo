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
    final userid= json["userid"].toString();
    final username= json["username"].toString();
    final useremail= json["useremail"].toString();
    final useridd= json["useridd"].toString();
    final usermobile= json["usermobile"].toString();
    final userphoto= json["userphoto"].toString();
    final useraccountno= json["useraccountno"].toString();
    final ucountry= json["ucountry"].toString();
    final ucurrency= json["ucurrency"].toString();
    final ucharge= json["ucharge"].toString();
    final userpdate= json["userpdate"].toString();
    final userpplang= json["userpplang"].toString();
    final userlasthoroid= json["userlasthoroid"];
    final password= json["password"].toString();
    final tokenfacebook= json["tokenfacebook"].toString();
    final tokengoogle= json["tokengoogle"].toString();
    final tokenyahoo= json["tokenyahoo"].toString();
    final touchid= json["touchid"].toString();
    final token= json["token"].toString();
    final tcFlag= json["tcFlag"].toString();
    final tccode= json["tccode"].toString();
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
