import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Message.dart';

class ChatsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future getMessages({
    int limit,
    DocumentSnapshot last,
    String id_chat,
  }) {
    CollectionReference reference;

    reference =
        _firestore.collection('groups').doc(id_chat).collection('messages');

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

  Future addMessage({Message message, String id_chat}) {
    Map m = message.toMap();
//    m['date'] = FieldValue.serverTimestamp();

    return _firestore
        .collection('groups')
        .doc(id_chat)
        .collection('messages')
        .add(m);
  }

  Stream getNewMessages({String id_chat}) {
    return _firestore
        .collection('groups')
        .doc(id_chat)
        .collection('messages')
        .orderBy('date')
        .startAfter([DateTime.now()]).snapshots();
  }
}
