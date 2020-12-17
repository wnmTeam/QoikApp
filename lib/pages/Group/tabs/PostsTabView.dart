import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/PostsController.dart';

import '../PostWidget.dart';

class PostsTab extends StatefulWidget {
  Group group;

  PostsTab(this.group);

  @override
  _PostsTabState createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;

  bool tt = true;

  PostsController _postsController = PostsController();

  List<DocumentChange> posts = [];

  @override
  void initState() {
//    _scrollController.addListener(() {
//      double maxScroll = _scrollController.position.maxScrollExtent;
//      double currentScroll = _scrollController.position.pixels;
//      double delta = MediaQuery.of(context).size.height * 0.20;
//      if (maxScroll - currentScroll <= delta) {
//        getPosts();
//      }
//    });
    _scrollController.addListener(() {});
//    getPosts();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: _postsController.getPosts(
            limit: documentLimit,
            last: lastDocument,
            group: widget.group,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              snapshot.data.docChanges.forEach((element) {
                if (element.type == DocumentChangeType.modified) {
                  List<DocumentChange> temp = List();
//                  temp.add(element);
//                  posts.replaceRange(
//                      element.newIndex, element.newIndex + 1, temp);
                }
              });
              print(snapshot.data.docChanges.length);
              for (int i = 0; i < snapshot.data.docChanges.length; i++)
                if (snapshot.data.docChanges[i].type ==
                    DocumentChangeType.modified) {
                  List<DocumentChange> temp = List();
                  temp.add(snapshot.data.docChanges[i]);
                  posts.replaceRange(snapshot.data.docChanges[i].newIndex,
                      snapshot.data.docChanges[i].newIndex + 1, temp);
                } else
                  posts.add(snapshot.data.docChanges[i]);
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                if (posts[index] == null)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                return PostWidget(
                  post: Post()
                      .fromMap(posts[index].doc.data())
                      .setId(posts[index].doc.id),
                  group: widget.group,
                );
              },
            );
//              posts.length == 0
//                ? Center(
//                    child: Text('No Data...'),
//                  )
//                : ListView.builder(
//                    controller: _scrollController,
//                    itemCount: posts.length,
//                    itemBuilder: (context, index) {
//                      if (posts[index] == null)
//                        return Center(
//                          child: Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: CircularProgressIndicator(),
//                          ),
//                        );
//                      return PostWidget(
//                        post: Post().fromMap(posts[index].data()),
//                      );
//                    },
//                  );
          }),
      floatingActionButton: tt
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/WritePostPage', arguments: {
                  'group': widget.group,
                });
              },
              backgroundColor: Colors.indigo,
              child: Icon(
                Icons.edit,
                color: Colors.white,
              ),
            )
          : Container(),
    );
  }

//  Future getPosts() async {
//    if (!hasMore) {
//      print('No More Posts');
//      return;
//    }
//    if (isLoading) {
//      return;
//    }
//    log('hhhhhhhhhhhhhhhhhh', name: 'get Posts');
//    setState(() {
//      isLoading = true;
//    });
//    Future f = _postsController.getPosts(
//      limit: documentLimit,
//      last: lastDocument,
//      group: widget.group,
//    );
//    return f.then((querySnapshot) {
//      print('querySnapshot.docs.length' + querySnapshot.docs.length.toString());
//      if (querySnapshot.docs.length < documentLimit) {
//        hasMore = false;
//      }
//      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
//      posts.removeAt(posts.length - 1);
//      posts.addAll(querySnapshot.docs);
//      if (hasMore) posts.add(null);
//      setState(() {
//        isLoading = false;
//      });
//    });
//  }

  @override
  bool get wantKeepAlive => true;
}
