import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/controller/PostsController.dart';

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

  List<DocumentSnapshot> posts = [];

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

//    streams.add(_postsController.getPosts(
//      limit: documentLimit,
//      last: lastDocument,
//      group: widget.group,
//    ));
//    myposts.add([]);
//    _scrollController.addListener(() {});
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

      posts = [];
    });
    getPosts();
    return Future.delayed(Duration(milliseconds: 10));
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
            return PostWidget(
              post: Post().fromMap(posts[index].data())..setId(posts[index].id),
              group: widget.group,
            );
          },
        ),
      ),
      floatingActionButton: _isVisible
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/WritePostPage',
                  arguments: {
                    'group': widget.group,
                  },
                );
              },
              backgroundColor: Colors.indigo,
              child: Icon(
                Icons.edit,
                color: Colors.white,
              ),
            )
          : null,
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
      id_group: widget.group.id,
    )
        .then((value) {
      setState(() {
        posts.addAll(value.docs);
        print('posts');
        print(value.docs.length);
        if (value.docs.length < documentLimit) hasMore = false;
        isLoading = false;
        try {
          lastDocument = posts.last;
        } catch (e) {}
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
