import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart' as appUser;
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/localization.dart';
// import 'package:toast/toast.dart';

import 'Widgets.dart';

class RegisterLoginPage extends StatefulWidget {
  @override
  _RegisterLoginPageState createState() => _RegisterLoginPageState();
}

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

  double width;

  int _value = 1;
  String _gender = 'male';
  String _degree;
  String _college;
  String _university;
  String _oldUniversity;
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

    return Scaffold(
      key: scaffoldKey,
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: isMain
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
        return _universityCollegeBuilder();
      case 'master':
        return _masterBuilder();
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
          color: Theme
              .of(context)
              .errorColor,
          child: Text(
            Languages.translate(
              context,
              logInErrorMessage,
            ),
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 30,
        ),
        RaisedButton(
          color: Theme
              .of(context)
              .primaryColor,
          textColor: Colors.white,
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
              } on FirebaseAuthException catch (e) {
                print("errr");
                print(e.message);
                setState(() {
                  logInErrorMessage = e.message;
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
                  child: CircularProgressIndicator()),
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
        SizedBox(
          height: 20,
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
                  color: Theme
                      .of(context)
                      .primaryColor,
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
                      activeColor: Theme
                          .of(context)
                          .primaryColor,
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
                      activeColor: Theme
                          .of(context)
                          .primaryColor,
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
            items: [
              Languages.translate(
                context,
                'high school',
              ),
              Languages.translate(
                context,
                'college',
              ),
              Languages.translate(
                context,
                'master',
              ),
              Languages.translate(
                context,
                'graduate',
              ),
            ],
            onSelected: (_selected) {
              setState(() {
                if (_selected ==
                    Languages.translate(
                      context,
                      'high school',
                    ))
                  _degree = 'high school';
                else if (_selected ==
                    Languages.translate(
                      context,
                      'college',
                    ))
                  _degree = 'college';
                else if (_selected ==
                    Languages.translate(
                      context,
                      'master',
                    ))
                  _degree = 'master';
                else if (_selected ==
                    Languages.translate(
                      context,
                      'graduate',
                    )) _degree = 'graduate';
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
//              SizedBox(
//                width: width,
//                child:
          _degreeInfoBuild(),
//              ),
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
            activeColor: Theme
                .of(context)
                .primaryColor,
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
          signUpErrorMessage == ""
              ? Container()
              : Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            margin: EdgeInsets.symmetric(vertical: 10),
            color: Theme
                .of(context)
                .errorColor,
            child: Text(
              Languages.translate(
                context,
                signUpErrorMessage,
              ),
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          RaisedButton(
            color: Theme
                .of(context)
                .primaryColor,
            textColor: Colors.white,
            onPressed: () async {
              if (!_formKey.currentState.validate()) {
                return;
              }

              if ((_degree == null) ||
                  (_degree != 'high school' &&
                      (_college == null || _university == null))) {
                // TODO

                // Toast.show(
                //     Languages.translate(context, "Please_Chose_degree"),
                //     context,
                //     backgroundColor: Theme
                //         .of(context)
                //         .errorColor,
                //     duration: Toast.LENGTH_LONG,
                //     gravity: Toast.CENTER);
                return;
              }
              setState(() {
                singUpWaiting = true;
              });
              if (/*_formKey.currentState.validate() &&*/
              _checkedTrueInfo == true) {
                try {
                  List groups = setGroups();
                  await _authController.createAccount(
                    _emailController.text,
                    _passwordController.text,
                    appUser.User(
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
                        userTag: 'new_user'),
                  );
                } on FirebaseAuthException catch(e) {
                  setState(() {
                    print(e.message);
                    signUpErrorMessage = e.message;
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
                    child: CircularProgressIndicator()),
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
                    color: Theme
                        .of(context)
                        .primaryColor,
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

  _main() =>
      Container(
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
                            color: Theme
                                .of(context)
                                .primaryColor,
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
                            color: Theme
                                .of(context)
                                .primaryColor,
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

  _bottomSheetBuild(String type,
      Future future,) {
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

                List list = snapshot.data.data()[temp];
                list.sort();

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    String item = list[index];
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
          _university + '.' + _college,
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
          _university + '.' + _college,
          _college,
          _oldUniversity + '.' + _college,
          'Graduates And Masters',
          Group.TYPE_MOFADALAH,
        ]);
        break;
    }

    return g;
  }
}
