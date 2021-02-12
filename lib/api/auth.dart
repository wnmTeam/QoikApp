import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';

class Auth {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get userChangesStream => _firebaseAuth.authStateChanges();

  auth.User get getUser => _firebaseAuth.currentUser;

  Future<String> signUp(String email, String password) async {
    auth.UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    auth.User user = userCredential.user;
    try {
      await user.sendEmailVerification();
      return user.uid;
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
    }
  }

  logOut() {
    return _firebaseAuth.signOut();
  }

  sendEmailVerification() {
    auth.User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  Stream<auth.User> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().where((user) => user.emailVerified);
  }

  isUserVerified() => _firebaseAuth.currentUser.emailVerified;

  reloadUser() => _firebaseAuth.currentUser.reload();

  Future<String> signIn(String email, String password) async {
    auth.UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user.uid;
  }

  Future<void> sendPasswordResetMail(email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
    return null;
  }

  void createRecord(User user) async {
    await _firestore.collection("users").doc(getUser.uid).set(user.toMap());
  }

  Future<void> recordUserInfo(User user) {
    print(getUser.uid);
    print(user.toMap());
    return _firestore.collection("users").doc(getUser.uid).set(user.toMap());
  }

  getUserInfo(String id) {
    return _firestore.collection('users').doc(id).get();
  }

  getUsers({List<String> cases, int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('users')
          .orderBy('firstName', descending: true)
          .startAt([cases.last])
          .endAt([cases.first])
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('users')
        .orderBy('firstName', descending: true)
        .startAt([cases.last])
        .endAt([cases.first])
        .limit(limit)
        .get();
  }

  addPoint({String id_user}) {
    return _firestore.collection('users').doc(id_user).set(
      {'points': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  Future updateUserTag({User user, String tag}) {
    return _firestore
        .collection('users')
        .doc(user.id)
        .set({'tag': tag}, SetOptions(merge: true));
  }

  setImageUrl({String id_user, String url}) {
    return _firestore
        .collection('users')
        .doc(id_user)
        .set({'img': url}, SetOptions(merge: true));
  }

  void updateBio(String text) {
    _firestore
        .collection('users')
        .doc(getUser.uid)
        .set({'bio': text}, SetOptions(merge: true));
  }

  updatePassword(String text) {
    return getUser.updatePassword(text);
  }

  Future getUniversities() {
    return _firestore.collection('appInfo').doc('universities').get();
  }

  Future getColleges() {
    return _firestore.collection('appInfo').doc('colleges').get();
  }

  deletePoint({String id_user}) {
    return _firestore.collection('users').doc(id_user).set(
      {'points': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
  }

  recordEnter() {
    return _firestore.collection('users').doc(getUser.uid).set(
      {
        'enterCount': FieldValue.increment(1),
      },
      SetOptions(merge: true),
    );
  }

  search({
    String text,
    int limit,
    last,
    String gender,
    String college,
    String university,
  }) {
    Query q = _firestore.collection('users');

    if (gender != null) q = q.where('gender', isEqualTo: gender);

    if (university != null) q = q.where('university', isEqualTo: university);

    if (college != null) q = q.where('college', isEqualTo: college);

    q = q.orderBy('fullName').startAt([text]).endAt([text + '\uf8ff']);

    if (last != null) return q.startAfterDocument(last).limit(limit).get();

    return q.limit(limit).get();
  }

  bool isBan() {
    if (MyUser.myUser.ban == null) return false;

    DateTime now = DateTime.now();
//    DateTime def = now.subtract(now.difference(MyUser.myUser.ban));
    Duration d = MyUser.myUser.ban.add(Duration(hours: 24)).difference(now);
    print(
        'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
    print(d);
    if (d.isNegative) {
      return false;
    }
    return true;
  }

  getLastVersion() {
    return _firestore.collection('appInfo').doc('version').get();
  }

  getLinks() {
    return _firestore.collection('appInfo').doc('links').get();
  }
}
