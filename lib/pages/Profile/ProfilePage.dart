import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/ImageView/ImageView.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({this.user});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  TextEditingController textEditingController;

  bool isMyProfile = false;
  String imagePath = "";

  bool chatLoading = true;
  bool friendLoading = true;

  Group chat;
  bool isFriend = false;
  bool isRequested = false;
  bool isHeRequeste = false;

  // var _image;

  AuthController _authController = AuthController();
  FriendsController _friendsController = FriendsController();
  ChatController _chatsController = ChatController();
  StorageController _storageController = StorageController();

  TextEditingController _bioController;
  bool _editBio = false;
  bool uploadImage = false;

  @override
  void initState() {
    if (MyUser.myUser.id == widget.user.id) {
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
            ? Stack(children: [
                SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        height: 300,
                        width: size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                        ),
                        // child: Column(
                        //   children: <Widget>[
                        //     SizedBox(
                        //       height: 40,
                        //     ),
                        //     Avatar(
                        //       imagePath: widget.user.img,
                        //       myProfile: isMyProfile,
                        //       uploadImage: uploadImage,
                        //       ubdateImagerofile: (img) async {
                        //         setState(() {
                        //           uploadImage = true;
                        //         });
                        //         String url = await _storageController.uploadPic(
                        //           context,
                        //           img,
                        //           widget.user.id,
                        //         );
                        //         await _authController.setImageUrl(
                        //             id_user: widget.user.id, url: url);
                        //         print(url);
                        //         print(widget.user.id);
                        //
                        //         setState(() {
                        //           uploadImage = false;
                        //         });
                        //       },
                        //     ),
                        //     SizedBox(
                        //       height: 12,
                        //     ),
                        //     Text(
                        //       widget.user.firstName +
                        //           ' ' +
                        //           widget.user.secondName,
                        //       style: TextStyle(
                        //         fontSize: 24,
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     uploadImage
                        //         ? SizedBox(
                        //             width: size.width / 2,
                        //             child: LinearProgressIndicator())
                        //         : Container(),
                        //     SizedBox(
                        //       height: 8,
                        //     ),
                        //   ],
                        // ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Avatar(
                            imagePath: widget.user.img,
                            myProfile: isMyProfile,
                            uploadImage: uploadImage,
                            ubdateImagerofile: (img) async {
                              setState(() {
                                uploadImage = true;
                              });
                              String url = await _storageController.uploadPic(
                                context,
                                img,
                                widget.user.id,
                              );
                              await _authController.setImageUrl(
                                  id_user: widget.user.id, url: url);
                              print(url);
                              print(widget.user.id);

                              setState(() {
                                uploadImage = false;
                              });
                            },
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            widget.user.firstName +
                                ' ' +
                                widget.user.secondName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          uploadImage
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width / 4),
                                  // width: size.width / 2,
                                  child: LinearProgressIndicator())
                              : Container(),
                          SizedBox(
                            height: 8,
                          ),
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
                                                ),
                                                label: Text(Languages.translate(
                                                  context,
                                                  'remove_friend',
                                                )),
                                                onPressed: () async {
                                                  await _friendsController
                                                      .deleteFriend(
                                                    id_user1: MyUser.myUser.id,
                                                    id_user2: widget.user.id,
                                                  );
                                                  setState(() {
                                                    isFriend = false;
                                                  });
                                                },
                                              )
                                            : isRequested
                                                ? FlatButton.icon(
                                                    icon: Icon(
                                                      Icons.person_remove,
                                                    ),
                                                    label: Text(
                                                        Languages.translate(
                                                      context,
                                                      'cancel_reques',
                                                    )),
                                                    onPressed: () async {
                                                      await _friendsController
                                                          .deleteFriendRequest(
                                                        id_user: widget.user.id,
                                                        id_other:
                                                            MyUser.myUser.id,
                                                      );
                                                      setState(() {
                                                        isRequested = false;
                                                      });
                                                    },
                                                  )
                                                : isHeRequeste
                                                    ? FlatButton.icon(
                                                        icon: Icon(
                                                          Icons.person_add,
                                                        ),
                                                        label: Text(
                                                            Languages.translate(
                                                          context,
                                                          'accept',
                                                        )),
                                                        onPressed: () async {
                                                          await _friendsController
                                                              .acceptRequestFriend(
                                                            id_requestSender:
                                                                widget.user.id,
                                                          );
                                                          setState(() {
                                                            isFriend = true;
                                                          });
                                                        },
                                                      )
                                                    : FlatButton.icon(
                                                        icon: Icon(
                                                          Icons.person_add,
                                                        ),
                                                        label: Text(
                                                            Languages.translate(
                                                          context,
                                                          'add_friend',
                                                        )),
                                                        onPressed: () async {
                                                          await _friendsController
                                                              .sendRequestFriend(
                                                            id_sender:
                                                                _authController
                                                                    .getUser
                                                                    .uid,
                                                            id_receiver:
                                                                widget.user.id,
                                                          );
                                                          setState(() {
                                                            isRequested = true;
                                                          });
                                                        },
                                                      ),
                                        FlatButton.icon(
                                          icon: Icon(
                                            CupertinoIcons.chat_bubble_fill,
                                          ),
                                          label: Text(Languages.translate(
                                            context,
                                            'message',
                                          )),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      Languages.translate(
                                        context,
                                        'personal_info',
                                      ),
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
                                            Image.asset(
                                              _userTagImage(),
                                              width: 50,
                                              height: 50,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            Text(Languages.translate(
                                              context,
                                              widget.user.userTag != 'admin'
                                                  ? widget.user.tag
                                                  : widget.user.userTag,
                                            )),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              widget.user.points.toString(),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 45,
                                              ),
                                            ),
                                            Text(Languages.translate(
                                              context,
                                              'points',
                                            )),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/${widget.user.gender}.svg',
                                              width: 42,
                                              height: 42,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(Languages.translate(
                                              context,
                                              widget.user.gender,
                                            )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 18,
                                  ),
                                  isMyProfile ? ListTile(
                                    trailing: isMyProfile
                                        ? IconButton(
                                      icon: Icon(
                                        !_editBio
                                            ? Icons.edit
                                            : Icons.save,
                                      ),
                                      onPressed: () {
                                        if (_editBio) {
                                          _authController.updateBio(
                                              _bioController.text);
                                        }
                                        setState(() {
                                          if (_editBio) {
                                            MyUser.myUser.bio =
                                                _bioController.text;
                                            widget.user.bio =
                                                _bioController.text;
                                          }
                                          _editBio = !_editBio;
                                        });
                                      },
                                    )
                                        : SizedBox(
                                      height: 2,
                                      width: 2,
                                    ),
                                    title: Text(Languages.translate(
                                      context,
                                      'bio',
                                    )),
                                    subtitle: TextField(
                                      maxLines: 50,
                                      autofocus: true,
                                      minLines: 1,
                                      style: TextStyle(
                                        color: Theme
                                            .of(context)
                                            .textTheme
                                            .bodyText2
                                            .color
                                            .withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                      controller: _bioController,
                                      readOnly: !_editBio,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ) :
                                  ListTile(
                                    title: Text(Languages.translate(
                                      context,
                                      'bio',
                                    )),
                                    subtitle: Linkify(
                                      onOpen: (link) async {
                                        if (await canLaunch(link.url)) {
                                                await launch(link.url);
                                              } else {
                                                throw 'Could not launch $link';
                                              }
                                            },
                                            linkStyle: TextStyle(
                                              color: Colors.blue[200],
                                            ),
                                            options:
                                                LinkifyOptions(humanize: true),
                                            text: _bioController.text,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .color
                                                  .withOpacity(0.6),
                                              fontSize: 14,
                                            ),
                                            // style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  if (widget.user.university != null)
                                    ListTile(
                                      title: Text(Languages.translate(
                                        context,
                                        'university',
                                      )),
                                      subtitle:
                                      Text(widget.user.university),
                                    ),
                                  if (widget.user.college != null)
                                    ListTile(
                                      title: Text(Languages.translate(
                                        context,
                                        'college',
                                      )),
                                      subtitle: Text(widget.user.college),
                                    ),
                                  isMyProfile && widget.user.email != null
                                      ? ListTile(
                                    title: Text(Languages.translate(
                                      context,
                                      'email',
                                    )),
                                    subtitle: Text(widget.user.email),
                                  )
                                      : Container(),
                                  isMyProfile
                                      ? ListTile(
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            '/ChangePasswordPage');
                                      },
                                    ),
                                    title: Text(Languages.translate(
                                      context,
                                      'password',
                                    )),
                                    subtitle: TextField(
                                      controller: TextEditingController(
                                          text: 'rrrrrrrryuiodrcfvgbh'),
                                      obscureText: true,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    isMyProfile
                                        ? Languages.translate(
                                      context,
                                            'my_friends',
                                          )
                                        : Languages.translate(
                                            context,
                                            'friends',
                                          ),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                // FlatButton(
                                //     onPressed: () {
                                //       //TODO
                                //     },
                                //     child: Text("More friends"),
                                // )
                              ],
                            ),
                          ),
                          FutureBuilder(
                              future: _friendsController.getFriends(
                                id: widget.user.id,
                                limit: 8,
                                last: null,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List friends = snapshot.data.docs;

                                  print(friends);
                                  return SizedBox(
                                    height: 270,
                                    child: friends.length > 0
                                        ? ListView.builder(
                                            padding: EdgeInsets.all(8),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: friends.length,
                                            itemBuilder: (context, index) {
                                              String id = friends[index].id;
                                              print(friends[index].data());
                                              try {
                                                return FriendWidget(
                                                  id: id,
                                                  isMyProfile: isMyProfile,
                                                );
                                              } catch (e) {
                                                return Container();
                                              }
                                            },
                                          )
                                        : Center(
                                            child: Text(Languages.translate(
                                            context,
                                            'no_friends',
                                          ))),
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
                    ],
                  ),
                ),
          //TODO un comment
          // SafeArea(
          //   child: Directionality.of(context) == TextDirection.ltr
          //       ? Positioned(
          //           top: 0,
          //           left: 0,
          //           child: BackButton(),
          //         )
          //       : Positioned(
          //           top: 0,
          //           right: 0,
          //           child: BackButton(),
          //         ),
          // )
        ])
            : Center(child: CircularProgressIndicator()));
  }

  getChat() async {
    if (isMyProfile) {
      setState(() {
        chatLoading = false;
      });
      return;
    }
    var d = await _chatsController.getChat(getChatID());

    setState(() {
      if (d.data() != null) chat = Group().fromMap(d.data())..setId(d.id);
      chatLoading = false;
    });
  }

  getFriend() async {
    if (isMyProfile) {
      setState(() {
        friendLoading = false;
      });
      return;
    }
    var d = await _friendsController.getFriend(
      id_user: MyUser.myUser.id,
      id_friend: widget.user.id,
    );
    if (d.data() != null) {
      setState(() {
        isFriend = true;
        friendLoading = false;
      });
      return;
    }
    d = await _friendsController.getFriendRequest(
      id_user: MyUser.myUser.id,
      id_other: widget.user.id,
    );
    if (d.data() != null) {
      setState(() {
        isHeRequeste = true;
        friendLoading = false;
      });
      return;
    }
    d = await _friendsController.getFriendRequest(
      id_user: widget.user.id,
      id_other: MyUser.myUser.id,
    );
    if (d.data() != null) {
      setState(() {
        isRequested = true;
        friendLoading = false;
      });
      return;
    }
    setState(() {
      friendLoading = false;
    });
  }

  String getChatID() {
    List l = [widget.user.id, MyUser.myUser.id];
    l.sort();

    return l[0] + l[1];
  }

  String _userTagImage() {
    switch (widget.user.tag) {
      case User.TAG_NEW_USER:
        return 'assets/newUser.png';
      case User.TAG_NORMAL_USER:
        return 'assets/normalUser.png';
      case User.TAG_ACTIVE_USER:
        return 'assets/activeUser.png';
      case User.TAG_PREMIUM_USER:
        return 'assets/exUser.png';
      case User.TAG_VERIFIED_USER:
        return 'assets/sureUser.png';
      default:
        return 'assets/newUser.png';
    }
  }
}

