import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Notification.dart';

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

  sendNotification(
    Notification notification,
    String type,
  ) {
    Map m = notification.toMap();
    m[Notification.DATE] = FieldValue.serverTimestamp();

    WriteBatch batch = _firestore.batch();

    if (notification.type != 'chats' && notification.type != 'rooms')
      batch.set(
        _firestore
            .collection('notificationsCount')
            .doc(notification.idReceiver),
        {'count': FieldValue.increment(1)},
      );

    batch.set(_firestore.collection(type).doc(), m);

    return batch.commit();
  }

  getNotifications({int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('notifications')
          .where(Notification.ID_RECEIVER, isEqualTo: MyUser.myUser.id)
          .orderBy(Notification.DATE, descending: true)
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('notifications')
        .where(Notification.ID_RECEIVER, isEqualTo: MyUser.myUser.id)
        .orderBy(Notification.DATE, descending: true)
        .limit(limit)
        .get();
  }

  Stream getUnreadNotificationsCount({String id_user}) {
    return _firestore.collection('notificationsCount').doc(id_user).snapshots();
  }

  Future resetNotificationsCount({String id_user}) {
    return _firestore
        .collection('notificationsCount')
        .doc(id_user)
        .set({'count': 0});
  }
}
