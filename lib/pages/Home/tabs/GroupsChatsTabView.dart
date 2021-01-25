import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/GroupsController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class GroupsChatsTab extends StatefulWidget {
  @override
  _GroupsChatsTabState createState() => _GroupsChatsTabState();
}

class _GroupsChatsTabState extends State<GroupsChatsTab>
    with AutomaticKeepAliveClientMixin {
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
    return ListView.builder(
      itemCount: MyUser.myUser.groups.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: _groupsController.getGroupInfo(id_group: MyUser.myUser.groups[index]),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              print(MyUser.myUser.groups[index]);
              Group group = Group()
                  .fromMap(snapshot.data.data())
                  .setId(MyUser.myUser.groups[index]);
              return _groupBuilder(
                context,
                group,
              );
            }
            return UserPlaceholder();
          },
        );
      },
    );
  }

  Widget _groupBuilder(BuildContext context, Group group) {
    return ListTile(
      title: group.type == Group.TYPE_UNIVERSITY
          ? Text('My University')
          : Text('My College'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/col.svg',
              color: Colors.white,
              width: 25,
              height: 25,
            ),
          ],
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: ConstValues.firstColor[600]),
      ),
      subtitle: group.type == Group.TYPE_GROUP ? Text('') : Text(group.name),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