class FriendWidget extends StatefulWidget {
  final String id;
  final bool isMyProfile;

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
          try{
            _user = User().fromMap(snapshot.data)..setId(snapshot.data.id);
            return _friendBuilder();
          }catch(e){return Container();}


        }
        return Container();
      },
    );
  }

  Widget _friendBuilder() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/ProfilePage', arguments: {
          'user': _user,
          'id_user': _user.id,
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Container(
                  height: 175,
                  width: 175,
                  color: Colors.indigo[900],
                  child: CachedNetworkImage(
                    imageUrl: _user.img,
                    placeholder: (context, url) => Center(
                      child: Image.asset(ConstValues.userImage),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 0,
              ),
              SizedBox(
                width: 175,
                child: Text(
                  _user.firstName + ' ' + _user.secondName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                width: 175,
                child: Text(
                  Languages.translate(context, _user.tag),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withOpacity(0.5),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Avatar extends StatefulWidget {
  final String imagePath;
  final bool myProfile;
  final Function ubdateImagerofile;
  final bool uploadImage;

  Avatar(
      {this.imagePath,
      this.myProfile,
      this.ubdateImagerofile,
      this.uploadImage});

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
            child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ImageView(widget.imagePath != null
                    ? widget.imagePath
                    : _image != null && !widget.uploadImage
                        ? _image
                        : ""),
              ),
            );
          },
          child: Hero(
            tag: widget.imagePath != null
                ? widget.imagePath
                : _image != null && !widget.uploadImage
                    ? _image
                    : "",
            child: CircleAvatar(
              radius: 75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: widget.imagePath != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Center(
                          child: Image.asset(ConstValues.userImage),
                        ),
                        imageUrl: widget.imagePath,
                        fit: BoxFit.cover,
                        height: 150,
                        width: 150,
                      )
                    : _image != null && !widget.uploadImage
                        ? Image.file(
                            _image,
                            fit: BoxFit.cover,
                            height: 150,
                            width: 150,
                          )
                        : Image.asset(
                            ConstValues.userImage,
                            fit: BoxFit.cover,
                            height: 150,
                            width: 150,
                          ),
              ),
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
                        color: Theme.of(context).backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).primaryColor,
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
