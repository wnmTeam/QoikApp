import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();
  AuthController _authController = AuthController();

  StorageController _storageController = StorageController();

  List<DocumentSnapshot> friends = [];

  TextEditingController _nameController = TextEditingController();

  File _image;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "createGroup",
      child: Scaffold(
        appBar: AppBar(
          title: Text(Languages.translate(
            context,
            'ceate_group',
          )),
          elevation: 0,
          actions: [
            Tooltip(
              message: Languages.translate(
                context,
                'next',
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Avatar(
                  setImage: (image) {
                    setState(() {
                      _image = image;
                    });
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    // floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelText: "Group name",
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {}
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) return;
                    Navigator.pushNamed(
                      context,
                      '/SelectMembers',
                      arguments: {
                        'group': Group(
                          name: _nameController.text,
                          type: Group.TYPE_GROUP,
                          img: ' ',
                          admins: [_authController.getUser.uid],
                        ),
                        'type': 'create',
                        'image': _image,
                      },
                    );
                  },
                  child: Text(Languages.translate(
                    context,
                    'next',
                  )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getMyFriends() async {
    if (!hasMore) {
      print('No More friends');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _friendsController
        .getFriends(
      id: _authController.getUser.uid,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('friends');
      print(value.docs.length);
      setState(() {
        friends.addAll(value.docs);
        isLoading = false;
        try {
          lastDocument = friends.last;
        } catch (e) {}
      });
    });
  }
}

class Avatar extends StatefulWidget {
  Function setImage;

  Avatar({this.setImage});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  StorageController _storageController = StorageController();
  File _image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 75,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: _image != null ? Image.file(
                  _image,
                  fit: BoxFit.cover,
                  height: 150,
                  width: 150,
                ) : Image.asset(
                  ConstValues.userImage,
                  fit: BoxFit.cover,
                  height: 150,
                  width: 150,
                )),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 115, right: 50),
            child: InkWell(
              onTap: () async {
                final pickedFile = await _storageController.getImage();

                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                  widget.setImage(_image);
                }

                print("onTap");
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

//class Avatar extends StatelessWidget {
//  const Avatar({
//    Key key,
//    this.myProfile,
//    @required this.imagePath,
//  }) : super(key: key);
//  final String imagePath;
//  final bool myProfile;
//
//  StorageController _storageController =StorageController();
//
//
//  @override
//  Widget build(BuildContext context) {
//    return Stack(
//      children: <Widget>[
//        Center(
//          child: Container(
//            width: 100.0,
//            height: 100.0,
//            decoration: BoxDecoration(
//              shape: BoxShape.circle,
//              color: Colors.white,
//              image: DecorationImage(
//                image: ExactAssetImage(imagePath),
//                fit: BoxFit.cover,
//              ),
//            ),
//          ),
//        ), Center(
//          child: Padding(
//            padding: const EdgeInsets.only(top: 75, right: 40),
//            child: InkWell(
//              onTap: () {
//                final pickedFile =
//                    await _storageController
//                    .getImage();
//
//                if(pickedFile != null){
//                  ll
//                }
//
//                print("onTap");
//              },
//              child: Container(
//                decoration: BoxDecoration(
//                  color: Colors.grey[400],
//                  shape: BoxShape.circle,
//                ),
//                child: Padding(
//                  padding: const EdgeInsets.all(7.0),
//                  child: Icon(
//                    Icons.camera_alt,
//                    color: Colors.white,
//                  ),
//                ),
//              ),
//            ),
//          ),
//        )
//      ],
//    );
//  }
//}

class UserWidget extends StatefulWidget {
  String id;

  UserWidget({this.id});

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  AuthController _authController = AuthController();

  User user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authController.getUserInfo(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = User().fromMap(snapshot.data)..setId(widget.id);
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: () {},
              leading: Container(
                width: 57,
                height: 57,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Colors.indigo[200]),
              ),
              title: Text(user.firstName + ' ' + user.secondName),
              subtitle: Text(
                user.university + ' | ' + user.college,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            );
          }
          return Container();
        });
  }
}
