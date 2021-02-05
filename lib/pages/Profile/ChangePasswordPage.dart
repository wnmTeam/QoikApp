import 'package:flutter/material.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';

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

  String password;

  @override
  void initState() {
    password = _storageController.getUserPassword();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(Languages.translate(
          context,
          'change_password',
        ), style: TextStyle(color: Colors.grey[500]),),
        iconTheme: IconThemeData(color: Colors.grey[600]),
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
                } else if (value != password) return Languages.translate(
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
              height: 15,
            ),
            RaisedButton(
              onPressed: ()async {
                if (_formKey.currentState.validate()) {
                  await _authController.updatePassword(_newPasswordController.text);
                  print('login done');
                }
              },
              child: Text(Languages.translate(
                context,
                'save',
              )),
            )
          ],
        ),
      ),
    );
  }
}
