import 'package:flutter/material.dart';

import 'package:planetcombo/screens/web/webLogin.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/web/web_home.dart';
import 'package:planetcombo/screens/web/web_article.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => WebHomePage(),
        );
      case '/webHome':
        return MaterialPageRoute(
          builder: (_) => WebHomePage(),
        );
      case '/webLogin':
        return MaterialPageRoute(
          builder: (_) => const WebLogin(),
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const Dashboard(),
        );
      default:
        return null;
    }
  }
}