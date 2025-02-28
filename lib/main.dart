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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

bool userValue = false;

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Firebase based on platform
    if (kIsWeb) {
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
      ).then((_) {
        print('Firebase Web initialized successfully');
      }).catchError((error) {
        print('Error initializing Firebase Web: $error');
      });
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).then((_) {
        print('Firebase Mobile initialized successfully');
      }).catchError((error) {
        print('Error initializing Firebase Mobile: $error');
      });

      // Mobile specific Firebase Messaging setup
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      try {
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

          // Handle foreground messages
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
      } catch (e) {
        print('Error setting up Firebase Messaging: $e');
      }
    }

    // Initialize localization
    await LocalizationController.getInstance().getLanguage();

    // Initialize controllers
    final AppLoadController appLoadController = Get.put(AppLoadController.getInstance(), permanent: true);
    final ApplicationBaseController applicationBaseController = Get.put(ApplicationBaseController.getInstance(), permanent: true);

    // Handle user authentication state
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('UserInfo');
      if (jsonString != 'null' && jsonString != null) {
        var jsonBody = json.decode(jsonString);
        appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
        applicationBaseController.initializeApplication();
        userValue = true;
        appLoadController.userValue.value = true;
      }
    } catch (e) {
      print('Error handling user authentication state: $e');
    }
  } catch (e) {
    print('Error in initializeApp: $e');
    // You might want to rethrow the error or handle it appropriately
  }
}

void main() {
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
          : Dashboard())
          : const SocialLogin();
    } else {
      return userValue ? Dashboard() : WebHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planet Combo',
      locale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('en', 'GB'),
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        radioTheme: RadioThemeData(
          fillColor: MaterialStateColor.resolveWith((states) => Colors.orangeAccent),
        ),
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: _appRouter.onGenerateRoute,
      home: FutureBuilder(
        future: initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error initializing app: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return getInitScreen();
          }
          return const AnimatedLoadingScreen();
        },
      ),
      builder: EasyLoading.init(),
    );
  }
}

class AnimatedLoadingScreen extends StatefulWidget {
  const AnimatedLoadingScreen({super.key});

  @override
  _AnimatedLoadingScreenState createState() => _AnimatedLoadingScreenState();
}

class _AnimatedLoadingScreenState extends State<AnimatedLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 5,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Loading Planet Combo...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}