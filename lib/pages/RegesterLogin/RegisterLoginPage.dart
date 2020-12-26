import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';

import 'Widgets.dart';

class RegisterLoginPage extends StatefulWidget {
  @override
  _RegisterLoginPageState createState() => _RegisterLoginPageState();
}

class _RegisterLoginPageState extends State<RegisterLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _coPasswordController = TextEditingController();
  final TextEditingController _resetController = TextEditingController();

  AuthController _authController = AuthController();

  int _value = 1;
  String _gender = 'male';
  String _degree;
  String _college;
  String _univercity;
  bool _checkedTrueInfo = false;

  bool _isRegister = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Container(
                  height: 250,
                  child: Center(child: Text('LOGO')),
                ),
                _isRegister ? _registerForm() : _loginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _degreeInfoBuild() {
    switch (_degree) {
      case 'hight school':
        return Container();
      case 'college':
      case 'graduate':
      case 'master':
        return Column(
          children: [
            MyDropdownButton(
                items: [
                  'University1',
                  'University2',
                  'University3',
                  'University4',
                ],
                onSelected: (_selected) {
                  setState(() {
                    _univercity = _selected;
                  });
                },
                label: 'Univercity'),
            SizedBox(
              height: 20,
            ),
            MyDropdownButton(
                items: [
                  'College1',
                  'College2',
                  'College3',
                  'College4',
                ],
                onSelected: (_selected) {
                  setState(() {
                    _college = _selected;
                  });
                },
                label: 'College'),
            SizedBox(
              height: 20,
            ),
          ],
        );
      default:
        return Container();
    }
  }

  _loginForm() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'email is required';
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'password is required';
                }
                return null;
              },
            ),
            SizedBox(
              height: 15,
            ),
            FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ResetDialog(
                        resetEmailController: _resetController,
                        onPressed: () {
                          _authController.resetPassword(_resetController.text);
                        },
                      );
                    });
              },
              child: Text(
                'forgut password?',
                style: TextStyle(
                  color: Colors.indigo,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                color: Colors.indigo,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await _authController.login(
                        _emailController.text, _passwordController.text);
                    print('login done');
                  }
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      );

  _registerForm() => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'this field is required';
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _secondNameController,
              decoration: const InputDecoration(
                labelText: 'Second Name',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'this field is required';
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Radio(
                        activeColor: Colors.indigoAccent,
                        value: 1,
                        groupValue: _value,
                        onChanged: (i) {
                          setState(() {
                            _value = i;
                            _gender = 'male';
                          });
                        },
                      ),
                      Text(
                        'male',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        activeColor: Colors.indigoAccent,
                        value: 2,
                        groupValue: _value,
                        onChanged: (i) {
                          setState(() {
                            _value = i;
                            _gender = 'female';
                          });
                        },
                      ),
                      Text(
                        'female',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            MyDropdownButton(
                items: [
                  'hight school',
                  'college',
                  'master',
                  'graduate',
                ],
                onSelected: (_selected) {
                  setState(() {
                    _degree = _selected;
                  });
                },
                label: 'degree'),
            SizedBox(
              height: 20,
            ),
            _degreeInfoBuild(),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'email is required';
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'password is required';
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _coPasswordController,
              decoration: const InputDecoration(
                labelText: 'confirm Password',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'this field is required';
                } else if (value != _passwordController.text)
                  return 'wrong password';
                return null;
              },
            ),
            SizedBox(
              height: 15,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("All entered informations are true"),
              value: _checkedTrueInfo,
              onChanged: (newValue) {
                setState(() {
                  _checkedTrueInfo = newValue;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                color: Colors.indigo,
                onPressed: () async {
                  if (_formKey.currentState.validate() &&
                      _checkedTrueInfo == true) {
                    _authController.createAccount(
                      _emailController.text,
                      _passwordController.text,
                      User(
                        firstName: _firstNameController.text,
                        secondName: _secondNameController.text,
                        degree: _degree,
                        gender: _gender,
                        university: _univercity,
                        college: _college,
                      ),
                    );
                  }
                },
                child: const Text('Signup'),
              ),
            ),
            FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _isRegister = false;
                });
              },
              child: Text(
                'already have an account?',
                style: TextStyle(
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
        ),
      );
}
