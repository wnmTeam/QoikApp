import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationApi {
  final FirebaseMessaging fbm = FirebaseMessaging();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  }

  saveDeviceToken(uid) async {
    // Get the token for this device
    String fcmToken = await fbm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = _firestore
          .collection('users')
          .doc(uid)
          .collection('tokens')
          .doc(Platform.operatingSystem);

      return tokens.set({
        'token': fcmToken,
      });
    }
  }

  removeDeviceToken(uid) {
    var tokens = _firestore
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .doc(Platform.operatingSystem);

    return tokens.delete();
  }
}
