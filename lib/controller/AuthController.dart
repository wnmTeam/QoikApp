import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
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

  Future createAccount(email, password, User user) async {
    await  api.signUp(
      email,
      password,
    );
      print(user.toMap());
      await api.recordUserInfo(user);
      await _storage.setUser(user);

      await _groupsController.addMemberToGroup(
        uids: [getUser.uid],
        id_group: user.university,
      );
      print('un');
      await _groupsController.addMemberToGroup(
        uids: [getUser.uid],
        id_group: user.college,
      );


  }

  login(String email, String password) async {
    await api.signIn(email, password);
    User user = User();
    user.fromMap(await api.getUserInfo(api.getUser.uid));

    return _storage.setUser(user);
  }

  void logOut() {
    api.logOut();
    _storage.deleteUser();
  }

  bool isUserVerified() => api.isUserVerified();

  sendEmailVerification() => api.sendEmailVerification();

  Future<void> reloadUser() => api.reloadUser();

  resetPassword(email) => api.sendPasswordResetMail(email);

  getUserInfo(String id) => api.getUserInfo(id);

  getUsers({List<String> cases, int limit, DocumentSnapshot last}) =>
      api.getUsers(
        cases: cases,
        limit: limit,
        last: last,
      );
}
