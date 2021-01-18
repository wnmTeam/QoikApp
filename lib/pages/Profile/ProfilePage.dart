import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as str;
import 'package:stumeapp/controller/StorageController.dart';

class ProfilePage extends StatefulWidget {
  String id_user;
  User user;

  ProfilePage({this.id_user, this.user});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage> {
  TextEditingController textEditingController;

  bool isMyProfile = false;
  String imagePath = "";

  bool chatLoading = true;
  bool friendLoading = true;

  Group chat;
  bool isFriend = false;
  bool isRequested = false;

  var _image;

  AuthController _authController = AuthController();
  FriendsController _friendsController = FriendsController();
  ChatController _chatsController = ChatController();
  StorageController _storageController = StorageController();

  TextEditingController _bioController;
  bool _editBio = false;

  @override
  void initState() {
    if (_authController.getUser.uid == widget.id_user) {
      isMyProfile = true;
      print('My Profile');
    }
    _bioController = TextEditingController(
      text: widget.user.bio,
    );

    getChat();
    getFriend();

    super.initState();
  }

  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
        body: !chatLoading && !friendLoading
            ? SafeArea(
                child: ListView(
                  children: <Widget>[
                    Stack(
                      children: [
                        Container(
                          height: 300.0,
                          width: size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(11),
                            ),
                            color: Colors.indigo[300],
                          ),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 40,
                              ),
                              Avatar(
                                imagePath: widget.user.img,
                                myProfile: isMyProfile,
                                ubdateImagerofile: (img) async {
                                  String url =
                                      await _storageController.uploadPic(
                                    context,
                                    img,
                                    widget.id_user,
                                  );
                                  await _authController.setImageUrl(
                                      id_user: widget.id_user, url: url);
                                },
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                widget.user.firstName +
                                    ' ' +
                                    widget.user.secondName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 240),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                !isMyProfile
                                    ? Card(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 15,
                                          horizontal: 20,
                                        ),
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16.0,
                                            horizontal: 8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              isFriend
                                                  ? FlatButton.icon(
                                                      icon: Icon(
                                                        Icons.person_remove,
                                                        color: Colors.blueGrey,
                                                      ),
                                                      label:
                                                          Text('Remove Friend'),
                                                      onPressed: () async {
                                                        await _friendsController
                                                            .deleteFriend(
                                                          id_user1:
                                                              MyUser.myUser.id,
                                                          id_user2:
                                                              widget.id_user,
                                                        );
                                                        setState(() {
                                                          isFriend = false;
                                                        });
                                                      },
                                                    )
                                                  : isRequested
                                                      ? FlatButton.icon(
                                                          color: Colors
                                                              .indigoAccent,
                                                          icon: Icon(
                                                            Icons.person_add,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                          label: Text(
                                                              'add Friend'),
                                                          onPressed:
                                                              () async {},
                                                        )
                                                      : FlatButton.icon(
                                                          icon: Icon(
                                                            Icons.person_add,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                          label: Text(
                                                              'add Friend'),
                                                          onPressed: () async {
                                                            await _friendsController
                                                                .sendRequestFriend(
                                                              id_sender:
                                                                  _authController
                                                                      .getUser
                                                                      .uid,
                                                              id_receiver:
                                                                  widget
                                                                      .user.id,
                                                            );
                                                            setState(() {
                                                              isRequested =
                                                                  true;
                                                            });
                                                          },
                                                        ),
                                              FlatButton.icon(
                                                icon: Icon(
                                                  Icons.chat,
                                                  color: Colors.blueGrey,
                                                ),
                                                label: Text('Mesaage'),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                      context, '/ChatRoomPage',
                                                      arguments: {
                                                        'group': chat,
                                                        'user': widget.user,
                                                      });
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Card(
                                  margin: EdgeInsets.all(20),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Personal Info',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    widget.user.points
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.indigo,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 40,
                                                    ),
                                                  ),
                                                  Text('Points'),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    color: Colors.indigo,
                                                    size: 50,
                                                  ),
                                                  Text(widget.user.tag),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 18,
                                        ),
                                        SizedBox(
                                            width: size.width - 24,
                                            child: ListTile(
                                              trailing: isMyProfile
                                                  ? IconButton(
                                                      icon: Icon(
                                                        !_editBio
                                                            ? Icons.edit
                                                            : Icons.save,
                                                      ),
                                                      onPressed: () {
                                                        if (_editBio) {
                                                          _authController
                                                              .updateBio(
                                                                  _bioController
                                                                      .text);
                                                        }
                                                        setState(() {
                                                          if (_editBio) {
                                                            MyUser.myUser.bio =
                                                                _bioController
                                                                    .text;
                                                            widget.user.bio =
                                                                _bioController
                                                                    .text;
                                                          }
                                                          _editBio = !_editBio;
                                                        });
                                                      },
                                                    )
                                                  : SizedBox(
                                                      height: 2,
                                                      width: 2,
                                                    ),
                                              title: Text('Bio'),
                                              subtitle: TextField(
                                                maxLines: 50,
                                                autofocus: true,
                                                minLines: 1,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                                controller: _bioController,
                                                readOnly: !_editBio,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            )),
                                        SizedBox(
                                            width: size.width - 24,
                                            child: ListTile(
                                              title: Text('University'),
                                              subtitle:
                                                  Text(widget.user.university),
                                            )),
                                        SizedBox(
                                            width: size.width - 24,
                                            child: ListTile(
                                              title: Text('College'),
                                              subtitle:
                                                  Text(widget.user.college),
                                            )),
                                        isMyProfile
                                            ? SizedBox(
                                                width: size.width - 24,
                                                child: ListTile(
                                                  title: Text('E-Mail'),
                                                  subtitle: Text(
                                                      'syromar39@gmail.com'),
                                                ))
                                            : Container(),
                                        isMyProfile
                                            ? SizedBox(
                                                width: size.width - 24,
                                                child: ListTile(
                                                  trailing: IconButton(
                                                    icon: Icon(
                                                      Icons.edit,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/ChangePasswordPage');
                                                    },
                                                  ),
                                                  title: Text('password'),
                                                  subtitle: TextField(
                                                    controller:
                                                        TextEditingController(
                                                            text:
                                                                'rrrrrrrryuiodrcfvgbh'),
                                                    obscureText: true,
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ))
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      isMyProfile ? 'My Friends' : 'Friends',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ),
                                FutureBuilder(
                                    future: _friendsController.getFriends(
                                      id: widget.id_user,
                                      limit: 8,
                                      last: null,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        List friends = snapshot.data.docs;

                                        print(friends);
                                        return SizedBox(
                                          height: 260,
                                          child: friends.length > 0
                                              ? ListView.builder(
                                                  padding: EdgeInsets.all(8),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: friends.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    String id =
                                                        friends[index].id;
                                                    print(
                                                        friends[index].data());
                                                    return FriendWidget(
                                                      id: id,
                                                      isMyProfile: isMyProfile,
                                                    );
                                                  },
                                                )
                                              : Center(
                                                  child: Text('No Friends')),
                                        );
                                      }
                                      return SizedBox(
                                        height: 250,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }),
                                SizedBox(
                                  height: 25,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }

  getChat() async {
    if (isMyProfile)
      setState(() {
        chatLoading = false;
      });
    var d = await _chatsController.getChat(getChatID());

    setState(() {
      if (d.data() != null) chat = Group().fromMap(d.data())..setId(d.id);
      chatLoading = false;
    });
  }

  getFriend() async {
    if (isMyProfile)
      setState(() {
        friendLoading = false;
      });
    var d = await _friendsController.getFriend(
      id_user: _authController.getUser.uid,
      id_friend: widget.user.id,
    );

    setState(() {
      if (d.data() != null) isFriend = true;
      friendLoading = false;
    });
  }

  String getChatID() {
    List l = [widget.user.id, _authController.getUser.uid];
    l.sort();

    return l[0] + l[1];
  }
}

class FriendWidget extends StatefulWidget {
  String id;
  bool isMyProfile;

  FriendWidget({this.id, this.isMyProfile});

  @override
  _FriendWidgetState createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  User _user;
  Future _getUser;

  AuthController _authController = AuthController();

  @override
  void initState() {
    _getUser = _authController.getUserInfo(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _user = User().fromMap(snapshot.data)..setId(snapshot.data.id);
          return _friendBuilder();
        }
        return Container();
      },
    );
  }

  Widget _friendBuilder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 175,
                width: 175,
                color: Colors.indigo[200],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              _user.firstName + ' ' + _user.secondName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              width: 170,
              height: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text(
                      'New User',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  !widget.isMyProfile
                      ? InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.person_add,
                              color: Colors.indigo[400],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/ChatRoomPage',
                              arguments: {
                                'user': _user,
                                'group': Group(
                                  members: [
                                    _user.id,
                                    MyUser.myUser.id,
                                  ],
                                ),
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.chat,
                              color: Colors.indigo[400],
                            ),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Avatar extends StatefulWidget {
  String imagePath;
  bool myProfile;
  Function ubdateImagerofile;

  Avatar({this.imagePath, this.myProfile, this.ubdateImagerofile});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  File _image;

  StorageController _storageController = StorageController();

  @override
  Widget build(BuildContext context) {
    print(widget.imagePath);
    return Stack(
      children: <Widget>[
        Center(
            child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: widget.imagePath != ''
                ? Image.network(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    width: 150,
                    height: 150,
                  )
                : _image != null
                    ? Image.file(
                        _image,
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      )
                    : Container(
                        color: Colors.white,
                      ),
          ),
        )),
        widget.myProfile
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 125, right: 80),
                  child: InkWell(
                    onTap: () async {
                      final pickedFile = await _storageController.getImage();
                      if (pickedFile != null) {
                        {
                          setState(() {
                            _image = File(pickedFile.path);
                          });
                          widget.ubdateImagerofile(_image);
                        }
                      }
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
            : Container(),
      ],
    );
  }
}
