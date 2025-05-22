import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:planetcombo/screens/authentication.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/profile/edit_profile.dart';
import 'package:planetcombo/screens/web/webLogin.dart';
import 'package:planetcombo/screens/web/web_article.dart';
import 'package:planetcombo/screens/web/web_aboutus.dart';
import 'package:planetcombo/screens/web/web_contactUS.dart';
import 'package:planetcombo/service/local_notification.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late final GoogleSignIn _googleSignIn;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  final List<String> imgList = [
    'assets/images/web/bg1.jpg',
    'assets/images/web/1.jpg',
    'assets/images/web/2.jpg',
  ];

  final List<String> mobileImgList = [
    'assets/images/logintn.jpg',
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

    Navigator.of(context).pop(); // Close the drawer

    switch (index) {
      case 0: // Home/Dashboard (already on this page)
        break;
      case 1: // Articles
        Navigator.push(context, MaterialPageRoute(builder: (context) => buildWebArticle()));
        break;
      case 2: // About Us
        Navigator.push(context, MaterialPageRoute(builder: (context) => buildWebAboutUs()));
        break;
      case 3: // Contact
        Navigator.push(context, MaterialPageRoute(builder: (context) => buildWebContactUs()));
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize Google Sign In based on platform
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: '488939796804-7sg8h4gm8oda4qrqvca1cmd2eo91jq9r.apps.googleusercontent.com',
      );
    } else {
      _googleSignIn = GoogleSignIn();
      _initializeNotifications();
    }

    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 2.1).animate(_controller);
  }

  void _initializeNotifications() {
    if (!kIsWeb) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.initialize(flutterLocalNotificationsPlugin!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    return kIsWeb
        ? DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(now)
        : DateFormat('ddMMyyHHmmss').format(now);
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Show appropriate loading dialog based on platform
      if (kIsWeb) {
        showWebLoadingDialog(context, "Signing in...");
      } else {
        CustomDialog.showLoading(context, 'Please wait');
      }

      // Sign out first to avoid cached credentials
      await _googleSignIn.signOut();

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

        _dismissLoading();

        if (response == 'true') {
          await _handleSuccessfulLogin();
        } else if (response == 'false') {
          CustomDialog.showAlert(context, 'Something went wrong. Please try later', false, 16);
        } else if (response == 'No Data found') {
          await _handleNewUser();
        }
      } else {
        _dismissLoading();
      }
    } catch (e) {
      _dismissLoading();
      print("Error signing in: $e");
      CustomDialog.showAlert(context, 'An error occurred during sign-in. Please try again.', false, 16);
    }
  }

  void _dismissLoading() {
    if (kIsWeb) {
      dismissWebLoadingDialog(context);
    } else {
      CustomDialog.cancelLoading(context);
    }
  }

  Future<void> _handleSuccessfulLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('UserInfo');
    var jsonBody = json.decode(jsonString!);
    appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
    applicationBaseController.initializeApplication();

    if (kIsWeb || appLoadController.loggedUserData.value.touchid == 'F') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Authentication()));
    }
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

  Widget _buildHomeContent() {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600 || screenSize.height < 600;
    final List<String> currentImgList = kIsWeb ? imgList : mobileImgList;

    return Stack(
      children: [
        // Background Carousel
        CarouselSlider.builder(
          itemCount: currentImgList.length,
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
                        image: AssetImage(currentImgList[index]),
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

        // Content overlay
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title section
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
                        offset: const Offset(0, -40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Text with an auto-sized container
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: commonBoldText(
                                  text: 'PLANET COMBO',
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 42 : 62,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tagline
                  commonBoldText(
                    text: 'Astrology Redefined - Precise and Powerful Prediction',
                    fontSize: isSmallScreen ? 22 : 32,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isSmallScreen ? 15 : 20),

                  // Author text
                  commonBoldText(
                    text: '(CHANDRASEKAR PATHATHI - CP ASTROLOGY)',
                    fontSize: isSmallScreen ? 14 : 18,
                    color: Colors.white,
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 25),

                  // Login buttons
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double maxWidth = 500;
                      double width = constraints.maxWidth < maxWidth
                          ? constraints.maxWidth
                          : maxWidth;
                      return SizedBox(
                        width: width,
                        child: Column(
                          children: [
                            fullLeftIconColorButton(
                              title: 'Login Using Google Account',
                              iconLeftSize: isSmallScreen ? 20 : 25,
                              textColor: Colors.black,
                              buttonColor: Colors.white,
                              context: context,
                              onPressed: _handleGoogleSignIn,
                              iconUrl: 'assets/svg/google.svg',
                            ),
                            // Only show Facebook login on mobile
                            if (!kIsWeb) ...[
                              const SizedBox(height: 20),
                              // fullLeftIconColorButton(
                              //   title: 'Login with Facebook',
                              //   textColor: Colors.white,
                              //   iconColor: Colors.white,
                              //   buttonColor: appLoadController.facebookBlue,
                              //   context: context,
                              //   onPressed: () => SocialLoginController.loginWithFacebook(context),
                              //   iconUrl: 'assets/svg/facebook-logo.svg',
                              // ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = appLoadController.userValue.value;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        onItemTap: _handleItemTap,
        selectedIndex: _selectedIndex,
        isLoggedIn: isLoggedIn,
      ),
      body: Stack(
        children: [
          _buildHomeContent(),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Drawer Widget
class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTap;
  final int selectedIndex;
  final bool isLoggedIn;

  final Constants constant = Constants();

  CustomDrawer({super.key, required this.onItemTap, required this.selectedIndex, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                boxShadow: const [],
              ),
              child: Image.asset('assets/images/headletters.png'),
            ),
            _createDrawerItem(
              icon: Icons.home_outlined,
              text: isLoggedIn ? 'Dashboard' : 'Home',
              onTap: () => onItemTap(0),
              isSelected: selectedIndex == 0,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/article.svg',
              text: 'Articles',
              onTap: () => onItemTap(1),
              isSelected: selectedIndex == 1,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/about1.svg',
              text: 'About us',
              onTap: () => onItemTap(2),
              isSelected: selectedIndex == 2,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/contact1.svg',
              text: 'Contact',
              onTap: () => onItemTap(3),
              isSelected: selectedIndex == 3,
            ),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.all(12),
                child: commonBoldText(text: '© 2024 Planet Combo - All Rights Reserved.', fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    String? svgIcon,
    IconData? icon,
    required String text,
    required GestureTapCallback onTap,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: ListTile(
        leading: svgIcon == null ? Icon(
          icon,
          size: 21,
          color: isSelected ? constant.appPrimaryColor : Colors.black,
        ) :
        SvgPicture.asset(
          svgIcon,
          colorFilter: ColorFilter.mode(
            isSelected ? constant.appPrimaryColor : Colors.black,
            BlendMode.srcIn,
          ),
          width: 21,
          height: 21,
        ),
        title: Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected ? constant.appPrimaryColor  : Colors.black,
          ),
        ),
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}