import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/GroupsController.dart';
import 'package:stumeapp/controller/StorageController.dart';

class GroupsChatsTab extends StatefulWidget {
  @override
  _GroupsChatsTabState createState() => _GroupsChatsTabState();
}

class _GroupsChatsTabState extends State<GroupsChatsTab> {
  GroupsController _groupsController = GroupsController();

  AuthController _authController = AuthController();
  StorageController _storageController = StorageController();

  List _groups = [];
  User user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authController.getUserInfo(_authController.getUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = User().fromMap(snapshot.data.data());
            return ListView.builder(
              itemCount: user.groups.length,
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: _groupsController.getGroupInfo(
                      id_group: user.groups[index]),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      print(user.groups[index]);
                      Group group = Group()
                          .fromMap(snapshot.data.data())
                          .setId(user.groups[index]);
                      if (group.type == Group.TYPE_CHAT)
                        return _chatBuilder(
                          context,
                          group,
                        );
                      return _groupBuilder(
                        context,
                        group,
                      );
                    }
                    return Container();
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _chatBuilder(BuildContext context, Group group) {
    User user;
    return FutureBuilder(
      future: _authController.getUserInfo(
        _authController.getUser.uid == group.members[0]
            ? group.members[1]
            : group.members[0],
      ),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          user = User().fromMap(snapshot.data.data()).setId(snapshot.data.id);
          return ListTile(
            leading: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.indigo[200]),
            ),
            title: Text(user.firstName + ' ' + user.secondName),
            subtitle: Text('New User'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/ChatRoomPage',
                arguments: {
                  'user': user,
                  'group': group,
                },
              );
            },
          );
        }
        return Container();
      },
    );
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
        width: 55,
        height: 55,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: Colors.indigo[200]),
      ),
      subtitle: group.type == Group.TYPE_GROUP ? Text('') : Text(group.name),
    );
  }
}
