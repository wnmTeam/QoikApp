import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';

class VerifyPage extends StatelessWidget {
  String email;

  AuthController _authController = AuthController();

  VerifyPage(this.email) {
    _authController.sendEmailVerification();
  }

  double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        //TODO : translation
        title: Text("Email Verification"),
      ),
      body: WillPopScope(
        onWillPop: ()async{
          _authController.logOut();
          return false;
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //TODO : translation
                Text(
                  'Verify message sent to',
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
                  //TODO : translation
                  child: Text(
                    'Verified',
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
                  //TODO : translation
                  child: Text(
                    'send verify again',
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
