import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SocialLoginController extends GetxController {
  static SocialLoginController? _instance;

  static SocialLoginController getInstance() {
    _instance ??= SocialLoginController();
    return _instance!;
  }
  static bool _fbIsInitialized = false;

  static Future<void> initialize(BuildContext context) async {
    if (kIsWeb && !_fbIsInitialized) {
      print('Initializing Facebook SDK...');
      try {
        await FacebookAuth.instance.webAndDesktopInitialize(
          appId: "YOUR_FACEBOOK_APP_ID", // Replace with your actual App ID
          cookie: true,
          xfbml: true,
          version: "v15.0",
        );
        print('Facebook SDK initialized successfully');
        _fbIsInitialized = true;
      } catch (e) {
        print('Facebook SDK initialization failed: $e');
      }
      print('Facebook SDK initialization process completed');
    }
  }

  static Future<void> loginWithFacebook(BuildContext context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');

      await initialize(context);
      print('Attempting Facebook login...');

      final LoginResult result = await FacebookAuth.instance.login()
          .timeout(Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Facebook login timed out');
      });

      print('Login result: ${result.status}, Message: ${result.message}');

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        final userData = await FacebookAuth.instance.getUserData();

        final AuthCredential credential = FacebookAuthProvider.credential(accessToken!.token);
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User user = userCredential.user!;

        print('Facebook login successful. User: ${user.displayName}');
        print('User data: $userData');

        CustomDialog.cancelLoading(context);
        // Navigate to your app's main screen or perform other actions
      } else {
        throw Exception('Facebook login failed. Status: ${result.status}');
      }
    } catch (e) {
      print('Exception during Facebook login: $e');
      CustomDialog.cancelLoading(context);

      String errorMessage = 'Facebook login failed';
      if (e is TimeoutException) {
        errorMessage = 'Login timed out. Please check your internet connection and try again.';
      } else if (e is FirebaseAuthException) {
        errorMessage = 'Firebase authentication error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'An error occurred: ${e.toString()}';
      }

      CustomDialog.showAlert(context, errorMessage, false, 14);
    }
  }

}