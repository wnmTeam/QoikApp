import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';

class ChatsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  }) {
    Map m = message.toMap();
    m['date'] = FieldValue.serverTimestamp();

    return _firestore
        .collection(type)
        .doc(id_chat)
        .collection('messages')
        .add(m);
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
}
