import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Notification.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/controller/StorageController.dart';

class ChatsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StorageController _storageController = StorageController();
  NotificationApi _notificationsApi = NotificationApi();

  Future getMessages({
    int limit,
    DocumentSnapshot last,
    String id_chat,
    String type,
  }) {
    CollectionReference reference;

    reference = _firestore.collection(type).doc(id_chat).collection('messages');

    if (last == null) {
      return reference
          .orderBy(
            'date',
            descending: true,
          )
          .limit(limit)
          .get();
    } else {
      return reference
          .orderBy(
            'date',
            descending: true,
          )
          .startAfterDocument(last)
          .limit(limit)
          .get();
    }
  }

  Future addMessage({
    Message message,
    String id_chat,
    String id_receiver,
    String type,
    List<File> images,
    File doc,
  }) async {
    WriteBatch batch = _firestore.batch();

    Map m = message.toMap();
    m['date'] = FieldValue.serverTimestamp();

    await _firestore
        .collection(type)
        .doc(id_chat)
        .collection('messages')
        .add(m)
        .then((value) async {
      await updateLastActive(id_group: id_chat, type: type);
      for (int i = 0; i < images.length; i++) {
        String url = await _storageController.uploadMessageImage(
          type: type,
          id_group: id_chat,
          id_message: value.id,
          img: images[i],
          nom: i.toString(),
        );
        await addImageToMessage(
          type: type,
          id_group: id_chat,
          id_message: value.id,
          url: url,
        );
      }

      if (doc != null) {
        String url = await _storageController.uploadMessageDoc(
          type: type,
          id_group: id_chat,
          id_message: value.id,
          doc: doc,
        );
        await addDocToMessage(
          type: type,
          id_group: id_chat,
          id_message: value.id,
          url: url,
        );
      }
    });

    return _notificationsApi.sendNotification(
        Notification(
          idSender: MyUser.myUser.id,
          idReceiver: id_receiver,
          data: message.text,
          type: type,
        ),
        type == 'chats' ? 'chatsNotifications' : 'roomsNotifications');
  }

  Stream getNewMessages({
    String id_chat,
    last,
    String type,
  }) {
    if (last != null)
      return _firestore
          .collection(type)
          .doc(id_chat)
          .collection('messages')
          .orderBy('date')
          .startAfterDocument(last)
          .snapshots();

    return _firestore
        .collection(type)
        .doc(id_chat)
        .collection('messages')
        .orderBy('date')
        .snapshots();
  }

  getChats({String id_user, int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('chats')
          .where(Group.MEMBERS, arrayContains: id_user)
          .orderBy(Group.LAST_ACTIVE, descending: true)
//          .startAfterDocument(last)
//          .limit(limit)
          .snapshots();

    return _firestore
        .collection('chats')
        .where(Group.MEMBERS, arrayContains: id_user)
        .orderBy(Group.LAST_ACTIVE, descending: true)
//        .limit(limit)
        .snapshots();
  }

  Future createChat({Group group}) {
    Map m = group.toMap();
    m[Group.LAST_ACTIVE] = FieldValue.serverTimestamp();
    return _firestore.collection('chats').doc(group.id).set(m);
  }

  getRooms({id, DocumentSnapshot last, int limit}) {
    if (last != null)
      return _firestore
          .collection('rooms')
          .where(Group.MEMBERS, arrayContains: id)
          .orderBy(Group.LAST_ACTIVE, descending: true)
//          .startAfterDocument(last)
//          .limit(limit)
          .snapshots();

    return _firestore
        .collection('rooms')
        .where(Group.MEMBERS, arrayContains: id)
        .orderBy(Group.LAST_ACTIVE, descending: true)

//        .limit(limit)
        .snapshots();
  }

  getChat(chatId) {
    return _firestore.collection('chats').doc(chatId).get();
  }

  getRoom({String id}) {
    return _firestore.collection('rooms').doc(id).get();
  }

  addImageToMessage(
      {String type, String id_group, String id_message, String url}) {
    return _firestore
        .collection(type)
        .doc(id_group)
        .collection('messages')
        .doc(id_message)
        .set({
      'images': FieldValue.arrayUnion([url]),
    }, SetOptions(merge: true));
  }

  addDocToMessage(
      {String type, String id_group, String id_message, String url}) {
    return _firestore
        .collection(type)
        .doc(id_group)
        .collection('messages')
        .doc(id_message)
        .set({
      'doc': url,
    }, SetOptions(merge: true));
  }

  removeMemberFromRoom({String id_user, String id_room}) {
    _firestore.collection('rooms').doc(id_room).set({
      'members': FieldValue.arrayRemove([id_user]),
      'admins': FieldValue.arrayRemove([id_user]),
    }, SetOptions(merge: true));
  }

  setRoomImageUrl({String id_room, String url}) {
    return _firestore
        .collection('rooms')
        .doc(id_room)
        .set({'img': url}, SetOptions(merge: true));
  }

  updateLastActive({String id_group, String type}) {
    return _firestore.collection(type).doc(id_group).set(
      {Group.LAST_ACTIVE: FieldValue.serverTimestamp()},
      SetOptions(
        merge: true,
      ),
    );
  }
}
