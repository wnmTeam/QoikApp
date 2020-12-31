import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/api/groups_api.dart';
import 'package:stumeapp/controller/StorageController.dart';

class GroupsController {
  GroupsApi api = GroupsApi();
  StorageController storage = StorageController();

  getMyGroups({String id_user}) {
    return api.getMyGroups(id_user:id_user);
  }

  getMembers({int limit, DocumentSnapshot last, Group group}) => api.getMembers(
        limit: limit,
        last: last,
        group: group,
      );

  void addMemberToUniversity({uid, university, user}) {
    api.addMemberToUniversity(uid: uid, university: university, user: user);
  }

  void addMemberToCollege({uid, college}) {}

   addMemberToGroup({uid, String id_group}) {
    return api.addMemberToGroup(
      uid: uid,
      id_group: id_group,
    );
  }
}
