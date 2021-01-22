import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class RoomInfoPage extends StatefulWidget {
  Group group;

  RoomInfoPage({this.group});

  @override
  _RoomInfoPageState createState() => _RoomInfoPageState();
}

class _RoomInfoPageState extends State<RoomInfoPage> {
  AuthController _authController = AuthController();

  bool isAdmin = false;

  @override
  void initState() {
    if (widget.group.admins.contains(MyUser.myUser.id)) isAdmin = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              child: Icon(Icons.person_add),
            )
          : null,
      body: ListView.builder(
        itemCount: widget.group.members.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
              future: _authController.getUserInfo(widget.group.members[index]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                  User user = User()
                      .fromMap(snapshot.data.data())
                      .setId(snapshot.data.id);
                  print(user.id);
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/ProfilePage',
                        arguments: {
                          'id_user': user.id,
                          'user': user,
                        },
                      );
                    },
                    title: Row(
                      children: [
                        Text(user.firstName + ' ' + user.secondName),
                        widget.group.admins.contains(user.id)
                            ? Icon(
                                Icons.star,
                                color: Colors.grey,
                              )
                            : Container(),
                      ],
                    ),
                    subtitle: Text('New User'),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(57),
                      child: Image.network(
                        user.img != null ? user.img : ' ',
                        fit: BoxFit.cover,
                        width: 57,
                        height: 57,
                      ),
                    ),
                  );
                }
                return UserPlaceholder();
              });
        },
      ),
    );
  }
}
