import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/apiCalling_controllers.dart';
import 'package:planetcombo/controllers/social_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/models/social_login.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/profile/edit_profile.dart';

class WebLogin extends StatefulWidget {
  const WebLogin({super.key});

  @override
  State<WebLogin> createState() => _WebLoginState();
}

class _WebLoginState extends State<WebLogin> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final SocialLoginController socialLoginController =
  Get.put(SocialLoginController.getInstance(), permanent: true);

  final ApiCallingsController apiCallingsController =
  Get.put(ApiCallingsController.getInstance(), permanent: true);

  Constants constants = Constants();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '488939796804-7sg8h4gm8oda4qrqvca1cmd2eo91jq9r.apps.googleusercontent.com',
  );

  final List<DropdownItem> countries = [
    DropdownItem(title: "India", iconUrl: "assets/icon/india_flag.png"),
    DropdownItem(title: "UAE", iconUrl: "assets/svg/uae_flag.png"),
    DropdownItem(title: "REST", iconUrl: "assets/svg/world.png"),
  ];


  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(now);
    return formattedDate;
  }

  Future<void> _handleSignIn() async {
    try {
      showWebLoadingDialog(context, "Signing in with Google...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
        var response = await apiCallingsController.socialLogin(
          _auth.currentUser!.email,
          constants.mediumGmail,
          constants.password,
          _auth.currentUser!.providerData[0].uid,
          context,
        );
        dismissWebLoadingDialog(context);
        print('the response Profile from the User of google login ${_auth.currentUser!.photoURL!}');
        print('the response from the User of google login ${_auth.currentUser}');
        if (response == 'true') {
          await _handleSuccessfulLogin();
        } else if (response == 'false') {
          CustomDialog.showAlert(context, 'Something went wrong. Please try later', false, 16);
        } else if (response == 'No Data found') {
          await _handleNewUser();
        }
      } else {
        dismissWebLoadingDialog(context);
      }
    } catch (e) {
      dismissWebLoadingDialog(context);
      print("Error signing in: $e");
      CustomDialog.showAlert(context, 'An error occurred during sign-in. Please try again.', false, 16);
    }
  }

  Future<void> _handleSuccessfulLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('UserInfo');
    var jsonBody = json.decode(jsonString!);
    appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
    applicationBaseController.initializeApplication();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
  }

  Future<void> _handleNewUser() async {
    appLoadController.addNewUser.value = 'YES';
    appLoadController.loggedUserData.value.userid = _auth.currentUser!.email;
    appLoadController.loggedUserData.value.username = _auth.currentUser!.displayName;
    appLoadController.loggedUserData.value.useremail = _auth.currentUser!.email;
    appLoadController.loggedUserData.value.useridd = constants.idd;
    appLoadController.loggedUserData.value.usermobile = _auth.currentUser!.phoneNumber ?? '';
    appLoadController.loggedUserData.value.ucountry = constants.country;
    appLoadController.loggedUserData.value.ucurrency = constants.currency;
    appLoadController.loggedUserData.value.userpdate = getCurrentDateTime();
    appLoadController.loggedUserData.value.userpplang = constants.lang;
    appLoadController.loggedUserData.value.tokengoogle = _auth.currentUser!.providerData[0].uid;
    appLoadController.loggedUserData.value.touchid = constants.touchId;
    appLoadController.loggedUserData.value.userphoto = _auth.currentUser!.photoURL!;
    appLoadController.loggedUserData.value.password = constants.password;
    appLoadController.loggedUserData.value.tccode = constants.tccode;
    appLoadController.loggedUserData.value.tokenfacebook = '';
    appLoadController.loggedUserData.value.tokenyahoo = '';
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const ProfileEdit()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/logintn.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double maxWidth = 300;
                    double width = constraints.maxWidth < maxWidth
                        ? constraints.maxWidth
                        : maxWidth;
                    return Image.asset(
                      'assets/images/headletters.png',
                      width: width,
                    );
                  },
                ),
                const SizedBox(height: 5),
                // LayoutBuilder(
                //   builder: (BuildContext context, BoxConstraints constraints) {
                //     double maxWidth = 500;
                //     double width = constraints.maxWidth < maxWidth
                //         ? constraints.maxWidth
                //         : maxWidth;
                //     return SizedBox(
                //       width: width,
                //       child:
                //       CustomDropdownButton(placeholder: 'Please Choose Country', textColor: Colors.black, buttonColor: Colors.yellow, items: countries, onChanged: (v){}),
                //     );
                //   },
                // ),
                // const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double maxWidth = 500;
                    double width = constraints.maxWidth < maxWidth
                        ? constraints.maxWidth
                        : maxWidth;
                    return SizedBox(
                      width: width,
                      child: fullLeftIconColorButton(
                        title: 'Continue with Google',
                        iconLeftSize: 25,
                        textColor: Colors.black,
                        buttonColor: Colors.white,
                        context: context,
                        onPressed: _handleSignIn,
                        iconUrl: 'assets/svg/google.svg',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double maxWidth = 500;
                    double width = constraints.maxWidth < maxWidth
                        ? constraints.maxWidth
                        : maxWidth;
                    return SizedBox(
                      width: width,
                      child: fullLeftIconColorButton(
                        title: 'Login with Facebook',
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        buttonColor: appLoadController.facebookBlue,
                        context: context,
                        onPressed: () {
                          SocialLoginController.loginWithFacebook(context);
                          // Facebook login logic here
                        },
                        iconUrl: 'assets/svg/facebook-logo.svg',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}