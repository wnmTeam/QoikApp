import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  getFriendRequests({int limit, DocumentSnapshot last, String id}) {
    if (last == null)
      return _firestore
          .collection('users')
          .doc(id)
          .collection('friendRequests')
          .orderBy('date')
          .limit(limit)
          .get();

    return _firestore
        .collection('users')
        .doc(id)
        .collection('friendRequests')
        .orderBy('date')
        .startAfterDocument(last)
        .limit(limit)
        .get();
  }

  sendRequestFriend({id_sender, String id_receiver}) {
    return _firestore
        .collection('users')
        .doc(id_receiver)
        .collection('friendRequests')
        .doc(id_sender)
        .set({
      'date': FieldValue.serverTimestamp(),
    });
  }

  getFriends({String id, int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('users')
          .doc(id)
          .collection('friends')
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('users')
        .doc(id)
        .collection('friends')
        .limit(limit)
        .get();
  }

  acceptRequestFriend({String id, String id_requestSender}) async {
    WriteBatch batch = _firestore.batch();

    batch.delete(
      _firestore
          .collection('users')
          .doc(id)
          .collection('friendRequests')
          .doc(id_requestSender),
    );

    batch.set(
        _firestore
            .collection('users')
            .doc(id)
            .collection('friends')
            .doc(id_requestSender),
        {
          'date': FieldValue.serverTimestamp(),
        });

    batch.set(
        _firestore.collection('users').doc(id_requestSender),
        {
          'groups': FieldValue.arrayUnion([getChatID(id, id_requestSender)])
        },
        SetOptions(merge: true));

    batch.set(
        _firestore.collection('users').doc(id),
        {
          'groups': FieldValue.arrayUnion([getChatID(id, id_requestSender)])
        },
        SetOptions(merge: true));

    batch.set(
        _firestore
            .collection('users')
            .doc(id_requestSender)
            .collection('friends')
            .doc(id),
        {
          'date': FieldValue.serverTimestamp(),
        });

    return batch.commit();
  }

  String getChatID(id1, id2) {
    List l = [id1, id2];
    l.sort();

    return l[0] + l[1];
  }

}
