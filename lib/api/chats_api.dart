import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/controller/StorageController.dart';

class ChatsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StorageController _storageController = StorageController();

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
    String type,
    List<File> images,
  }) {
    Map m = message.toMap();
    m['date'] = FieldValue.serverTimestamp();

    return _firestore
        .collection(type)
        .doc(id_chat)
        .collection('messages')
        .add(m)
        .then((value) async {
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
    });
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
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('chats')
        .where(Group.MEMBERS, arrayContains: id_user)
        .limit(limit)
        .get();
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
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('rooms')
        .where(Group.MEMBERS, arrayContains: id)
        .limit(limit)
        .get();
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

  removeMemberFromRoom({String id_user, String id_room}) {
    _firestore.collection('rooms').doc(id_room).set({
      'members': FieldValue.arrayRemove([id_user]),
      'admins': FieldValue.arrayRemove([id_user]),
    }, SetOptions(merge: true));
  }
}
