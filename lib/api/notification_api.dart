import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Notification.dart' as noti;
import 'package:stumeapp/Models/User.dart';

//import 'package:stumeapp/controller/AuthController.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  final FirebaseMessaging fbm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//  AuthController _authController = AuthController();

  requestNotificationPermissions(context) async {
    fbm.requestPermission();
    // TODO

//     FirebaseMessaging.configure(
//       onMessage: (msg) {
//         print(msg);
//         return;
//       },
//       onLaunch: (msg) {
//         print(msg);
//         String type = msg['data']['type'];
//         String id_sender = msg['data']['id_sender'];
//
//         switch (type) {
//           case 'chats':
// //            var d = _authController.getUserInfo(id_sender);
//
// //            Navigator.pushNamed(context, '/ChatRoomPage', arguments: {
// //              'group': null,
// //              'user': User().fromMap(d.data()),
// //            });
//             break;
//           case 'rooms':
//             break;
//           default:
//             Navigator.pushNamed(
//               context,
//               '/NotificationsPage',
//             );
//         }
//         return;
//       },
//       onResume: (msg) {
//         print(msg);
//         String type = msg['data']['type'];
//         String id_sender = msg['data']['id_sender'];
//
//         switch (type) {
//           case 'chats':
// //            var d = _authController.getUserInfo(id_sender);
//
// //            Navigator.pushNamed(context, '/ChatRoomPage', arguments: {
// //              'group': null,
// //              'user': User().fromMap(d.data())..setId(d.id),
// //            });
//             break;
//           case 'rooms':
//             break;
//           default:
//             Navigator.pushNamed(
//               context,
//               '/NotificationsPage',
//             );
//         }
//         return;
//       },
//     );
  }

//  requestNotificationPermissions(context) async {
//    fbm.requestNotificationPermissions();
//    fbm.configure(
//      onMessage: (msg) {
//        print(msg);
//        return;
//      },
//      onLaunch: (msg) {
//        print(msg);
//        String type = msg['data']['type'];
//        String id_sender = msg['data']['id_sender'];
//
//        switch (type) {
//          case 'chats':
//            var d = .getUserInfo(id_sender);
//
////            Navigator.pushNamed(context, '/ChatRoomPage', arguments: {
////              'group': null,
////              'user': User().fromMap(d.data()),
////            });
//            break;
//          case 'rooms':
//            break;
//          default:
//            Navigator.pushNamed(
//              context,
//              '/NotificationsPage',
//            );
//        }
//        return;
//      },
//      onResume: (msg) {
//        print(msg);
//        String type = msg['data']['type'];
//        String id_sender = msg['data']['id_sender'];
//
//        switch (type) {
//          case 'chats':
////            var d = _authController.getUserInfo(id_sender);
//
////            Navigator.pushNamed(context, '/ChatRoomPage', arguments: {
////              'group': null,
////              'user': User().fromMap(d.data())..setId(d.id),
////            });
//            break;
//          case 'rooms':
//            break;
//          default:
//            Navigator.pushNamed(
//              context,
//              '/NotificationsPage',
//            );
//        }
//        return;
//      },
//    );
//  }

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
    noti.Notification notification,
    String type, {
    String id_group,
    String id_post,
  }) {
    Map m = notification.toMap();
    m[noti.Notification.DATE] = FieldValue.serverTimestamp();
    print('MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM');
    print(m);
    WriteBatch batch = _firestore.batch();

    if (notification.type == 'chats') {
      batch.set(
        _firestore
            .collection('chatsNotificationsCount')
            .doc(notification.idReceiver)
            .collection('count')
            .doc(id_group),
        {'count': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
    } else if (notification.type == 'commentPost')
      ;

//    else if (notification.type == 'rooms')
//      batch.set(
//        _firestore
//            .collection('roomsNotificationsCount')
//            .doc(id_group)
//            .collection('count')
//            .doc(notification.idReceiver),
//        {'count': FieldValue.increment(1)},
//      );
    else
      batch.set(
        _firestore
            .collection('notificationsCount')
            .doc(notification.idReceiver),
        {'count': FieldValue.increment(1)},
        SetOptions(merge: true),
      );

    batch.set(_firestore.collection(type).doc(), m);

    return batch.commit();
  }

  getNotifications({int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('notifications')
          .where(noti.Notification.ID_RECEIVER, isEqualTo: MyUser.myUser.id)
          .orderBy(noti.Notification.DATE, descending: true)
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('notifications')
        .where(noti.Notification.ID_RECEIVER, isEqualTo: MyUser.myUser.id)
        .orderBy(noti.Notification.DATE, descending: true)
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

  void resetGroupNotificationsCount(
      {String id_user, String id_group, String type}) {
    _firestore
        .collection(type)
        .doc(id_user)
        .collection('count')
        .doc(id_group)
        .set({'count': 0});
  }

  Stream getUnreadGroupNotificationsCount(
      {String id_user, String id_group, String type}) {
    return _firestore
        .collection(type)
        .doc(id_user)
        .collection('count')
        .doc(id_group)
        .snapshots();
  }

  Stream getUnreadGroupsNotificationsCount({String id_user, String type}) {
    return _firestore
        .collection(type)
        .doc(id_user)
        .collection('count')
        .where('count', isGreaterThan: 0)
        .snapshots();
  }

  subscribeToTopic(String topic) {
    topic = _formatTopic(topic);

    print(topic);
    return fbm.subscribeToTopic(topic);
  }

  unsubscribeFromTopic(String topic) {
    topic = _formatTopic(topic);

    print(topic);

    return fbm.unsubscribeFromTopic(topic);
  }

  String _formatTopic(String topic) {
    print(topic);
    topic = topic.replaceAll(RegExp(" "), '.');
    topic = topic.replaceAll(RegExp("[ÜĞŞÇÖIüğışçö]"), '.');
    return topic;
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  sendMentionsNotifications(
      {List mentions, String idSender, String idGroup, String idPost}) {
    WriteBatch batch = _firestore.batch();
    for (Map mention in mentions) {
      batch.set(
        _firestore.collection('notifications').doc(),
        noti.Notification(
          type: 'mention_comment',
          idSender: idSender,
          idReceiver: mention['user_id'],
          idGroup: idGroup,
          idPost: idPost,
        ).toMap()
          ..['date'] = FieldValue.serverTimestamp(),
      );
      batch.set(
        _firestore.collection('notificationsCount').doc(mention['user_id']),
        {'count': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
    }

    return batch.commit();
  }
}
