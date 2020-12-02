import 'package:flutter/material.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
import 'StartingPage.dart';

class RouteController {
  static Route<dynamic> getRoute(RouteSettings settings) {
    final Map args = settings.arguments as Map;

    switch (settings.name) {
      case '/StartingPage':
        return MaterialPageRoute(builder: (_) => StartingPage());
      case '/RegisterLoginPage':
        return MaterialPageRoute(builder: (_) => RegisterLoginPage());
    }
  }
}
