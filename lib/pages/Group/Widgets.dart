import 'package:flutter/material.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../const_values.dart';
import '../../localization.dart';

class SearchToTag extends StatefulWidget {
  String groupId;

  SearchToTag({this.groupId});

  @override
  _SearchToTagState createState() => _SearchToTagState();
}

class _SearchToTagState extends State<SearchToTag> {
  bool isLoading = false;
  int documentLimit = 30;
  DocumentSnapshot lastDocument;

  AuthController _authController = AuthController();

  List<DocumentSnapshot> searchResults = [];

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          autofocus: true,
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
          onChanged: (value) {
            if (value.isNotEmpty) {
              _search();
            }
          },
          style: TextStyle(color: Colors.white70),
          textInputAction: TextInputAction.search,
        ),
      ),
      body: !isLoading
          ? ListView.builder(
              itemBuilder: _userBuilder,
              itemCount: searchResults.length,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void _search() {
    setState(() {
      searchResults = [];
    });
    getTagedUsers(_searchController.text);
  }

  getTagedUsers(String text) async {
    if (text.isEmpty || text.length < 2) return;

    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
//      posts.add(null);
    });

    _authController
        .getTagedUsers(
      text: text,
      limit: documentLimit,
      groupId: widget.groupId,
    )
        .then((value) {
      print('results');
      print(value.docs.length);

      setState(() {
        searchResults = value.docs;
        isLoading = false;
      });
    });
  }

  Widget _userBuilder(BuildContext context, int index) {
    User user = User()
        .fromMap(searchResults[index].data())
        .setId(searchResults[index].id);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      onTap: () {
        Navigator.pop(context, user);
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: CachedNetworkImage(
          placeholder: (context, url) => Center(
            child: Image.asset(ConstValues.userImage),
          ),
          imageUrl: user.img != null ? user.img : ConstValues.userImage,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      ),
      title: Text(user.firstName + ' ' + user.secondName),
    );
  }
}
