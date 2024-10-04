import 'dart:convert';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/routes/app_routes.dart';
import 'package:planetcombo/screens/authentication.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/social_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:planetcombo/screens/web/web_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'models/social_login.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

bool userValue = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if(!kIsWeb){
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    print('User granted permission: ${settings.authorizationStatus}');
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission granted');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a message in the foreground!');
        print('Message data: ${message.data}');
        if (message.notification != null) {
          print('Message contains a notification: ${message.notification}');
        }
      });
    } else {
      print('Notification permission denied');
      showFailedToast('Notifications have been blocked. Please enable them to receive notifications.');
    }
  }else{
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCXAw8BQBx4OPMOWyNaI4bv7gh5GUXa0lQ",
          authDomain: "flutterplanetcombo-ff367.firebaseapp.com",
          databaseURL: "https://flutterplanetcombo-ff367-default-rtdb.firebaseio.com",
          projectId: "flutterplanetcombo-ff367",
          storageBucket: "flutterplanetcombo-ff367.appspot.com",
          messagingSenderId: "488939796804",
          appId: "1:488939796804:web:5c94e0a3b5f03ca2abbf11",
          measurementId: "G-MLW4X9WR7H"
      ),
    );
  }

  await LocalizationController.getInstance().getLanguage();

  final AppLoadController appLoadController = Get.put(AppLoadController.getInstance(), permanent: true);
  final ApplicationBaseController applicationBaseController = Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final prefs = await SharedPreferences.getInstance();
  String? jsonString = prefs.getString('UserInfo');
  if (jsonString != 'null' && jsonString != null) {
    var jsonBody = json.decode(jsonString);
    appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
    applicationBaseController.initializeApplication();
    userValue = true;
    appLoadController.userValue.value = true;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();
  MyApp({super.key});

  final AppLoadController appLoadController = Get.put(AppLoadController.getInstance(), permanent: true);

  Widget getInitScreen() {
    if (!kIsWeb) {
      return userValue
          ? (appLoadController.loggedUserData.value.touchid == 'T'
          ? const Authentication()
          : const Dashboard())
          : const SocialLogin();
    } else {
      return userValue ? const Dashboard() : WebHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planet Combo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        radioTheme: RadioThemeData(
          fillColor: WidgetStateColor.resolveWith((states) => Colors.orangeAccent),
        ),
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: _appRouter.onGenerateRoute,
      home: getInitScreen(),
      builder: EasyLoading.init(),
    );
  }
}
