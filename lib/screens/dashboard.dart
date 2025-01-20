import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/screens/payments/payment_dashboard.dart';
import 'package:planetcombo/screens/policy.dart';
import 'package:planetcombo/screens/profile/profile.dart';
import 'package:planetcombo/screens/services/horoscope_services.dart';
import 'package:planetcombo/screens/social_login.dart';
import 'package:planetcombo/screens/web/web_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planetcombo/screens/live_chat.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:planetcombo/youtube_listing.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final LocalAuthentication auth = LocalAuthentication();
  final double width = 32;
  final double height = 32;
  final String defaultAvatarAsset = 'assets/imgs/profile_avatar.png';

  // Controllers
  final LocalizationController localizationController = Get.put(LocalizationController.getInstance(), permanent: true);
  final AppLoadController appLoadController = Get.put(AppLoadController.getInstance(), permanent: true);
  final AddHoroscopeController addHoroscopeController = Get.put(AddHoroscopeController.getInstance(), permanent: true);

  // Profile Image Builder with Error Handling
  Widget _buildNetworkImage(String imageUrl) {
    if (kIsWeb) {
      // For web platform
      return ClipOval(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(
                imageUrl,
                headers: {
                  'Access-Control-Allow-Origin': '*',
                  'Access-Control-Allow-Methods': 'GET',
                },
              ),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
                print('Error loading image: $error');
              },
            ),
          ),
          child: Image.network(
            imageUrl,
            width: width,
            height: width,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Web image error: $error');
              return Container(
                width: width,
                height: width,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 22),
              );
            },
          ),
        ),
      );
    } else {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 95,
          height: 95,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => Container(
            width: 95,
            height: 95,
            color: Colors.grey[300],
            child: const Icon(Icons.person, size: 40),
          ),
        ),
      );
    }
  }

  // Menu Item Builder
  Widget buildMenuItem({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
    bool showBorder = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 125,
        decoration: BoxDecoration(
          border: showBorder ? Border(
            bottom: BorderSide(
              color: appLoadController.appPrimaryColor,
              width: 0.3,
            ),
          ) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 52,
              height: 52,
              color: appLoadController.appPrimaryColor,
            ),
            const SizedBox(height: 12),
            commonBoldText(
              text: LocalizationController.getInstance().getTranslatedValue(text),
              fontSize: 13,
              color: appLoadController.appPrimaryColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Logout Dialog
  Future<void> showLogoutDialog() async {
    return yesOrNoDialog(
      context: context,
      dialogMessage: LocalizationController.getInstance().getTranslatedValue('Are you sure you want to logout?'),
      cancelText: LocalizationController.getInstance().getTranslatedValue('No'),
      okText: LocalizationController.getInstance().getTranslatedValue('Yes'),
      cancelAction: () => Navigator.pop(context),
      okAction: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        appLoadController.userValue.value = false;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => kIsWeb ? WebHomePage() : SocialLogin()),
              (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: GradientAppBar(
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile())),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipOval(child: _buildNetworkImage(appLoadController.loggedUserData.value.userphoto!)),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  const Icon(Icons.payment_outlined, color: Colors.white, size: 16),
                  commonBoldText(
                    text: ' - ${appLoadController.loggedUserData.value.ucurrency ?? ""}',
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
          ],
          title: LocalizationController.getInstance().getTranslatedValue("Hi !  ${appLoadController.loggedUserData.value.username}"),
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 500,
                child: Stack(
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade50,
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/images/Headletters_background.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            commonBoldText(
                              fontSize: 19,
                              color: Colors.white,
                              text: LocalizationController.getInstance().getTranslatedValue("Welcome to Planet Combo"),
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: commonText(
                                fontSize: 14,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                                text: LocalizationController.getInstance().getTranslatedValue(
                                  "Planetary calculation on charts, Dasas and transits powered by True Astrology software",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Menu Grid
                    Positioned.fill(
                      top: 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 21),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Left Column
                              Column(
                                children: [
                                  buildMenuItem(
                                    iconPath: 'assets/svg/horoscope.svg',
                                    text: "Horoscope Services",
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HoroscopeServices())),
                                  ),
                                  buildMenuItem(
                                    iconPath: 'assets/svg/Profile_Update.svg',
                                    text: "Profile",
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile())),
                                  ),
                                  buildMenuItem(
                                    iconPath: 'assets/svg/support.svg',
                                    text: "Chat Support",
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveChat())),
                                    showBorder: false,
                                  ),
                                ],
                              ),
                              // Divider
                              Container(
                                width: 0.5,
                                height: 360,
                                color: appLoadController.appPrimaryColor,
                              ),
                              // Right Column
                              Column(
                                children: [
                                  buildMenuItem(
                                    iconPath: 'assets/svg/payment.svg',
                                    text: "Payment",
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentDashboard())),
                                  ),
                                  buildMenuItem(
                                    iconPath: 'assets/svg/youtube.svg',
                                    text: "How to Use",
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const YouTubeVideosPage()));
                                    }
                                  ),
                                  buildMenuItem(
                                    iconPath: 'assets/svg/Terms-conditions.svg',
                                    text: "Terms and Conditions",
                                    onTap: () {
                                      if (kIsWeb) {
                                        if(ApplicationBaseController.getInstance().termsAndConditionsLink.value == '' ||
                                            ApplicationBaseController.getInstance().termsAndConditionsLink.value == null
                                        ){
                                          showFailedToast('Error : Link Not found');
                                        }else{
                                          launchUrl(Uri.parse(ApplicationBaseController.getInstance().termsAndConditionsLink.value));
                                        }
                                      } else {
                                        launchUrl(Uri.parse(ApplicationBaseController.getInstance().termsAndConditionsLink.value));
                                      }
                                    },
                                    showBorder: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Logout Button
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: GestureDetector(
                  onTap: showLogoutDialog,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/logout.svg',
                                  width: 16,
                                  height: 16,
                                  color: appLoadController.appPrimaryColor,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    LocalizationController.getInstance().getTranslatedValue(
                                        "Logout - (${appLoadController.loggedUserData.value.userid})"
                                    ),
                                    style: TextStyle(
                                      color: appLoadController.appPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    commonText(
                      textAlign: TextAlign.center,
                      text: '© ${LocalizationController.getInstance().getTranslatedValue("Planet Combo... All rights reserved")}',
                      fontSize: 12,
                    ),
                    const SizedBox(height: 5),
                    commonText(
                      textAlign: TextAlign.center,
                      text: LocalizationController.getInstance().getTranslatedValue("Developed by Planetcombo Team"),
                      fontSize: 12,
                    ),
                    const SizedBox(height: 5),
                    commonText(
                      textAlign: TextAlign.center,
                      text: LocalizationController.getInstance().getTranslatedValue("Version : 1.0.0"),
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}