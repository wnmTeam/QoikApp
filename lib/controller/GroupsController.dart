import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/api/groups_api.dart';

class GroupsController {
  GroupsApi api = GroupsApi();

  getMembers({int limit, DocumentSnapshot last, Group group}) => api.getMembers(
        limit: limit,
        last: last,
        group: group,
      );

  addMemberToRoom({uids, String id_group}) {
    return api.addMemberToRoom(
      uids: uids,
      id_group: id_group,
    );
  }

  Future createGroup({Group group, uids, image}) {
    group.members = uids;
    return api.createGroup(
      group: group,
      uids: uids,
      image: image,
    );
  }

  Future getGroupInfo({id_group}) => api.getGroupInfo(id_group: id_group);

  addMemberToGroup({uid, String id_group, String type, String name}) {
    return api.addMemberToGroup(
        uid: uid, id_group: id_group, type: type, name: name);
  }
}
