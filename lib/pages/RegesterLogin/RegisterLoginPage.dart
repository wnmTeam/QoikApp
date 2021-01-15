import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';

import 'Widgets.dart';

class RegisterLoginPage extends StatefulWidget {
  @override
  _RegisterLoginPageState createState() => _RegisterLoginPageState();
}

double width;

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
  String _university;
  bool _checkedTrueInfo = false;

  bool _isRegister = true;

  Future<bool> _onBackBressed() {
    if (!_isRegister)
      setState(() {
        _isRegister = true;
      });
    else
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onBackBressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
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
      case 'high school':
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
                    _university = _selected;
                  });
                },
                label: 'University'),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/login.png',
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Welcome back!",
              style: TextStyle(
                fontSize: width / ConstValues.fontSize_1,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Log in to Live your life smarter with us!",
              style: TextStyle(
                color: Color.fromARGB(150, 0, 0, 0),
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            TextFormField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                icon: Icon(Icons.email_outlined),
                labelText: 'Email',
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
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_open),
                labelText: "Password",
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
            Align(
              alignment: Alignment.centerLeft,
              child: FlatButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ResetDialog(
                          resetEmailController: _resetController,
                          onPressed: () {
                            _authController
                                .resetPassword(_resetController.text);
                          },
                        );
                      });
                },
                child: Text(
                  "Forget your password?",
                  style: TextStyle(
                    color: Color.fromARGB(150, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),

            // FlatButton(
            //   padding: EdgeInsets.zero,
            //   onPressed: () async {
            //     showDialog(
            //         context: context,
            //         builder: (context) {
            //           return ResetDialog(
            //             resetEmailController: _resetController,
            //             onPressed: () {
            //               _authController.resetPassword(_resetController.text);
            //             },
            //           );
            //         });
            //   },
            //   child: Text(
            //     'forgot password?',
            //     style: TextStyle(
            //       color: Colors.indigo,
            //     ),
            //   ),
            // ),
            RaisedButton(
                color: Colors.indigo,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await _authController.login(
                        _emailController.text, _passwordController.text);
                    print('login done');
                  }
                },
                child: Text(
                  'LOG IN',
                  style: TextStyle(
                    fontSize: width / ConstValues.fontSize_2,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                )),
            // FlatButton(
            //   padding: EdgeInsets.zero,
            //   onPressed: () {
            //     setState(() {
            //       _isRegister = true;
            //     });
            //   },
            //   child: Text(
            //     "don't have an account ?",
            //     style: TextStyle(
            //       color: Colors.indigo,
            //     ),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "don't have an account ?",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _isRegister = true;
                    });
                  },
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  _registerForm() => Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/signUp.png'),
              SizedBox(
                height: 12,
              ),
              Text(
                "Let's Get Started!",
                style: TextStyle(
                  fontSize: width / ConstValues.fontSize_1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Improve the communications with your collages",
                style: TextStyle(
                  color: Color.fromARGB(150, 0, 0, 0),
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextFormField(
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  icon: Icon(Icons.person_outline),
                  labelText: 'First Name',
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
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: 'Second Name',
                  icon: Icon(Icons.person_outline),
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
                label: 'degree',
              ),
              SizedBox(
                height: 20,
              ),
              _degreeInfoBuild(),
              TextFormField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  icon: Icon(Icons.email_outlined),
                  labelText: 'Email',
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
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock_open),
                  labelText: "Password",
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
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock_open),
                  labelText: "Confirm password",
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
                title: Text("All  information are true"),
                value: _checkedTrueInfo,
                onChanged: (newValue) {
                  setState(() {
                    _checkedTrueInfo = newValue;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(
                height: 15,
              ),
              RaisedButton(
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
                        university: _university,
                        college: _college,
                        groups: [_university, _college],
                        points: 10,
                        enterCount: 0,
                        bio: 'Hey There.. I am New User.',
                        recordDate: DateTime.now(),
                      ),
                    );
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  "Create account",
                  style: TextStyle(
                    fontSize: width / ConstValues.fontSize_2,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "already have an account?",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        _isRegister = false;
                      });
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
