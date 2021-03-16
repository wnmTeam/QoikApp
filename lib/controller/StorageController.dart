import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as str;
import 'package:image_picker/image_picker.dart';
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
    return;
  }

  String getString(String name) {
    return prefs.getString(name);
  }

  Future<bool> setString(String name, String value) async {
    return prefs.setString(name, value);
  }

  Future setUser(User user) async {
    await setString('user.' + User.FIRST_NAME, user.firstName);
    await setString('user.' + User.SECOND_NAME, user.secondName);
    await setString('user.' + User.GENDER, user.gender);
    await setString('user.' + User.DEGREE, user.degree);
    await setString('user.' + User.UNIVERSITY, user.university);
    await setString('user.' + User.COLLEGE, user.college);
    return prefs.setInt('user.' + User.POINTS, user.points);
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
      points: prefs.getInt('user.' + User.POINTS),
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
    await prefs.remove('user.' + User.POINTS);
  }

  Future getImage() {
    return ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
  }

  Future getImageFromCamera() {
    return ImagePicker().getImage(source: ImageSource.camera, imageQuality: 50);
  }

  Future<File> getDoc() async {
    // File x = await FilePicker.getFile();
    return await FilePicker.getFile();

//    if(result != null) {
//      PlatformFile file = result.files.first;
//
//      print(file.name);
//      print(file.bytes);
//      print(file.size);
//      print(file.extension);
//      print(file.path);
//    } else {
//      // User canceled the picker
//    }
  }

  Future<List<File>> getDocs() async {
    return await FilePicker.getMultiFile();
  }

  Future uploadPic(context, img, id_user) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child('profileImages')
        .child(id_user);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(img);
    str.TaskSnapshot taskSnapshot = await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  uploadPostImage({
    String id_post,
    String nom,
    File img,
    String id_group,
  }) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child('postImages')
        .child(id_group + id_post + nom);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(img);
    await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  uploadPostFile({
    String id_post,
    String nom,
    File file,
    String id_group,
  }) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child('postFiles')
        .child(id_group + id_post + nom);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(file);
    await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  uploadCommentImage({
    String id_post,
    String nom,
    File img,
    String id_group,
  }) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child('commentImages')
        .child(id_group + id_post + nom);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(img);
    await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  uploadCommentFile({
    String id_post,
    String nom,
    File file,
    String id_group,
  }) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child('commentFiles')
        .child(id_group + id_post + nom);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(file);
    await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  uploadRoomImage({
    File img,
    String id_room,
  }) async {
    String url;
    str.Reference firebaseStorageRef =
        str.FirebaseStorage.instance.ref().child('roomImages').child(id_room);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(img);
    await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  uploadMessageImage(
      {String id_message,
      String nom,
      File img,
      String type,
      String id_group}) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child(type + 'Images')
        .child(id_group + id_message + nom);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(img);
    await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  uploadMessageDoc({
    String id_message,
    File doc,
    String type,
    String id_group,
  }) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child(type + 'Docs')
        .child(id_group + id_message);
    str.UploadTask uploadTask = firebaseStorageRef.putFile(doc);
    await uploadTask.then((res) async {
      url = await res.ref.getDownloadURL();
      return;
    });
    return url;
  }

  String getUserPassword() {
    return prefs.getString('password');
  }

  setPassword(String password) {
    return prefs.setString('password', password);
  }

  String getLang() {
    try {
      String lang = prefs.getString('lang');
      return lang;
    } catch (e) {
      return 'en';
    }
  }

  setLang(String lang) {
    return prefs.setString('lang', lang);
  }

  String getTheme() {
    try {
      String theme = prefs.getString('theme');
      return theme;
    } catch (e) {
      return 'light';
    }
  }

  setTheme(String theme) {
    return prefs.setString('theme', theme);
  }

  // setOneNotificationSetting(String notificationType, bool value) {
  //   prefs.setBool(notificationType, value);
  // }
  //
  // getOneNotificationSetting(String notificationType) {
  //   return prefs.getBool(notificationType);
  // }

  getAllNotificationSetting() {
    List<bool> n = new List<bool>();
    try {
      n.insert(0, prefs.getBool("chat&roomsNotif"));
      n[0] = n[0] == null ? true : n[0];
    } catch (e, s) {
      n.insert(0, true);
    }
    try {
      n.insert(1, prefs.getBool("groupsNotif"));
      n[1] = n[1] == null ? true : n[1];
    } catch (e, s) {
      n.insert(1, true);
    }
    try {
      n.insert(2, prefs.getBool("homeNotif"));
      n[2] = n[2] == null ? true : n[2];
    } catch (e, s) {
      n.insert(2, true);
    }

    print(n);
    return n;
  }

//  void setGroup(Group group) {
//    prefs.setString('groupName.', value)
//  }
}
