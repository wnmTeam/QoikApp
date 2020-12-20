import 'dart:async';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/GroupsController.dart';
import 'package:stumeapp/controller/StorageController.dart';

import '../api/auth.dart';

class AuthController {
  StreamController _streamController = StreamController();

  Sink get _out => _streamController.sink;

  Stream<int> get _in => _streamController.stream;

  Auth api = Auth();
  StorageController _storage = StorageController();
  GroupsController _groupsController = GroupsController();

  get authStream => api.userChangesStream;

  get getUser => api.getUser;

  Future<String> createAccount(email, password, user) {
    return api
        .signUp(
      email,
      password,
    )
        .whenComplete(() {
      api.recordUserInfo(user);
      _storage.setUser(user);

    }).whenComplete(() {
      _groupsController.addMemberToUniversity(uid: getUser.uid, university: user.university, user: user);
    }).whenComplete(() {
      _groupsController.addMemberToCollege(uid: getUser.uid, college: user.college);
    });
  }

  login(String email, String password) async {
    await api.signIn(email, password);
    User user = User();
    user.fromMap(await api.getUserInfo());

    _storage.setUser(user);
  }

  void logOut() {
    api.logOut();
    _storage.deleteUser();
  }

  bool isUserVerified() => api.isUserVerified();

  sendEmailVerification() => api.sendEmailVerification();

  Future<void> reloadUser() => api.reloadUser();

  resetPassword(email) => api.sendPasswordResetMail(email);
}
