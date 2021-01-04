import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentWidget extends StatefulWidget {
  Comment comment;
  Group group;
  Post post;

  Function addPoint;

  CommentWidget({this.comment, this.post, this.group, this.addPoint});

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  Future _getUser;
  PostsController _postsController = PostsController();
  AuthController _authController = AuthController();

  User user;

  @override
  void initState() {
    _getUser = _authController.getUserInfo(widget.comment.idOwner);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUser,
        builder: (context, snapshot) {
          if (user != null) {
            return _postBuilder();
          }
          if (snapshot.hasData) {
            user = User().fromMap(snapshot.data);
            return _postBuilder();
          }
          return Container();
        });
  }

  Widget _postBuilder() {
    return Container(
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ProfilePage',
            arguments: {'id_user': widget.comment.idOwner, 'user': user},
          );
        },
        contentPadding: EdgeInsets.zero,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(22)),
                color: Colors.indigo[200]),
          ),
        ),
        title: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 12,
              ),
              Text(user.firstName + ' ' + user.secondName),
              SizedBox(
                height: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.comment.text,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  widget.comment.id == widget.post.commentPointed
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 15),
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 30,
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  StreamBuilder(
                      stream: _postsController.isLikeComment(
                        id_user: _authController.getUser.uid,
                        group: widget.group,
                        id_post: widget.post.id,
                        id_comment: widget.comment.id,
                      ),
                      builder: (context, snapshot) {
                        print(snapshot.data);

                        if (snapshot.hasData) {
                          if (snapshot.data.data() != null &&
                              snapshot.data.data()['exists'] == 1)
                            widget.comment.isLiked = true;
                          else
                            widget.comment.isLiked = false;
                        }
                        return InkWell(
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 6),
                              child: Text(
                                ' Like ',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: widget.comment.isLiked
                                  ? Color.fromARGB(100, 100, 100, 255)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onTap: () async {
                            await _postsController.setLikeToComment(
                              id_user: _authController.getUser.uid,
                              group: widget.group,
                              id_post: widget.post.id,
                              id_comment: widget.comment.id,
                            );
                          },
                        );
                      }),
                  SizedBox(
                    width: 6,
                  ),
                  _authController.getUser.uid == widget.post.idOwner &&
                          _authController.getUser.uid !=
                              widget.comment.idOwner &&
                          widget.post.commentPointed == null
                      ? InkWell(
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 6),
                              child: Text(
                                ' Give Point ',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onTap: () async {
                            await _postsController.addPoint(
                              id_group: widget.group.id,
                              comment: widget.comment,
                              post: widget.post,
                            );
                            print('add point');
                            await _authController.addPoint(
                                id_user: widget.comment.idOwner);
                            widget.addPoint(widget.comment.id);
                          },
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
