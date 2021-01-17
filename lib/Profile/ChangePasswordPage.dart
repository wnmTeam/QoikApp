import 'package:flutter/material.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/StorageController.dart';

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
        title: Text('Change Password', style: TextStyle(color: Colors.grey[500]),),
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
                labelText: "Old Password",
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'password is required';
                } else if (value != password) return 'wrong password';
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
                labelText: "New password",
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'this field is required';
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
              child: Text('save'),
            )
          ],
        ),
      ),
    );
  }
}
