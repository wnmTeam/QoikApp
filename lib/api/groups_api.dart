import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/StorageController.dart';

import 'auth.dart';

class GroupsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth auth = Auth();

  StorageController _storageController = StorageController();

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
      return reference.limit(limit).get();
    } else {
      return reference.startAfterDocument(last).limit(limit).get();
    }
  }

  addMemberToRoom({uids, String id_group}) async {
    return _firestore.collection('rooms').doc(id_group).set({
      'members': FieldValue.arrayUnion(uids),
    }, SetOptions(merge: true));
  }

  Future createGroup({Group group, List uids, File image}) async {
    var d = await _firestore.collection('rooms').add(group.toMap());
    if (image != null) {
      String url = await _storageController.uploadRoomImage(
        id_room: d.id,
        img: image,
      );
      print(url);
      await addImageToRoom(
        id_room: d.id,
        url: url,
      );
    }
  }

  Future getGroupInfo({id_group}) {
    return _firestore.collection('groups').doc(id_group).get();
  }

  addMemberToGroup({uid, String id_group, String type, String name}) {
    WriteBatch batch = _firestore.batch();
    batch.set(_firestore.collection('groups').doc(id_group), {
      'name': name,
      'type': type,
    });

    batch.set(
        _firestore
            .collection('groups')
            .doc(id_group)
            .collection('members')
            .doc(uid),
        {'ex': true});

    return batch.commit();
  }

  addImageToRoom({
    String id_room,
    String url,
  }) {
    return _firestore
        .collection('rooms')
        .doc(id_room)
        .set({'img': url}, SetOptions(merge: true));
  }
}
