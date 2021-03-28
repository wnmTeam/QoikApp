import 'package:flutter/material.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
// import 'package:toast/toast.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  StorageController _storageController = StorageController();
  AuthController _authController = AuthController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool updating = false;

  double width;

  String password;

  @override
  void initState() {
    password = _storageController.getUserPassword();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Languages.translate(
            context,
            'change_password',
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.next,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_open),
                labelText: Languages.translate(
                  context,
                  'old_password',
                ),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return Languages.translate(
                    context,
                    'password_is_Requered',
                  );
                } else if (value != password)
                  return Languages.translate(
                    context,
                    'wrong_password',
                  );
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _newPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_open),
                labelText: Languages.translate(
                  context,
                  'new_passeord',
                ),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return Languages.translate(
                    context,
                    'field_requered',
                  );
                }
                return null;
              },
            ),
            SizedBox(
              height: 40,
            ),
            RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    updating = true;
                  });
                  try {
                    await _authController.login(_authController.getUser.email,
                        _passwordController.text);
                    await _authController
                        .updatePassword(_newPasswordController.text);
                    _authController.logOut();
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });
                  } catch (e) {
                    // TODO

                    // Toast.show("Fail", context,
                    //     backgroundColor: Colors.grey,
                    //     textColor: Colors.white,
                    //     duration: Toast.LENGTH_LONG,
                    //     gravity: Toast.CENTER);
                  }
                  setState(() {
                    updating = false;
                  });

                  print('login done');
                }
              },
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: !updating
                  ? Text(Languages.translate(
                context,
                'save',
              ))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      )),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    Languages.translate(
                      context,
                      'whaiting',
                    ),
                    style: TextStyle(
                      fontSize: width / ConstValues.fontSize_2,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
