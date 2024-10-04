import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:planetcombo/screens/dashboard.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Authentication> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
      print('Error checking biometrics: $e');
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      if (_canCheckBiometrics) {
        _authenticate();
      } else {
        // Handle the case where biometrics are not available on the device
        _showErrorMessage('Biometric authentication not available');
      }
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access the app',
      );
    } catch (e) {
      print('Error: $e');
    }

    if (authenticated) {
      // User authenticated successfully, navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else {
      // Authentication failed or user canceled, display message and exit
      _showErrorMessage('Authentication failed. Please try again or exit.');
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Authentication Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _authenticate(); // Retry authentication
              },
              child: Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Close the app
                Navigator.of(context).pop();
              },
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _canCheckBiometrics
            ? CircularProgressIndicator()
            : Text('Biometric authentication not available'),
      ),
    );
  }
}
