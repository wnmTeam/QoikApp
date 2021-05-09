import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/StorageController.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'message.dart';
// import 'message_list.dart';
// import 'permissions.dart';
// import 'token_monitor.dart';

import 'RouteController.dart';
import 'localization.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

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
  String theme;
  static Locale locale;
  static bool isDark = false;
  int sColor = 0xff333333;

  @override
  void initState() {
    super.initState();



    setLanguage();
    setTheme();
  }

  @override
  Widget build(BuildContext context) {
    myAppState = this;
    return MaterialApp(
      title: 'Qoiq',
      debugShowCheckedModeBanner: true,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      theme: isDark
          ? ThemeData(
              brightness: Brightness.dark,

              primarySwatch: ConstValues.firstColorDark,
              primaryColor: ConstValues.firstColorDark,
              buttonColor: Colors.blueGrey,

              scaffoldBackgroundColor: Color(sColor),
              cardColor: Color(sColor),

              //canvasColor is the drawer backgroundColor
              canvasColor: Color(sColor),
              dialogBackgroundColor: Color(sColor),
              accentColor: Colors.yellowAccent,

              backgroundColor: Colors.grey,
              textButtonTheme: TextButtonThemeData(style: ButtonStyle()),
              iconTheme: IconThemeData(color: Colors.white),

              //Search friends button
              buttonTheme: ButtonThemeData(
                  textTheme: ButtonTextTheme.primary,
                  buttonColor: Theme.of(context).primaryColor),

              textTheme: TextTheme(
                button: TextStyle(
                  color: Colors.red,
                ),

                headline1: TextStyle(color: Colors.indigo),
                headline2: TextStyle(color: Colors.deepPurple),
                headline3: TextStyle(color: Colors.brown),
                headline4: TextStyle(color: Colors.deepOrange),
                headline5: TextStyle(color: Colors.teal),

                subtitle2: TextStyle(
                  color: Colors.red,
                ),

                overline: TextStyle(
                  color: Colors.blue,
                ),

                //For AlertDialog title and ...
                headline6: TextStyle(
                  color: Colors.white,
                ),

                //For drawer text and ...
                bodyText1: TextStyle(
                  color: Colors.white,
                ),

                //For normal text (post, comment, ...) and ...
                bodyText2: TextStyle(
                  color: Colors.white,
                ),

                //For listTile title and ...
                subtitle1: TextStyle(
                  color: Colors.white,
                ),

                //For listTile subtitle and ...
                caption: TextStyle(
                  color: Colors.white60,
                ),
              ),
            )
          : ThemeData(
              brightness: Brightness.light,

              primarySwatch: ConstValues.firstColor,
              primaryColor: ConstValues.firstColor,
              buttonColor: ConstValues.firstColor,

              accentColor: Colors.blueAccent,

              backgroundColor: Colors.white,
              scaffoldBackgroundColor: Colors.white,
              dialogBackgroundColor: Colors.white,
              cardColor: Colors.white,

              //canvasColor is the drawer backgroundColor
              canvasColor: Colors.white,

              iconTheme: IconThemeData(color: Colors.white),

              //Search friends button
              buttonTheme: ButtonThemeData(
                  textTheme: ButtonTextTheme.primary,
                  buttonColor: Theme.of(context).primaryColor),

              textTheme: TextTheme(
                button: TextStyle(
                  color: Colors.white,
                ),
                // headline1: TextStyle(color: Colors.indigo),
                // headline2: TextStyle(color: Colors.deepPurple),
                // headline3: TextStyle(color: Colors.brown),
                // headline4: TextStyle(color: Colors.deepOrange),
                // headline5: TextStyle(color: Colors.teal),
                // subtitle2: TextStyle(color: Colors.red,),
                // overline: TextStyle(color: Colors.blue,),

                //For AlertDialog title and ...
                headline6: TextStyle(
                  color: Colors.black,
                ),

                //For drawer text and ...
                bodyText1: TextStyle(
                  color: Colors.black,
                ),

                //For normal text (post, comment, ...) and ...
                bodyText2: TextStyle(
                  color: Colors.black,
                ),

                //For listTile title and ...
                subtitle1: TextStyle(
                  color: Colors.black,
                ),

                //For listTile subtitle and ...
                caption: TextStyle(
                  color: Colors.black54,
                ),
              ),

              textButtonTheme: TextButtonThemeData(style: ButtonStyle()),
            ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,

        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.blueGrey,
        buttonColor: Colors.blueGrey,

        accentColor: Colors.yellowAccent,
        backgroundColor: Colors.grey,
        textButtonTheme: TextButtonThemeData(style: ButtonStyle()),
        scaffoldBackgroundColor: Colors.grey,

        dialogBackgroundColor: Colors.grey,
        cardColor: Colors.grey[600],
        buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.normal, buttonColor: Colors.red),
        textTheme: TextTheme(
          button: TextStyle(
            color: Colors.red,
          ),

          headline1: TextStyle(color: Colors.indigo),
          headline2: TextStyle(color: Colors.deepPurple),
          headline3: TextStyle(color: Colors.brown),
          headline4: TextStyle(color: Colors.deepOrange),
          headline5: TextStyle(color: Colors.teal),
          headline6: TextStyle(color: Colors.lime),

          subtitle2: TextStyle(
            color: Colors.red,
          ),

          overline: TextStyle(
            color: Colors.blue,
          ),

          //For drawer text and ...
          bodyText1: TextStyle(
            color: Colors.white,
          ),

          //For normal text (post, comment, ...) and ...
          bodyText2: TextStyle(
            color: Colors.white,
          ),

          //For listTile title and ...
          subtitle1: TextStyle(
            color: Colors.white,
          ),

          //For listTile subtitle and ...
          caption: TextStyle(
            color: Colors.white60,
          ),
        ),
        //canvasColor is the drawer backgroundColor
        canvasColor: Colors.grey,
      ),
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

  void setLanguage() async {
    await storageController.createPreferences();
    lang = storageController.getLang();
    print(lang);
    if (lang != null)
      setState(() {
        locale = Locale(lang);
      });
  }

  void setTheme() async {
    await storageController.createPreferences();
    theme = storageController.getTheme();
    print(theme);
    if (theme != null)
      setState(() {
        isDark = theme == 'dark';
      });
  }

  void _notificationRout({RemoteMessage message}) {
    Map data = message.data;
    Navigator.pushNamed(context, '/NotificationsPage');
    print(data);

  }

  _createForgroundNotification({RemoteMessage message}){
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ));
    }
  }
}
