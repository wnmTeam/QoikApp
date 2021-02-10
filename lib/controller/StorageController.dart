import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as str;
import 'package:file_picker/file_picker.dart';
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
    return ImagePicker().getImage(source: ImageSource.gallery);
  }

  Future getImageFromCamera() {
    return ImagePicker().getImage(source: ImageSource.camera);
  }

  Future getDoc() async {
    var v = await FilePicker.getFile();

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

  uploadRoomImage({
    File img,
    String id_room,
  }) async {
    String url;
    str.Reference firebaseStorageRef = str.FirebaseStorage.instance
        .ref()
        .child('roomImages')
        .child(id_room);
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
      return prefs.getString('lang');
    } catch (e) {
      return 'en';
    }
  }

  setLang(String lang) {
    return prefs.setString('lang', lang);
  }

//  void setGroup(Group group) {
//    prefs.setString('groupName.', value)
//  }
}
