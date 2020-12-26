import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/controller/GroupsController.dart';

class GroupsChatsTab extends StatefulWidget {
  @override
  _GroupsChatsTabState createState() => _GroupsChatsTabState();
}

class _GroupsChatsTabState extends State<GroupsChatsTab> {
  GroupsController _groupsController = GroupsController();

  List<Group> _groups = [];

  @override
  void initState() {
    _groups = _groupsController.getMyGroups();
    print('groups');
    print(_groups[0].name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        return _groupBuilder(context, _groups[index]);
      },
    );
  }
}

Widget _groupBuilder(BuildContext context, Group group) {
  print(group.name);
  return ListTile(
    title: group.type == Group.TYPE_UNIVERSITY
        ? Text('My University')
        : group.type == Group.TYPE_COLLEGE
            ? Text('My College')
            : Text(group.name),
    onTap: () {
      Navigator.of(context).pushNamed(
        '/GroupPage',
        arguments: {
          'group': group,
        },
      );
    },
    leading: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.indigo[200]),
    ),
    subtitle: Text(group.name),
  );
}
