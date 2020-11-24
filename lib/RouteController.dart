import 'package:flutter/material.dart';
import 'package:stumeapp/pages/RegesterLogin/RegesterLoginPage.dart';




class RouteController {
  static Route<dynamic> getRoute(RouteSettings settings) {
    final Map args = settings.arguments as Map;

    switch (settings.name) {
      case '/RegesterLoginPage':
        return MaterialPageRoute(builder: (_) => RegesterLoginPage());


    }
  }
}
