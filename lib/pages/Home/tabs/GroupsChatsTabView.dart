import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/GroupsController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
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

  bool loading = false;

  @override
  void initState() {
    getMyCity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(MyUser.myUser.groups);
    if (!loading)
      return ListView.builder(
        itemCount: MyUser.myUser.groups.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: _groupsController.getGroupInfo(
                id_group: MyUser.myUser.groups[index]),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data.data());
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
    return Center(child: CircularProgressIndicator());
  }

  Widget _groupBuilder(BuildContext context, Group group) {
    return ListTile(
      title: group.type == Group.TYPE_UNIVERSITY
          ? Text(Languages.translate(
              context,
              'my_university',
            ))
          : group.type == Group.TYPE_COLLEGE
              ? Text(Languages.translate(
                  context,
                  'my_college',
                ))
              : group.type == 'city'
                  ? Text(Languages.translate(
                      context,
                      'my_city',
                    ))
                  : Text(Languages.translate(
                      context,
                      group.id,
                    )),
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
          color: Theme.of(context).primaryColor,
        ),
      ),
      subtitle: group.type == Group.TYPE_MOFADALAH ||
              group.type == 'G' ||
              group.type == 'test'
          ? Text('')
          : Text(group.name),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void getMyCity() async {
    setState(() {
      loading = true;
    });
    var d = await _groupsController.getMyCity();
    String city;
    if (d != null) {
      print(d);
      city = d.docs[0].id;
      if (MyUser.myUser.isCity == null)
        _groupsController.addMemberToGroup(
          uid: MyUser.myUser.id,
          id_group: city,
          type: 'city',
          name: city,
        );
    }
    setState(() {
      if (city != null) MyUser.myUser.groups.insert(2, city);
      loading = false;
    });
  }
}
