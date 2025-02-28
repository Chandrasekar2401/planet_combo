import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Import your local files
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/controllers/apiCalling_controllers.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/social_login.dart';
import 'package:planetcombo/models/social_login.dart';
import 'package:planetcombo/screens/authentication.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/profile/edit_profile.dart';
import 'package:planetcombo/service/local_notification.dart';

class SocialLogin extends StatefulWidget {
  const SocialLogin({Key? key}) : super(key: key);

  @override
  _SocialLoginState createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  // Static constants for better performance
  static const backgroundImage = DecorationImage(
    image: AssetImage('assets/images/logintn.jpg'),
    fit: BoxFit.cover,
  );

  static const boxDecoration = BoxDecoration(
    image: backgroundImage,
  );

  // Lazy loaded controllers
  late final AppLoadController appLoadController;
  late final ApplicationBaseController applicationBaseController;
  late final SocialLoginController socialLoginController;
  late final ApiCallingsController apiCallingsController;

  // Constants and services
  final Constants constants = Constants();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeNotifications();
  }

  void _initializeControllers() {
    appLoadController = Get.put(AppLoadController.getInstance(), permanent: true);
    applicationBaseController = Get.put(ApplicationBaseController.getInstance(), permanent: true);
    socialLoginController = Get.put(SocialLoginController.getInstance(), permanent: true);
    apiCallingsController = Get.put(ApiCallingsController.getInstance(), permanent: true);
  }

  void _initializeNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.initialize(flutterLocalNotificationsPlugin);
    });
  }

  String _getCurrentDateTime() => DateFormat('ddMMyyHHmmss').format(DateTime.now());

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');
      final UserCredential? userCredential = await _signInWithGoogle();

      if (userCredential?.user == null) {
        CustomDialog.cancelLoading(context);
        CustomDialog.showAlert(context, 'Sign in failed', false, 16);
        return;
      }

      final response = await apiCallingsController.socialLogin(
          userCredential!.user!.email!,
          constants.mediumGmail,
          constants.password,
          userCredential.user!.providerData[0].uid,
          context
      );

      await _handleSocialLoginResponse(context, response, userCredential);
    } catch (e) {
      CustomDialog.cancelLoading(context);
      CustomDialog.showAlert(context, 'Something went wrong', false, 16);
    }
  }

  Future<void> _handleSocialLoginResponse(BuildContext context, String response, UserCredential userCredential) async {
    CustomDialog.cancelLoading(context);

    switch (response) {
      case 'true':
        await _handleSuccessfulLogin(context);
        break;
      case 'false':
        CustomDialog.showAlert(context, 'Something went wrong. Please try later', false, 16);
        break;
      case 'No Data found':
        await _handleNewUser(userCredential);
        break;
    }
  }

  Future<void> _handleSuccessfulLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('UserInfo');
    var jsonBody = json.decode(jsonString!);

    appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
    applicationBaseController.initializeApplication();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => appLoadController.loggedUserData.value.touchid == 'F'
                ? Dashboard()
                : const Authentication()
        )
    );
  }

  Future<void> _handleNewUser(UserCredential userCredential) async {
    appLoadController.addNewUser.value = 'YES';
    appLoadController.loggedUserData.value
      ..userid = userCredential.user!.email
      ..username = userCredential.user!.displayName
      ..useremail = userCredential.user!.email
      ..useridd = constants.idd
      ..usermobile = userCredential.user!.phoneNumber ?? ''
      ..ucountry = constants.country
      ..ucurrency = constants.currency
      ..userpdate = _getCurrentDateTime()
      ..userpplang = constants.lang
      ..tokengoogle = userCredential.user!.providerData[0].uid
      ..touchid = constants.touchId
      ..userphoto = userCredential.user!.photoURL!
      ..password = constants.password
      ..tccode = constants.tccode;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileEdit())
    );
  }

  Widget _buildLogo(BuildContext context, BoxConstraints constraints) {
    double maxWidth = 300;
    double width = constraints.maxWidth < maxWidth
        ? constraints.maxWidth
        : maxWidth;
    return Image.asset(
      'assets/images/headletters.png',
      width: width,
      cacheWidth: 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LayoutBuilder(builder: _buildLogo),
                    const SizedBox(height: 30),
                    fullLeftIconColorButton(
                        title: 'Login Using Google Account',
                        textColor: Colors.black,
                        buttonColor: Colors.white,
                        context: context,
                        onPressed: () => _handleGoogleSignIn(context),
                        iconUrl: 'assets/svg/google.svg'
                    ),
                    const SizedBox(height: 30),
                    fullLeftIconColorButton(
                        title: 'Login with facebook',
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        buttonColor: appLoadController.facebookBlue,
                        context: context,
                        onPressed: () => SocialLoginController.loginWithFacebook(context),
                        iconUrl: 'assets/svg/facebook-logo.svg'
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
