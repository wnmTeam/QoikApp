import 'dart:async';
import 'package:stumeapp/Models/User.dart';

import '../api/auth.dart';

class AuthController {
  StreamController _streamController = StreamController();

  Sink get _out => _streamController.sink;

  Stream<int> get _in => _streamController.stream;

  Auth api = Auth();

  get authStream => api.userChangesStream;

  get getUser => api.getUser;

  Future<String> createAccount(email, password, user) {
    return api.signUp(
      email,
      password,
    ).whenComplete(() => api.recordUserInfo(user));
  }

  void logOut() {
    api.logOut();
  }

  bool isUserVerified() => api.isUserVerified();

  sendEmailVerification() => api.sendEmailVerification();

  Future<void> reloadUser() => api.reloadUser();

  login(String email, String password) async{
    await api.signIn(email, password);
    User user = User();
    user.fromMap(api.getUserInfo());
  }



  resetPassword(email) => api.sendPasswordResetMail(email);
}
