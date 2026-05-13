import 'dart:convert';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:planetcombo/common/app_logger.dart';
import 'package:planetcombo/common/keyboard_scroll_wrapper.dart';
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
  AppLogger.i('Handling a background message: ${message.messageId}',
      tag: 'FCM');
}

bool userValue = false;

/// Observes route changes app-wide. The Dashboard subscribes so it can
/// pause its background video when the user navigates to another screen
/// and resume when they come back.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

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
        AppLogger.i('Firebase Web initialized successfully', tag: 'Firebase');
      }).catchError((error) {
        AppLogger.e('Error initializing Firebase Web',
            tag: 'Firebase', error: error);
      });
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).then((_) {
        AppLogger.i('Firebase Mobile initialized successfully',
            tag: 'Firebase');
      }).catchError((error) {
        AppLogger.e('Error initializing Firebase Mobile',
            tag: 'Firebase', error: error);
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

        AppLogger.i('User granted permission: ${settings.authorizationStatus}',
            tag: 'FCM');

        final fcmToken = await FirebaseMessaging.instance.getToken();
        AppLogger.d('FCM Token: $fcmToken', tag: 'FCM');

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          AppLogger.i('Notification permission granted', tag: 'FCM');

          // Handle foreground messages
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            AppLogger.i('Received a message in the foreground', tag: 'FCM');
            AppLogger.d('Message data: ${message.data}', tag: 'FCM');
            if (message.notification != null) {
              AppLogger.d(
                  'Message contains a notification: ${message.notification}',
                  tag: 'FCM');
            }
          });
        } else {
          AppLogger.w('Notification permission denied', tag: 'FCM');
          showFailedToast('Notifications have been blocked. Please enable them to receive notifications.');
        }
      } catch (e, st) {
        AppLogger.e('Error setting up Firebase Messaging',
            tag: 'FCM', error: e, stackTrace: st);
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
    } catch (e, st) {
      AppLogger.e('Error handling user authentication state',
          tag: 'Init', error: e, stackTrace: st);
    }
  } catch (e, st) {
    AppLogger.e('Error in initializeApp',
        tag: 'Init', error: e, stackTrace: st);
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

  final TransitionBuilder _easyLoadingBuilder = EasyLoading.init();

  Widget getInitScreen() {
    if (!kIsWeb) {
      return userValue
          ? (appLoadController.loggedUserData.value.touchid == 'T'
          ? const Authentication()
          : const Dashboard())
          : WebHomePage();
    } else {
      return userValue ? const Dashboard() : WebHomePage();
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
      navigatorObservers: [appRouteObserver],
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
      builder: (context, child) {
        final loaded = _easyLoadingBuilder(context, child);
        return kIsWeb ? KeyboardScrollWrapper(child: loaded) : loaded;
      },
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