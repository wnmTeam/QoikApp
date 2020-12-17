import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/api/groups_api.dart';
import 'package:stumeapp/controller/StorageController.dart';

class GroupsController {
  GroupsApi api = GroupsApi();
  StorageController storage = StorageController();

  List<Group> getMyGroups() {
    return [
      Group(name: storage.getUser().university, type: Group.TYPE_UNIVERSITY),
      Group(name: storage.getUser().college, type: Group.TYPE_COLLEGE),
    ];
  }

  getMembers({int limit, DocumentSnapshot last, Group group}) =>
      api.getMembers(limit: limit, last: last, group: group,);

  void addMemberToUniversity({uid, university, user}) {
    api.addMemberToUniversity(uid: uid, university: university, user: user);
  }

  void addMemberToCollege({uid, college}) {}
}
