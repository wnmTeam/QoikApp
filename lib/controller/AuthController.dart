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
  GroupsController _groupsController = GroupsController();
  StorageController _storageController = StorageController();

  get authStream => api.userChangesStream;

  get getUser => api.getUser;

  Future createAccount(email, password, User user) async {
    await api.signUp(
      email,
      password,
    );
    await _storageController.setPassword(password);

    await api.recordUserInfo(user);

    await _groupsController.addMemberToGroup(
      uid: getUser.uid,
      id_group: user.university,
      type: 'university',
    );
    print('un');
    await _groupsController.addMemberToGroup(
      uid: getUser.uid,
      id_group: user.college,
      type: 'college',
    );
  }

  login(String email, String password) async {
    await api.signIn(email, password);
    await _storageController.setPassword(password);
  }

  void logOut() {
    api.logOut();
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

  Future addPoint({String id_user}) => api.addPoint(id_user: id_user);

  Future updateUserTag(User user) {
    switch (user.tag) {
      case User.TAG_NEW_USER:
        if (DateTime.now().difference(user.recordDate).inDays > 6)
          return api.updateUserTag(user: user, tag: User.TAG_NORMAL_USER);
        break;

      case User.TAG_NORMAL_USER:
        if (DateTime.now().difference(user.recordDate).inDays > 89 &&
            DateTime.now().difference(user.recordDate).inDays /
                    user.enterCount >
                90 / 60)
          return api.updateUserTag(user: user, tag: User.TAG_ACTIVE_USER);
        break;
      case User.TAG_ACTIVE_USER:
        if (user.points > 100)
          return api.updateUserTag(user: user, tag: User.TAG_EX_USER);
        break;
      case User.TAG_EX_USER:
        break;
    }
  }

  setImageUrl({String id_user, String url}) {
    return api.setImageUrl(id_user: id_user, url: url);
  }

  void updateBio(String text) {
    api.updateBio(text);
  }

  updatePassword(String text) {
    return api.updatePassword(text);
  }

  Future getUniversities() {
    return api.getUniversities();
  }

  Future getColleges() {
    return api.getColleges();
  }

  deletePoint({String id_user}) {
    return api.deletePoint(id_user: id_user);
  }
}
