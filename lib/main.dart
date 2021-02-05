import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/StorageController.dart';

import 'RouteController.dart';
import 'localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static MyAppState myAppState;

  StorageController storageController = new StorageController();
  String lang;
  static Locale locale;

  @override
  Widget build(BuildContext context) {
    myAppState = this;
    lang = storageController.getLang();
    locale = Locale(lang);

    return MaterialApp(
      title: 'Qoiq',
      debugShowCheckedModeBanner: true,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      theme: ThemeData(
        primarySwatch: ConstValues.firstColor,
        accentColor: Color(0xFF8D5CD7),
      ),

      // darkTheme: ThemeData(
      //   primarySwatch: Colors.red,
      //   accentColor: Colors.redAccent,
      // ),
      locale: locale,
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
