import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/localization.dart';

import '../PostWidget.dart';

class PostsTab extends StatefulWidget {
  Group group;

  PostsTab(
    this.group,
  );

  @override
  _PostsTabState createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();
  bool _isVisible = true;

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  PostsController _postsController = PostsController();
  AuthController _authController = AuthController();

  List posts = ['loading'];

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
    getPinnedPosts();

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

      posts = ['loading'];
    });
    getPinnedPosts();

    getPosts();
    return Future.delayed(Duration(milliseconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            if (posts[index] == 'loading') {
              if (isLoading) return Center(child: CircularProgressIndicator());
              return Container();
            } else if (posts[index] == 'pinnedPosts')
              return Text('pinned_posts');
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
      ),
      floatingActionButton: _isVisible
          ? FloatingActionButton(
              onPressed: () {
                if (!_authController.isBan())
                  Navigator.of(context).pushNamed(
                    '/WritePostPage',
                    arguments: {
                      'group': widget.group,
                    },
                  );
                else
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(Languages.translate(
                            context,
                            'blocked',
                          )),
                          actions: [
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },
                              child: Text(
                                Languages.translate(
                                  context,
                                  'ok',
                                ),
                              ),
                            ),
                          ],
                        );
                      });
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.edit,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
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
      order: !hasMore ? Post.DATE : Post.LAST_ACTIVE,
    )
        .then((value) {
      List<DocumentSnapshot> l = value.docs;

      for (int i = 0; i < l.length; i++) {
        // try {
        //   if (l[i].data()[Post.IS_PIN]) {
        //     l.removeAt(i);
        //     i--;
        //   }
        // } catch (e) {}
      }

      l.sort((d1, d2) {
        DateTime lastActive;
        DateTime lastActive1;

        // try {
        //   lastActive = d1.data()[Post.LAST_ACTIVE].toDate();
        // } catch (e) {
        //   return 1;
        // }
        //
        // try {
        //   lastActive1 = d2.data()[Post.LAST_ACTIVE].toDate();
        // } catch (e) {
        //   return -1;
        // }

        // if (lastActive.isBefore(lastActive1)) return 1;
        return -1;
      });
      setState(() {
        posts.insertAll(posts.length - 1, l);
        isLoading = false;

        if (value.docs.length < documentLimit)
          hasMore = false;
        else
          lastDocument = value.docs.last;
      });
    });
  }

  void getPinnedPosts() {
    _postsController
        .getPinnedPosts(
      groupId: widget.group.id,
    )
        .then((value) {
      List<DocumentSnapshot> l = value.docs;
      print('pinned posts');
      print(l.length);
      if (l.isNotEmpty) {
        // print(l[0].data()['isPin']);
        setState(() {
          posts.insertAll(0, l);
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
