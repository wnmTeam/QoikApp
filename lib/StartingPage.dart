import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/pages/Home/HomePage.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
import 'package:stumeapp/pages/RegesterLogin/VerifyPage.dart';

class StartingPage extends StatefulWidget {
  @override
  _StartingPageState createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  final AuthController _controller = AuthController();

//  NotificationApi _notificationApi = NotificationApi();

  bool loading = true;
  bool canGo = false;

  _check() async {
    var lastV = await _controller.getLastVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    print(
        'ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd');
    print(lastV);
    print(versionName);
    print(versionCode);
    setState(() {
      canGo = lastV.data()['version'] == versionCode;
      loading = false;
    });
  }

  @override
  void initState() {
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
              : Center(
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          'Please Update Qoiq And Try Again!',
                          style: TextStyle(
                              fontSize: ConstValues.fontSize_1,
                              color: Colors.black),
                        )
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
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
    );
  }
}
