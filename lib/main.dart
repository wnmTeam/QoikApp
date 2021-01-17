import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'RouteController.dart';
import 'localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(229, 26, 75, .1),
      100: Color.fromRGBO(229, 26, 75, .2),
      200: Color.fromRGBO(229, 26, 75, .3),
      300: Color.fromRGBO(229, 26, 75, .4),
      400: Color.fromRGBO(229, 26, 75, .5),
      500: Color.fromRGBO(229, 26, 75, .6),
      600: Color.fromRGBO(229, 26, 75, .7),
      700: Color.fromRGBO(229, 26, 75, .8),
      800: Color.fromRGBO(229, 26, 75, .9),
      900: Color.fromRGBO(229, 26, 75, 1),
    };

    MaterialColor colorCustom = MaterialColor(0xFFE51A4B, color);

    return MaterialApp(
      title: 'Stume',
      debugShowCheckedModeBanner: true,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      theme: ThemeData(
        primarySwatch: colorCustom ,
        accentColor: colorCustom[700],
      ),

      // darkTheme: ThemeData(
      //   primarySwatch: Colors.red,
      //   accentColor: Colors.redAccent,
      // ),
      supportedLocales: [
        Locale('ar'),
        Locale('tr'),
        Locale('en'),
      ],
      localizationsDelegates: [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: '/StartingPage',
      onGenerateRoute: RouteController.getRoute,
    );
  }
}
