import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/GroupsController.dart';

class GroupsChatsTab extends StatefulWidget {
  @override
  _GroupsChatsTabState createState() => _GroupsChatsTabState();
}

class _GroupsChatsTabState extends State<GroupsChatsTab> {
  GroupsController _groupsController = GroupsController();

  AuthController _authController = AuthController();

  List _groups = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _groupsController.getMyGroups(
          id_user: _authController.getUser.uid,
        ),
        builder: (context, snapshot) {
          print(_authController.getUser.uid);
          if (snapshot.hasData) {
            _groups = snapshot.data.docs;
            print(_groups);
            return ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                return _groupBuilder(
                    context,
                    Group()
                        .fromMap(_groups[index].data())
                        .setId(_groups[index].id));
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
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
