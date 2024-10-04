import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class SocialLoginController extends GetxController {
  static SocialLoginController? _instance;

  static SocialLoginController getInstance() {
    _instance ??= SocialLoginController();
    return _instance!;
  }
  static bool _fbIsInitialized = false;

  static Future<void> initialize() async {
    if (kIsWeb && !_fbIsInitialized) {
      await FacebookAuth.instance.webAndDesktopInitialize(
        appId: "YOUR_FACEBOOK_APP_ID", // Replace with your actual App ID
        cookie: true,
        xfbml: true,
        version: "v15.0",
      );
      _fbIsInitialized = true;
    }
  }

  static Future<void> loginWithFacebook(context) async {
    try {
      if (kIsWeb && !html.window.location.protocol.contains('https')) {
        throw Exception('Facebook login requires HTTPS. Please use a secure connection.');
      }

      CustomDialog.showLoading(context, 'Please wait');

      await initialize();

      final LoginResult result = await FacebookAuth.instance.login();
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
      CustomDialog.showAlert(context, 'Facebook login failed: ${e.toString()}', false, 14);
    }
  }

}