import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';

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

  AuthController _authController = AuthController();
  FriendsController _friendsController = FriendsController();

  @override
  void initState() {
    super.initState();
  }

  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (_authController.getUser.uid == widget.id_user) {
      isMyProfile = true;
      print('My Profile');
    }
    return Scaffold(
        body: SafeArea(
      child: ListView(
        children: <Widget>[
          Stack(
            children: [
              Container(
                height: 275.0,
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
                      imagePath: imagePath,
                      myProfile: isMyProfile,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      widget.user.firstName + ' ' + widget.user.secondName,
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
                padding: const EdgeInsets.only(top: 200),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !isMyProfile
                          ? Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    FlatButton.icon(
                                      icon: Icon(
                                        Icons.person_add,
                                        color: Colors.blueGrey,
                                      ),
                                      label: Text('Add Friend'),
                                      onPressed: () {},
                                    ),
                                    FlatButton.icon(
                                      icon: Icon(
                                        Icons.chat,
                                        color: Colors.blueGrey,
                                      ),
                                      label: Text('Mesaage'),
                                      onPressed: () {},
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
                                          '120',
                                          style: TextStyle(
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.bold,
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
                                        Text('New User'),
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
                                              Icons.edit,
                                            ),
                                            onPressed: () {},
                                          )
                                        : SizedBox(
                                            height: 2,
                                            width: 2,
                                          ),
                                    title: Text('Bio'),
                                    subtitle: Text(
                                        'When the violence causes silence.. we must be mistaken'),
                                  )),
                              SizedBox(
                                  width: size.width - 24,
                                  child: ListTile(
                                    title: Text('University'),
                                    subtitle: Text(widget.user.university),
                                  )),
                              SizedBox(
                                  width: size.width - 24,
                                  child: ListTile(
                                    title: Text('College'),
                                    subtitle: Text(widget.user.college),
                                  )),
                              SizedBox(
                                  width: size.width - 24,
                                  child: ListTile(
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.copy,
                                      ),
                                      onPressed: () {},
                                    ),
                                    title: Text('E-Mail'),
                                    subtitle: Text('syromar39@gmail.com'),
                                  )),
                              SizedBox(
                                  width: size.width - 24,
                                  child: ListTile(
                                    trailing: isMyProfile
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                            ),
                                            onPressed: () {},
                                          )
                                        : SizedBox(
                                            height: 2,
                                            width: 2,
                                          ),
                                    title: Text('password'),
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
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(isMyProfile ? 'My Friends' : 'Friends',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
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
                                        scrollDirection: Axis.horizontal,
                                        itemCount: friends.length,
                                        itemBuilder: (context, index) {
                                          String id = friends[index].id;
                                          print(friends[index].data());
                                          return FriendWidget(
                                            id: id,
                                            isMyProfile: isMyProfile,
                                          );
                                        },
                                      )
                                    : Center(child: Text('No Friends')),
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
    ));
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
          _user = User().fromMap(snapshot.data);
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
                          onTap: () {},
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

class Avatar extends StatelessWidget {
  const Avatar({
    Key key,
    this.myProfile,
    @required this.imagePath,
  }) : super(key: key);
  final String imagePath;
  final bool myProfile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              image: DecorationImage(
                image: ExactAssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        myProfile
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 75, right: 40),
                  child: InkWell(
                    onTap: () {},
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
