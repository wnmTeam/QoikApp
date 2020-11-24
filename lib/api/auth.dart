import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class Auth{

  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  Future<String> signUp(String username, String email, String password) async {
    auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    auth.User user = userCredential.user;
    try {
      await user.sendEmailVerification();
      return user.uid;
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
    }
  }
}