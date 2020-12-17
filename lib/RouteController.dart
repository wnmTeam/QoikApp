import 'package:flutter/material.dart';
import 'package:stumeapp/pages/Group/GroupPage.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
import 'package:stumeapp/pages/WritePost.dart';
import 'StartingPage.dart';

class RouteController {
  static Route<dynamic> getRoute(RouteSettings settings) {
    final Map args = settings.arguments as Map;

    switch (settings.name) {
      case '/StartingPage':
        return MaterialPageRoute(builder: (_) => StartingPage());
      case '/RegisterLoginPage':
        return MaterialPageRoute(builder: (_) => RegisterLoginPage());
      case '/GroupPage':
        return MaterialPageRoute(builder: (_) => GroupPage(args['group']));
      case '/WritePostPage':
        return MaterialPageRoute(builder: (_) => WritePostPage(args['group']));
    }
  }
}
