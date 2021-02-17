import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/Home/HomePage.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
import 'package:stumeapp/pages/RegesterLogin/VerifyPage.dart';
import 'package:url_launcher/url_launcher.dart';

class StartingPage extends StatefulWidget {
  @override
  _StartingPageState createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  final AuthController _controller = AuthController();

//  NotificationApi _notificationApi = NotificationApi();

  bool loading = true;
  bool canGo = false;
  String appUrl = "";

  //TODO : Get the links from the server
  String googlePlayUrl =
      "https://play.google.com/store/apps/details?id=com.abosak.stumeapp";
  String appStoreUrl =
      "https://play.google.com/store/apps/details?id=com.abosak.stumeapp";

  _check() async {
    var lastV = await _controller.getLastVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    print(
        'ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd');
    print(lastV.data()['version']);
    print(versionName);
    print(versionCode);
    print(lastV.data()['version'] == versionCode);
    setState(() {
      canGo = lastV.data()['version'] == versionCode;
      loading = false;
    });
  }

  @override
  void initState() {
    appUrl = Platform.isAndroid ? googlePlayUrl : appStoreUrl;
    _check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !loading
          ? canGo
              ? StreamBuilder(
                  stream: _controller.authStream,
                  builder: (context, snapshot) {
                    if (snapshot.data == null)
                      return RegisterLoginPage();
                    else {
                      if (!snapshot.data.emailVerified)
                        return VerifyPage(_controller.getUser.email);
                      print('done ');
                      return HomePage();
                    }
                  })
              : FractionallySizedBox(
                  widthFactor: 1,
                  child: Container(
                    color: ConstValues.firstColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //TODO: Change the image
                        Image.asset("assets/login.png"),
                        Text(
                          Languages.translate(context, "update_message"),
                          style: TextStyle(
                              fontSize: ConstValues.fontSize_2,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RaisedButton(
                          onPressed: () async => {
                            if (appUrl != null)
                              {
                                await launch(appUrl)
                                    .then((value) => print('url  ' + appUrl))
                              }
                            else
                              {throw 'cant launch url'}
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          color: Colors.white,
                          child: Text(
                            Languages.translate(
                              context,
                              'update_app',
                            ),
                            style: TextStyle(
                              color: ConstValues.firstColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/launchImage.png",
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: MediaQuery.of(context).size.height / 10,
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )),
                ),
              ],
            ),
    );
  }
}
