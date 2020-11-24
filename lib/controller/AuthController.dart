import 'dart:async';
import '../api/auth.dart';

class Controller {
  StreamController _streamController = StreamController();

  Sink get _out => _streamController.sink;

  Stream<int> get _in => _streamController.stream;

  Auth api = Auth();

  Future<String> createAccount(username, email, password) {
    return api.signUp(
      username,
      email,
      password,
    );
  }
}
