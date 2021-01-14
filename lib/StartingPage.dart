import 'package:flutter/cupertino.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/pages/Home/HomePage.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
import 'package:stumeapp/pages/RegesterLogin/VerifyPage.dart';

class StartingPage extends StatelessWidget {
  final AuthController _controller = AuthController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _controller.authStream,
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return RegisterLoginPage();
          else {
            if (!snapshot.data.emailVerified) return VerifyPage(_controller.getUser.email);
            return HomePage();
          }
        });
  }
}
