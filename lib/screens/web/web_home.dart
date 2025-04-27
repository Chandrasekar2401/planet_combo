import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'dart:convert';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/theme_widgets.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/apiCalling_controllers.dart';
import 'package:planetcombo/controllers/social_login.dart';
import 'package:planetcombo/models/social_login.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/profile/edit_profile.dart';
import 'package:planetcombo/screens/web/webLogin.dart';
import 'package:planetcombo/screens/web/web_article.dart';
import 'package:planetcombo/screens/web/web_aboutus.dart';
import 'package:planetcombo/screens/web/web_contactUS.dart';

class WebHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<WebHomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  // Controllers
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);
  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);
  final SocialLoginController socialLoginController =
  Get.put(SocialLoginController.getInstance(), permanent: true);
  final ApiCallingsController apiCallingsController =
  Get.put(ApiCallingsController.getInstance(), permanent: true);

  // Constants and services
  final Constants constants = Constants();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '488939796804-7sg8h4gm8oda4qrqvca1cmd2eo91jq9r.apps.googleusercontent.com',
  );

  final List<String> imgList = [
    'assets/images/web/bg1.jpg',
    'assets/images/web/1.jpg',
    'assets/images/web/2.jpg',
  ];

  late AnimationController _controller;
  late Animation<double> _animation;

  int _selectedIndex = 0;

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close the drawer after selecting an item
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 2.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(now);
    return formattedDate;
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      showWebLoadingDialog(context, "Signing in...");
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()));
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

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      // case 1:
      //   return appLoadController.userValue.value == true ? Dashboard() : const WebLogin();
      case 1:
        return buildWebArticle();
      case 2:
        return buildWebAboutUs();
      case 3:
        return buildWebContactUs();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: imgList.length,
          itemBuilder: (context, index, realIndex) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double scale = _animation.value;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imgList[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1.0,
            autoPlay: true,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                      // Negative margin to pull text closer to the image
                      Transform.translate(
                        offset: Offset(0, -40),
                        child: Stack(children: [
                          commonBoldText(text: 'PLANET COMBO', color: Colors.white, fontSize: 62),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2.0,
                              color: Colors.white,
                            ),
                          ),
                        ],),
                      ),
                    ],
                  ),
                  commonBoldText(text: 'Astrology Redefined - Precise and Powerful Prediction', fontSize: 32, color: Colors.white),
                  SizedBox(height: 20),
                  commonBoldText(text: '(CHANDRASEKAR PATHATHI - CP ASTROLOGY)', fontSize: 18, color: Colors.white),
                  SizedBox(height: 25),
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double maxWidth = 500;
                      double width = constraints.maxWidth < maxWidth
                          ? constraints.maxWidth
                          : maxWidth;
                      return SizedBox(
                        width: width,
                        child: fullLeftIconColorButton(
                          title: 'Login Using Google Account',
                          iconLeftSize: 25,
                          textColor: Colors.black,
                          buttonColor: Colors.white,
                          context: context,
                          onPressed: _handleGoogleSignIn,
                          iconUrl: 'assets/svg/google.svg',
                        ),
                      );
                    },
                  ),
                  // commonColorButton(
                  //     textPadding: 18,
                  //     fontSize: 22,
                  //     title: '     Google Login     ',
                  //     textColor: Colors.white,
                  //     buttonColor: Colors.deepOrange,
                  //     onPressed: _handleGoogleSignIn), // Direct Google Sign In function
                ],
              )
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        onItemTap: _handleItemTap,
        selectedIndex: _selectedIndex,
      ),
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }
}