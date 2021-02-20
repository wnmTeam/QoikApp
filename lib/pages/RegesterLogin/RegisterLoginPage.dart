import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/localization.dart';
import 'package:toast/toast.dart';

import 'Widgets.dart';

class RegisterLoginPage extends StatefulWidget {
  @override
  _RegisterLoginPageState createState() => _RegisterLoginPageState();
}

double width;

class _RegisterLoginPageState extends State<RegisterLoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
  String _degree = 'hight school';
  String _college = 'not selected';
  String _university = 'not selected';
  String _oldUniversity = 'not selected';
  bool _checkedTrueInfo = false;

  bool _isRegister = true;
  bool logInWaiting = false;
  bool singUpWaiting = false;
  bool isMain = true;

  String logInErrorMessage = "";
  String signUpErrorMessage = "";

  Future<bool> _onBackPressed() async {
    if (!isMain)
      setState(() {
        isMain = true;
      });
    else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: isMain
            ? _main()
            : SingleChildScrollView(
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
        return Expanded(child: _universityCollegeBuilder());
      case 'master':
        return Expanded(child: _masterBuilder());
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
              Languages.translate(
                context,
                'welcome_back',
              ),
              style: TextStyle(
                fontSize: width / ConstValues.fontSize_1,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              Languages.translate(
                context,
                'login_statment',
              ),
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
              enableSuggestions: true,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                icon: Icon(Icons.email_outlined),
                labelText: Languages.translate(
                  context,
                  'email',
                ),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return Languages.translate(
                    context,
                    'email_is_Requered',
                  );
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
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_open),
                labelText: Languages.translate(
                  context,
                  'password',
                ),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return Languages.translate(
                    context,
                    'password_is_Requered',
                  );
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
                  Languages.translate(
                    context,
                    'forgut_password',
                  ),
                  style: TextStyle(
                    color: Color.fromARGB(150, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            logInErrorMessage == ""
                ? Container()
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    color: Color(0xFFff0033),
                    child: Text(
                      logInErrorMessage,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
            RaisedButton(
              color: ConstValues.firstColor,
              onPressed: () async {
                print("_formKey.currentState ");
                print(_formKey.currentState.validate());
                if (_formKey.currentState.validate()) {
                  setState(() {
                    logInWaiting = true;
                  });
                  try {
                    await _authController.login(
                        _emailController.text, _passwordController.text);
                  } on Exception catch (e) {
                    print("errr");
                    print(e);
                    setState(() {
                      logInErrorMessage = e.toString();
                    });
                  }
                }
                setState(() {
                  logInWaiting = false;
                });
                },
              child: !logInWaiting
                  ? Text(
                Languages.translate(
                  context,
                  'login',
                ),
                style: TextStyle(
                  fontSize: width / ConstValues.fontSize_2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                      )
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
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Languages.translate(
                    context,
                    'dont_have_account',
                  ),
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
                    Languages.translate(
                      context,
                      'create_account',
                    ),
                    style: TextStyle(
                      color: ConstValues.firstColor,
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
                Languages.translate(
                  context,
                  'signup_statment',
                ),
                style: TextStyle(
                  fontSize: width / ConstValues.fontSize_1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                Languages.translate(
                  context,
                  'signup_statment1',
                ),
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
                enableSuggestions: true,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  icon: Icon(Icons.person_outline),
                  labelText: Languages.translate(
                    context,
                    'first_name',
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
                height: 20,
              ),
              TextFormField(
                controller: _secondNameController,
                textInputAction: TextInputAction.next,
                enableSuggestions: true,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: Languages.translate(
                    context,
                    'second_name',
                  ),
                  icon: Icon(Icons.person_outline),
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
                          activeColor: ConstValues.firstColor,
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
                          Languages.translate(
                            context,
                            'male',
                          ),
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: ConstValues.firstColor,
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
                          Languages.translate(
                            context,
                            'female',
                          ),
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
                //TODO: Add translation
                //TODO 'hight school' is incorrect
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
                label: Languages.translate(
                  context,
                  'degree',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                child:
                _degreeInfoBuild(),

              ),
              TextFormField(
                controller: _emailController,
                enableSuggestions: true,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  icon: Icon(Icons.email_outlined),
                  labelText: Languages.translate(
                    context,
                    'email',
                  ),
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return Languages.translate(
                      context,
                      'email_is_Requered',
                    );
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
                obscureText: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock_open),
                  labelText: Languages.translate(
                    context,
                    'password',
                  ),
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return Languages.translate(
                      context,
                      'password_is_Requered',
                    );
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
                obscureText: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock_open),
                  labelText: Languages.translate(
                    context,
                    'confirm_password',
                  ),
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return Languages.translate(
                      context,
                      'field_requered',
                    );
                  } else if (value != _passwordController.text)
                    return Languages.translate(
                      context,
                      'wrong_password',
                    );
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              CheckboxListTile(
                activeColor: ConstValues.firstColor,
                contentPadding: EdgeInsets.zero,
                title: Text(Languages.translate(
                  context,
                  'info_true',
                )),
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
              signUpErrorMessage == "" ? Container() : Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.symmetric(vertical: 10),
                color: Color(0xFFff0033),
                child: Text(signUpErrorMessage,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,),
              ),
              RaisedButton(
                color: ConstValues.firstColor,
                onPressed: () async {
                  print("_degree " + _degree);
                  print("_college " + _college);
                  print("_university " + _university);
                  print(_degree != 'hight school'
                      && (_college == 'not selected'
                          || _university == 'not selected'));
                  if (_degree != 'hight school'
                      && (_college == 'not selected'
                          || _university == 'not selected')
                  ) {
                    Toast.show(
                        Languages.translate(context, "Please_Chose_degree"),
                        context,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        duration: Toast.LENGTH_LONG,
                        gravity: Toast.CENTER);
                    return;
                  }
                  setState(() {
                    singUpWaiting = true;
                  });
                  if (_formKey.currentState.validate() &&
                      _checkedTrueInfo == true) {
                    try {
                      List groups = setGroups();
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
                            oldUniversity: _oldUniversity,
                            groups: groups,
                            points: 10,
                            enterCount: 0,
                            bio: 'Hey There.. I\'m a New User.',
                            recordDate: DateTime.now(),
                            email: _emailController.text,
                            userTag: 'new_user'
                        ),
                      );
                    } catch (e) {
                      setState(() {
                        print(e.toString());
                        signUpErrorMessage = e.toString();
                      });
                    }
                  }
                  setState(() {
                    singUpWaiting = false;
                  });
                },
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: !singUpWaiting
                    ? Text(
                  Languages.translate(
                    context,
                    'create_account',
                  ),
                  style: TextStyle(
                    fontSize: width / ConstValues.fontSize_2,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                      )
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
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Languages.translate(
                      context,
                      'have_account',
                    ),
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
                      Languages.translate(
                        context,
                        'login',
                      ),
                      style: TextStyle(
                        color: ConstValues.firstColor,
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

  _main() => Container(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/launchImage.png",
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              bottom: 75,
              right: 0,
              left: 0,
              child: Column(
                children: [
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        isMain = false;
                        _isRegister = false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: 200,
                      height: 60,
                      child: Center(
                        child: Text(
                          Languages.translate(
                            context,
                            'login',
                          ),
                          style: TextStyle(
                            color: ConstValues.firstColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        isMain = false;
                        _isRegister = true;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: 200,
                      height: 60,
                      child: Center(
                        child: Text(
                          Languages.translate(
                            context,
                            'create_account',
                          ),
                          style: TextStyle(
                              color: ConstValues.firstColor,
                              fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  _universityCollegeBuilder() {
    return Column(
      children: [
        ListTile(
          onTap: () {
            _bottomSheetBuild(
              'universities',
              _authController.getUniversities(),
            );
          },
          contentPadding: EdgeInsets.zero,
          title: Text(Languages.translate(
            context,
            'university',
          )),
          subtitle: Text(_university == null
              ? Languages.translate(
                  context,
                  'tap_to_select',
                )
              : _university),
          leading: Icon(Icons.account_balance_outlined),
        ),
        SizedBox(
          height: 20,
        ),
        ListTile(
          onTap: () {
            _bottomSheetBuild(
              'colleges',
              _authController.getColleges(),
            );
          },
          contentPadding: EdgeInsets.zero,
          title: Text(Languages.translate(
            context,
            'college',
          )),
          subtitle: Text(_college == null
              ? Languages.translate(
                  context,
                  'tap_to_select',
                )
              : _college),
          leading: Icon(Icons.account_balance_outlined),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _bottomSheetBuild(
    String type,
    Future future,
  ) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
//        isScrollControlled: true,
        builder: (BuildContext context) {
          String temp;
          if (type == 'old')
            temp = 'universities';
          else
            temp = type;
          return FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data.data());
                return ListView.builder(
                  itemCount: snapshot.data.data()[temp].length,
                  itemBuilder: (context, index) {
                    String item = snapshot.data.data()[temp][index];
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          if (type == 'colleges')
                            _college = item;
                          else if (type == 'old')
                            _oldUniversity = item;
                          else
                            _university = item;
                        });
                        Navigator.pop(context, item);
                      },
                    );
                  },
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          );
        });
  }

  _masterBuilder() {
    return Column(
      children: [
        _universityCollegeBuilder(),
        ListTile(
          onTap: () {
            _bottomSheetBuild(
              'old',
              _authController.getUniversities(),
            );
          },
          contentPadding: EdgeInsets.zero,
          title: Text(Languages.translate(
            context,
            'old_university',
          )),
          subtitle: Text(_oldUniversity == null
              ? Languages.translate(
            context,
            'tap_to_select',
          )
              : _oldUniversity),
          leading: Icon(Icons.account_balance_outlined),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  List setGroups() {
    List g = [];

    switch (_degree) {
      case 'college':
      case 'graduate':
        g.addAll([
          _university + '|' + _college,
          _college,
          'Graduates And Masters',
          Group.TYPE_MOFADALAH,
        ]);
        break;
      case 'high school':
        g.addAll([
          Group.TYPE_MOFADALAH,
        ]);
        break;
      case 'master':
        g.addAll([
          _university + '|' + _college,
          _college,
          _oldUniversity + '|' + _college,
          'Graduates And Masters',
          Group.TYPE_MOFADALAH,
        ]);
        break;
    }

    return g;
  }
}
