import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class SearchFriendsPage extends StatefulWidget {
  @override
  _SearchFriendsPageState createState() => _SearchFriendsPageState();
}

class _SearchFriendsPageState extends State<SearchFriendsPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;

  AuthController _authController = AuthController();

  List<DocumentSnapshot> searchResults = [null];

  TextEditingController _searchController = TextEditingController();

  String _gender;
  String _university;
  String _college;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "search",
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _search();
                  }
                })
          ],
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: Languages.translate(
                  context,
                  'search',
                ),
                hintStyle: TextStyle(color: Colors.white70)),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _search();
              }
            },
            style: TextStyle(color: Colors.white70),
            textInputAction: TextInputAction.search,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Wrap(
                spacing: 5,
                children: [
                  RaisedButton(
                    elevation: 0,
                    onPressed: () async {
                      String item = await _bottomSheetBuild(
                        'universities',
                        _authController.getUniversities(),
                      );
                      _search();
                    },
                    child: Text(
                      _university != null ? _university : Languages.translate(
                        context,
                        'university',
                      ),
                      style: TextStyle(fontSize: 13),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  RaisedButton(
                    elevation: 0,
                    onPressed: () async {
                      String item = await _bottomSheetBuild(
                        'colleges',
                        _authController.getColleges(),
                      );
                      _search();
                    },
                    child: Text(
                      _college != null ? _college : Languages.translate(
                        context,
                        'college',
                      ),
                      style: TextStyle(fontSize: 13),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  RaisedButton(
                    elevation: 0,
                    onPressed: () async {
                      String item = await _bottomSheetBuild('gender', null);
                      _search();
                    },
                    child: Text(
                      _gender != null ? _gender : Languages.translate(
                        context,
                        'gender',
                      ),
                      style: TextStyle(fontSize: 13),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  RaisedButton(
                    elevation: 0,
                    onPressed: () {
                      setState(() {
                        _college = null;
                        _university = null;
                        _gender = null;
                      });
                    },
                    color: ConstValues.firstColor[800],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear,
                          size: 17,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(Languages.translate(
                          context,
                          'clear',
                        ),
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  if (searchResults[index] == null) {
                    if (isLoading)
                      return Center(child: CircularProgressIndicator());
                    else if (hasMore && searchResults.length > 1)
                      return FlatButton(
                          onPressed: () {
                            getFriendRequests(_searchController.text);
                          },
                          child: Text(Languages.translate(
                            context,
                            'load_more',
                          )));
                    return Container();
                  }
                  return UserWidget(
                      user: User().fromMap(searchResults[index].data())
                        ..setId(searchResults[index].id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getFriendRequests(String text) async {
    if (text.isEmpty) return;
    if (!hasMore) {
      print('No More results');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });

    _authController
        .search(
      text: text,
      limit: documentLimit,
      last: lastDocument,
      gender: null != _gender ? _gender.toLowerCase() : null,
      university: _university,
      college: _college,
    )
        .then((value) {
      print('results');
      print(value.docs.length);

      setState(() {
        if (value.docs.length < documentLimit) hasMore = false;
        searchResults.insertAll(searchResults.length - 1, value.docs);
        isLoading = false;
        try {
          lastDocument = searchResults[searchResults.length - 2];
        } catch (e) {}
      });
    });
  }

  List<String> _getCases(String text) {
    List<String> l = [];
    l.add(text[0]);
    for (int i = 1; i < text.length; i++) l.add(l[i - 1] + text[i]);

    print(l);
    return l;
  }

  _bottomSheetBuild(String type,
      Future future,) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          if (type == 'gender')
            return ListView(
              children: [
                ListTile(
                  title: Text(Languages.translate(
                    context,
                    'none',
                  )),
                  onTap: () {
                    setState(() {
                      _gender = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(Languages.translate(
                    context,
                    'male',
                  )),
                  onTap: () {
                    setState(() {
                      _gender = 'Male';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(Languages.translate(
                    context,
                    'female',
                  )),
                  onTap: () {
                    setState(() {
                      _gender = 'Female';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          return FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List items = snapshot.data.data()[type];
                items.insert(0, null);
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    String item = items[index];
                    return ListTile(
                      title: Text(null != item ? item : Languages.translate(
                        context,
                        'none',
                      )),
                      onTap: () {
                        setState(() {
                          if (type == 'colleges')
                            _college = item;
                          else
                            _university = item;
                        });
                        Navigator.pop(context, item);
                      },
                    );
                  },
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          );
        });
  }

  void _search() {
    setState(() {
      lastDocument = null;
      hasMore = true;
      searchResults = [null];
    });
    getFriendRequests(_searchController.text);
  }
}

class UserWidget extends StatefulWidget {
  User user;

  UserWidget({this.user});

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  AuthController _authController = AuthController();
  FriendsController _friendsController = FriendsController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _friendsController.getFriend(
            id_friend: widget.user.id, id_user: MyUser.myUser.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool isFriend;
            if (snapshot.data.data() == null)
              isFriend = false;
            else
              isFriend = true;
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/ProfilePage',
                  arguments: {
                    'user': widget.user,
                  },
                );
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(57),
                child:CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    //TODO: Change the placeHolder
                    child: Image.asset(ConstValues.userImage),
//                    child: Container(),
                  ),
                  imageUrl: widget.user.img != null ? widget.user.img : ConstValues.userImage,
                  fit: BoxFit.cover,
                  width: 57,
                  height: 57,
                ),
              ),
              title: Text(widget.user.firstName + ' ' + widget.user.secondName),
              subtitle: Text(
                widget.user.university + ' | ' + widget.user.college,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            );
          }
          return UserPlaceholder();
        });
  }
}
