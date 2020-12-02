import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/controller/AuthController.dart';

class VerifyPage extends StatelessWidget {
  String email;

  AuthController _authController = AuthController();

  VerifyPage(this.email) {
    _authController.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text('verify message sent to $email'),
            SizedBox(
              height: 20,
            ),
            RaisedButton(
              onPressed: () async{
                await _authController.reloadUser();
                print('fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
                print(_authController.isUserVerified());
                Navigator.of(context).pushReplacementNamed('/StartingPage');
              },
              child: Text('verified'),
            ),
            FlatButton(
              onPressed: (){
                _authController.sendEmailVerification();
              },
              child: Text('send verify again'),
            )
          ],
        ),
      ),
    );
  }
}
