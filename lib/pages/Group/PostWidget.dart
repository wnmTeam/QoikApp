import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'CommentWidget.dart';

class PostWidget extends StatefulWidget {
  DocumentSnapshot post;
  Group group;

  PostWidget({this.post, this.group});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool commentsShow = false;
  List<DocumentSnapshot> comments = [];
  List<DocumentSnapshot> newComments = [];

  int commentsLimit = 5;
  bool hasMoreComments = true;
  bool isLoading = false;
  Post _post;

  TextEditingController _commentController = TextEditingController();

  PostsController _postsController = PostsController();

  Size size;

  @override
  void initState() {
//    _setStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return StreamBuilder(
        initialData: widget.post,
        stream: _postsController.getPostChanges(
          id_post: widget.post.id,
          group: widget.group,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('f g g g g g');
            print(snapshot.data);
            _post = Post().fromMap(snapshot.data);
            return _postBuilder(_post);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  @override
  void dispose() {
    print('post ${_post.text} closed');
    super.dispose();
  }

  void _loadComments() async {
    if (!hasMoreComments) {
      print('No More Comments');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _postsController
        .getComments(
      group: widget.group,
      id_post: widget.post.id,
      last: comments.length == 0 ? null : comments[comments.length - 1],
      limit: commentsLimit,
    )
        .then((value) {
      setState(() {
        print(value.docs.length.toString());
        comments.addAll(value.docs);
        isLoading = false;
        if (value.docs.length < commentsLimit) hasMoreComments = false;
      });
    });
  }

  Widget _postBuilder(Post post) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: size.width - 24,
            child: Column(
              children: [
                ListTile(
                  onTap: () {},
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                        color: Colors.indigo[200]),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Omar alkadi',
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.more_vert,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('New User'),
                      Text(post.getStringDate),
                    ],
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: InkWell(
                    child: Text(
                      post.text,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {},
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      onPressed: () {},
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(post.likeCount.toString()),
                          ],
                        ),
                      ),
                    ),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      onPressed: () {
                        setState(() {
                          commentsShow = !commentsShow;
                        });
                        _loadComments();
                      },
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(post.commentCount.toString()),
                          ],
                        ),
                      ),
                    ),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      onPressed: () {},
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.add_box,
                              color: Colors.grey[600],
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(post.commentCount.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (commentsShow && hasMoreComments)
                  FlatButton(
                    child: Text('load more..'),
                    onPressed: () {
                      _loadComments();
                    },
                  ),
                if (commentsShow)
                  for (int i = comments.length - 1; i >= 0; i--)
                    CommentWidget(Comment().fromMap(comments[i].data())),
                if (commentsShow)
                  StreamBuilder(
                    stream: _postsController.getNewComments(
                      id_post: widget.post.id,
                      group: widget.group,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.docs.length > 0) {
                        newComments = snapshot.data.docs;
                        return Row(
                          children: [
                            SizedBox(
                              width: size.width - 24,
                              child: Column(
                                children: [
                                  for (int i = 0; i < newComments.length; i++)
                                    CommentWidget(Comment()
                                        .fromMap(newComments[i].data())),
                                ],
                              ),
                            )
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                if (commentsShow) Divider(),
                if (commentsShow)
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                            color: Colors.indigo[200]),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Comment here..'),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.indigo,
                          ),
                          onPressed: () async {
                            String text = _commentController.text;
                            if (text.isEmpty) return;
                            _commentController.clear();
                            await _postsController.createComment(
                              text: text,
                              post_id: widget.post.id,
                              group: widget.group,
                            );
                          })
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//  Future getComments() async {
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

}
