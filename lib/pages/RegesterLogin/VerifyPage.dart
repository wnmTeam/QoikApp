import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/localization.dart';

class VerifyPage extends StatelessWidget {
  final String email;

  final AuthController _authController = AuthController();

  VerifyPage(this.email) {
    _authController.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(context, "email_verification")),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _authController.logOut();
          return false;
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Languages.translate(context, "verif_sent"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width / ConstValues.fontSize_1 - 1,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '$email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width / ConstValues.fontSize_1 - 5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  child: Text(Languages.translate(context, "verified"),
                    style: TextStyle(
                      fontSize: width / ConstValues.fontSize_2,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () async {
                    await _authController.reloadUser();
                    print(_authController.isUserVerified());
                    Navigator.of(context).pushReplacementNamed('/StartingPage');
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  onPressed: () {
                    _authController.sendEmailVerification();
                  },
                  child: Text(Languages.translate(context, "send_verify_again"),
                    style: TextStyle(color: Theme
                        .of(context)
                        .primaryColor,),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
