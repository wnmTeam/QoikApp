import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void logOut() {
    _firebaseAuth.signOut();
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

  Future<void> recordUserInfo(user) {
    return _firestore.collection("users").doc(getUser.uid).set(user.toMap());
  }

  getUserInfo() async{
    DocumentSnapshot d = await _firestore.collection('users').doc(getUser.uid).get();
    print(d.data());
    return d.data();
  }
}
