import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/pages/Group/PostWidget.dart';

class HomeTab extends StatefulWidget {
  Group group;

  HomeTab(
    this.group,
  );

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();
  bool _isVisible = true;

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  PostsController _postsController = PostsController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> posts = [null];

//  List<List<DocumentChange>> myposts = [];
//  List<Stream> streams = [];

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible == true) {
          print("**** ${_isVisible} up"); //Move IO away from setState
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            print("**** ${_isVisible} down"); //Move IO away from setState
            setState(() {
              _isVisible = true;
            });
          }
        }
      }

      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getPosts();
      }
    });

    getPosts();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> refresh() {
    setState(() {
      _isVisible = true;

      isLoading = false;
      hasMore = true;
      lastDocument = null;

      posts = [null];
    });
    getPosts();
    return Future.delayed(Duration(milliseconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          if (index == posts.length - 1) {
            if (isLoading) return Center(child: CircularProgressIndicator());
            return Container(
              height: 30,
            );
          }
          return PostWidget(
            post: Post().fromMap(posts[index].data())..setId(posts[index].id),
              group: widget.group,
              deletePost: () {
                setState(() {
                  posts.removeAt(index);
                });
              },
            updatePost: (d) {
              setState(() {
                posts[index] = d;
              });
            },
          );
        },
      ),
    );
    // floatingActionButton:
    // _isVisible && MyUser.myUser.userTag == 'admin' ?
    // FloatingActionButton(
    //         onPressed: () {
    //           if (!_authController.isBan())
    //             Navigator.of(context).pushNamed(
    //               '/WritePostPage',
    //               arguments: {
    //                 'group': widget.group,
    //               },
    //             );
    //           else
    //             showDialog(
    //                 context: context,
    //                 builder: (context) {
    //                   return AlertDialog(
    //                     title: Text(Languages.translate(
    //                       context,
    //                       'blocked',
    //                     )),
    //                     actions: [
    //                       FlatButton(
    //                         onPressed: () {
    //                           Navigator.pop(
    //                             context,
    //                           );
    //                         },
    //                         child: Text(
    //                           Languages.translate(
    //                             context,
    //                             'ok',
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   );
    //                 });
    //         },
    //         backgroundColor: ConstValues.firstColor,
    //         child: Icon(
    //           Icons.edit,
    //           color: Colors.white,
    //         ),
    //       )
    //     : null,
    // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

  }

  getPosts() async {
    if (!hasMore) {
      print('No More Posts');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _postsController
        .getPosts(
      limit: documentLimit,
      last: lastDocument,
      groupId: widget.group.id,
    )
        .then((value) {
      setState(() {
        posts.insertAll(posts.length - 1, value.docs);
        isLoading = false;

        if (value.docs.length < documentLimit)
          hasMore = false;
        else
          lastDocument = value.docs.last;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
