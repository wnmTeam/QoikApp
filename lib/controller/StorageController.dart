import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';

class StorageController {
  static SharedPreferences prefs;
  static User _user;

  StorageController() {
    createPreferences();
  }

  createPreferences() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
  }

  String getString(String name) {
    return prefs.getString(name);
  }

  Future<bool> setString(String name, String value) async {
    return prefs.setString(name, value);
  }

  void setUser(User user) async {
//    _user = User(
//      firstName: user.firstName,
//      secondName: user.secondName,
//      gender: user.gender,
//      degree: user.degree,
//      university: user.university,
//      college: user.college,
//    );

    await setString('user.' + User.FIRST_NAME, user.firstName);
    await setString('user.' + User.SECOND_NAME, user.secondName);
    await setString('user.' + User.GENDER, user.gender);
    await setString('user.' + User.DEGREE, user.degree);
    await setString('user.' + User.UNIVERSITY, user.university);
    await setString('user.' + User.COLLEGE, user.college);
    log('done', name: 'storage', level: 1);
    log(getUser().toMap().toString(), name: 'get user');
  }

  User getUser() {
    if (_user != null) return _user;
    _user = User(
      firstName: prefs.getString('user.' + User.FIRST_NAME),
      secondName: prefs.getString('user.' + User.SECOND_NAME),
      gender: prefs.getString('user.' + User.GENDER),
      degree: prefs.getString('user.' + User.DEGREE),
      university: prefs.getString('user.' + User.UNIVERSITY),
      college: prefs.getString('user.' + User.COLLEGE),
    );
    return _user;
  }

  Group getGroup(String group) {
    return Group(
      name: prefs.getString('groupName.' + group),
    );
  }

  void deleteUser() async {
    await prefs.remove('user.' + User.FIRST_NAME);
    await prefs.remove('user.' + User.SECOND_NAME);
    await prefs.remove('user.' + User.GENDER);
    await prefs.remove('user.' + User.DEGREE);
    await prefs.remove('user.' + User.UNIVERSITY);
    await prefs.remove('user.' + User.COLLEGE);
  }

//  void setGroup(Group group) {
//    prefs.setString('groupName.', value)
//  }
}
