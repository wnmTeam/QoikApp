import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationApi {
  final FirebaseMessaging fbm = FirebaseMessaging();

  requestNotificationPermissions() async {
    fbm.requestNotificationPermissions();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    String t = await fbm.getToken();
    print(t);
  }
}
