import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }

    reference =
        _firestore.collection(type).doc(group.name).collection('members');

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

  addMemberToGroup({uid, String id_group}) {
    return _firestore.collection('groups').doc(id_group).set(
      {
        'members': [uid]
      },
      SetOptions(merge: true),
    );
  }
}
