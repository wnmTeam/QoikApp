import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'RouteController.dart';
import 'localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      supportedLocales: [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      // localeResolutionCallback: (locale, supportedLocals) {
      //   if (SavedSetting.LANGUAGE == null) {
      //     for (var supportedLocal in supportedLocals) {
      //       print(supportedLocal.toString() + "  :  " + locale.toString());
      //       //TODO: if you want to Use English Version Just flip the Following Condition from '!=' to '=='
      //       if (supportedLocal.languageCode == locale.languageCode)
      //         SavedSetting.LANGUAGE = supportedLocal.languageCode;
      //       print('2 + ${SavedSetting.LANGUAGE}');
      //       return supportedLocal;
      //     }
      //     SavedSetting.LANGUAGE = supportedLocals.first.languageCode;
      //     print('1 + ${SavedSetting.LANGUAGE}');
      //     return supportedLocals.first;
      //   } else {
      //     return Locale(SavedSetting.LANGUAGE);
      //   }
      // },


      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.indigo, accentColor: Colors.indigoAccent),
      initialRoute: '/StartingPage',
      onGenerateRoute: RouteController.getRoute,
    );
  }
}
