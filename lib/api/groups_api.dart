import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';

import 'auth.dart';

class GroupsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth auth = Auth();

  getMyGroups({String id_user}) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: id_user)
        .get();
  }

  Future<QuerySnapshot> getMembers({
    int limit,
    DocumentSnapshot last,
    Group group,
  }) {
    CollectionReference reference;

    reference =
        _firestore.collection('groups').doc(group.id).collection('members');

    if (last == null) {
      log(reference.path, name: 'reference');
      return reference.get();
//      return reference.limit(limit).get();
    } else {
      return reference.startAfterDocument(last).limit(limit).get();
    }
  }

  void addMemberToUniversity({uid, User user, university}) async {
    CollectionReference reference = _firestore
        .collection('universityGroups')
        .doc(university)
        .collection('members');

    await reference.doc(uid).set({
      'name': user.firstName + ' ' + user.secondName,
      'activeState': 'new user',
      'img': 'dfghjkrtdyugijketdrfyughjkfghjhjkfb',
    });
    print('ooooooooooooooooooooooooooooooooooooooooo');
  }

  void addMemberToCollege({uid, User user, college}) {
    CollectionReference reference = _firestore
        .collection('collegeGroups')
        .doc(college)
        .collection('members');

    reference.doc(uid).set({
      'name': user.firstName + ' ' + user.secondName,
      'activeState': 'new user',
      'img': 'dfghjkrtdyugijketdrfyughjkfghjhjkfb',
    });
  }

  addMemberToGroup({uids, String id_group}) async {
    WriteBatch b = _firestore.batch();

    for (String uid in uids) {
      DocumentReference r = _firestore
          .collection('groups')
          .doc(id_group)
          .collection('members')
          .doc(uid);
      b.set(r, {'ex': true});
      r = _firestore.collection('users').doc(uid);
      b.set(
          r,
          {
            'groups': FieldValue.arrayUnion([id_group])
          },
          SetOptions(merge: true));
    }
    return b.commit();
  }

  Future createGroup({Group group, List uids}) async {
    var d = await _firestore.collection('groups').add(group.toMap());
    WriteBatch b = _firestore.batch();

    for (String uid in uids) {
      DocumentReference r = _firestore
          .collection('groups')
          .doc(d.id)
          .collection('members')
          .doc(uid);
      b.set(r, {'ex': true});
      r = _firestore.collection('users').doc(uid);
      b.set(
          r,
          {
            'groups': FieldValue.arrayUnion([d.id])
          },
          SetOptions(merge: true));
    }
    return b.commit();
  }

  Future createChat({Group group}) {
    Map m = group.toMap();
    m[Group.LAST_ACTIVE] = FieldValue.serverTimestamp();
    return _firestore.collection('groups').doc(group.id).set(m);
  }

  Future getGroupInfo({id_group}) {
    return _firestore.collection('groups').doc(id_group).get();
  }
}
