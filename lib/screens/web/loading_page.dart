import 'package:flutter/material.dart';
import 'package:planetcombo/screens/web/webLogin.dart';

class LoadingPage extends StatelessWidget {
  // Simulate a network call or initialization process
  Future<void> _initializePage() async {
    await Future.delayed(Duration(seconds: 3)); // Simulate a delay
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading Example'),
      ),
      body: FutureBuilder<void>(
        future: _initializePage(),
        builder: (context, snapshot) {
          // Check if the future is still being processed
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Handle errors if any
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // Show the actual content once the initialization is complete
            return WebLogin();
          }
        },
      ),
    );
  }
}