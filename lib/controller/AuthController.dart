import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
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

  NotificationApi _notificationApi = NotificationApi();

  get authStream => api.userChangesStream;

  get getUser => api.getUser;

  Future createAccount(email, password, User user) async {
    await api.signUp(
      email,
      password,
    );
    await _storageController.setPassword(password);

    await api.recordUserInfo(user);
    await _notificationApi.saveDeviceToken(getUser.uid);
    if (user.college != null) {
      await _groupsController.addMemberToGroup(
        uid: getUser.uid,
        id_group: user.groups[0],
        name: user.university,
        type: 'university',
      );
      print('un');
      await _groupsController.addMemberToGroup(
        uid: getUser.uid,
        name: user.college,
        id_group: user.groups[1],
        type: 'college',
      );
      print('coll');
    }

    if (user.oldUniversity != null) {
      await _groupsController.addMemberToGroup(
        uid: getUser.uid,
        id_group: user.groups[2],
        name: user.oldUniversity,
        type: 'university',
      );
      print('old un');
    }

    await _groupsController.addMemberToGroup(
      uid: getUser.uid,
      id_group: Group.TYPE_MOFADALAH,
      type: Group.TYPE_MOFADALAH,
    );
    if (user.degree != 'hight school')
      await _groupsController.addMemberToGroup(
        uid: getUser.uid,
        id_group: 'Graduates And Masters',
        type: 'G',
      );
    return;
  }

  Future updateUserUniversity(User user) async {
    await api.updateUserInfo(user);

    if (user.college != null) {
      await _groupsController.addMemberToGroup(
        uid: getUser.uid,
        id_group: user.groups[0],
        name: user.university,
        type: 'university',
      );
      print('un');
      await _groupsController.addMemberToGroup(
        uid: getUser.uid,
        name: user.college,
        id_group: user.groups[1],
        type: 'college',
      );
      print('coll');
    }
  }

  login(String email, String password) async {
    await api.signIn(email, password);
    await _notificationApi.saveDeviceToken(getUser.uid);
    await _storageController.setPassword(password);
  }

  void logOut() async {
    await _notificationApi.removeDeviceToken(getUser.uid);
    await api.logOut();
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

  search({
    String text,
    int limit,
    last,
    String gender,
    String college,
    String university,
  }) {
    return api.search(
      text: text.toLowerCase(),
      limit: limit,
      last: last,
      college: college,
      university: university,
      gender: gender,
    );
  }

  Future addPoint({String id_user}) => api.addPoint(id_user: id_user);

  Future updateUserTag(User user) {
    print(user.tag);
    switch (user.tag) {
      case User.TAG_NEW_USER:
        if (DateTime.now().difference(user.recordDate).inDays > 6)
          return api.updateUserTag(user: user, tag: User.TAG_NORMAL_USER);
        break;

      case User.TAG_NORMAL_USER:
        print('yyyyyyyyyyyyeeeeeeeeeeeeeessssssssssssssssss');
        print(user.enterCount);
        print(user.recordDate);
        print(DateTime.now().difference(user.recordDate).inDays);
        if (DateTime.now().difference(user.recordDate).inDays > 89 &&
            user.enterCount /
                    DateTime.now().difference(user.recordDate).inDays >
                60 / 90) {
          print('yyyyyyyyyyyyeeeeeeeeeeeeeessssssssssssssssss');
          return api.updateUserTag(user: user, tag: User.TAG_ACTIVE_USER);
        }
        break;
      case User.TAG_ACTIVE_USER:
        if (user.points > 100)
          return api.updateUserTag(user: user, tag: User.TAG_PREMIUM_USER);
        break;
      case User.TAG_PREMIUM_USER:
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

  recordEnter() {
    return api.recordEnter();
  }

  bool isBan() {
    return api.isBan();
  }

  getLastVersion() {
    return api.getLastVersion();
  }

  getStoreLink() {
    return api.getStoreLink();
  }

  getLinks() {
    return api.getLinks();
  }

  setAllNotificationSetting(Map<String, dynamic> map) {
    return api.setAllNotificationSetting(map);
  }

  getAllNotificationSetting() {
    Future<dynamic> d = api.getAllNotificationSetting();

    return d;
  }

  blockUser({String id_user}) {
    return api.blockUser(id_user: id_user);
  }

  isLibraryAdmin() {
    return MyUser.myUser.userTag == User.USER_TAG_ADMIN ||
        MyUser.myUser.userTag == User.USER_TAG_PREMIUM_ADMIN ||
        MyUser.myUser.userTag == User.USER_TAG_VERIFIED_ADMIN;
  }

  getTagedUsers({String text, String groupId, int limit}) {
    return api.getTagedUsers(text: text.toLowerCase(), groupId: groupId, limit: limit);
  }
}
