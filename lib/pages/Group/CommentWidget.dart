import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/Sounds.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/main.dart';
import 'package:stumeapp/pages/ImageView/ImageView.dart';
import 'package:stumeapp/pages/widgets/FileWidget.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

// import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../const_values.dart';

class CommentWidget extends StatefulWidget {
  Comment comment;
  Group group;
  Post post;

  Function addPoint;
  Function deletePoint;
  Function deleteComment;
  Function updateComment;

  var doc;

  CommentWidget({
    this.comment,
    this.post,
    this.group,
    this.addPoint,
    this.deletePoint,
    this.deleteComment,
    this.updateComment,
    this.doc,
  });

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  Future _getUser;
  PostsController _postsController = PostsController();
  AuthController _authController = AuthController();

  User user;
  bool _isCommentExpended = false;

  bool edit = false;

  TextEditingController _controller = TextEditingController();

  // Sounds sounds = Sounds();

  final Color baseColor = MyAppState.isDark ? Colors.black87 : Colors.grey[100];
  final Color highlightColor =
      MyAppState.isDark ? Colors.black54 : Colors.grey[300];

  @override
  void dispose() {
    // sounds.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller.text = widget.comment.text;
    _getUser = _authController.getUserInfo(widget.comment.idOwner);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUser,
        builder: (context, snapshot) {
          if (user != null) {
            return _commentBuilder();
          }
          if (snapshot.hasData) {
            user = User().fromMap(snapshot.data)..setId(snapshot.data.id);
            return _commentBuilder();
          }
          return UserPlaceholder();
        });
  }

  Widget _commentBuilder() {
    return Container(
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ProfilePage',
            arguments: {'user': user},
          );
        },
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: widget.comment.text))
              .then((value) {
            // Toast.show(
            //   Languages.translate(context, 'text_copied'),
            //   context,
            //   duration: Toast.LENGTH_LONG,
            //   backgroundColor: Theme.of(context).primaryColor,
            // );

            // Scaffold.of(context).showSnackBar(
            //     SnackBar(content:Text('The text copied')));
          });
        },
        contentPadding: EdgeInsets.zero,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(57),
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
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isCommentExpended = !_isCommentExpended;
                        });
                      },
                      child: !edit
                          ? Linkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  throw 'Could not launch $link';
                                }
                              },
                              linkStyle: TextStyle(
                                color: Colors.blue,
                              ),
                              options: LinkifyOptions(humanize: false),
                              text: widget.comment.text,
                              maxLines: _isCommentExpended ? 1000 : 3,
                              overflow: TextOverflow.ellipsis,
                              // style: TextStyle(
                              //   color: Colors.grey[700],
                              // ),
                            )
                          : Row(
                              children: [
                                SizedBox(
                                    width: 180,
                                    height: 50,
                                    child: TextField(
                                      autofocus: true,
                                      controller: _controller,
                                      decoration: InputDecoration(),
                                    )),
                                ElevatedButton(
                                    onPressed: () async {
                                      await _postsController.updateComment(
                                        text: _controller.text,
                                        comment_id: widget.comment.id,
                                        post_id: widget.post.id,
                                        group_id: widget.group.id,
                                      );
                                      // setState(() {
                                      var d = await _postsController.getComment(
                                        comment_id: widget.comment.id,
                                        post_id: widget.post.id,
                                        group_id: widget.group.id,
                                      );
                                      setState(() {
                                        edit = false;
                                      });
                                      widget.updateComment(d);
                                      // });
                                    },
                                    child: Text('save')),
                              ],
                            ),
                    ),
                  ),
                  widget.comment.id == widget.post.commentPointed
                      ? InkWell(
                          onTap: () async {
                            if (widget.post.idOwner == MyUser.myUser.id) {
                              await _postsController.deletePoint(
                                groupId: widget.group.id,
                                comment: widget.comment,
                                post: widget.post,
                              );
                              print('delete point');
                              await _authController.deletePoint(
                                  id_user: widget.comment.idOwner);
                              widget.deletePoint();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            child: Icon(
                              Icons.star,
                              color: Colors.amber[300],
                              size: 30,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              if (widget.comment.image != null)
                GestureDetector(
                  onTap: () {
                    print("------------------------");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ImageView(widget.comment.image)));
                  },
                  child: Hero(
                    tag: widget.comment.image,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Center(
                        child: Shimmer.fromColors(
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.width / 2.5,
                            color: Colors.grey[200],
                          ),
                        ),
                      ),
                      imageUrl: widget.comment.image,
                    ),
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              if (widget.comment.file != null) FileWidget(widget.comment.file),
              SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  StreamBuilder(
                      stream: _postsController.isLikeComment(
                        userId: _authController.getUser.uid,
                        group: widget.group,
                        postId: widget.post.id,
                        commentId: widget.comment.id,
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
                                ' ' +
                                    Languages.translate(
                                      context,
                                      'like',
                                    ) +
                                    ' ',
                                style: TextStyle(
                                  color: widget.comment.isLiked
                                      ? Colors.white
                                      : ConstValues.secondColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: widget.comment.isLiked
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.7)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onTap: () async {
                            await _postsController.setLikeToComment(
                              userId: _authController.getUser.uid,
                              group: widget.group,
                              postId: widget.post.id,
                              commentId: widget.comment.id,
                            );
                            if (widget.comment.isLiked) {
                              // sounds.likeSound();
                            } else {
                              // sounds.disLikeSound();
                            }
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
                                ' ' +
                                    Languages.translate(
                                      context,
                                      'give_point',
                                    ) +
                                    ' ',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            decoration: BoxDecoration(
                              // color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onTap: () async {
                            await _postsController.addPoint(
                              groupId: widget.group.id,
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
                  SizedBox(
                    width: 0,
                  ),
                  PopupMenuButton(
                    // child: Icon(Icons.more_horiz),
                    padding: EdgeInsets.zero,
                    icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.more_horiz,
                              color: ConstValues.secondColor),
                        )),
                    itemBuilder: (context) => [
                      if (MyUser.myUser.id == widget.comment.idOwner ||
                          MyUser.myUser.isAdmin())
                        PopupMenuItem(
                          value: 1,
                          child: Text('Edit'),
                        ),
                      if (MyUser.myUser.id == widget.comment.idOwner ||
                          MyUser.myUser.isAdmin())
                        PopupMenuItem(
                          value: 2,
                          child: Text('Delete'),
                        ),
                      if (MyUser.myUser.id != widget.comment.idOwner)
                        PopupMenuItem(
                          value: 3,
                          child: Text('Report'),
                        ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 2:
                          _deleteComment();
                          break;
                        case 1:
                          // _editComment();
                          setState(() {
                            edit = true;
                          });
                          break;
                        case 3:
                          _reportComment();
                          break;
                      }
                    },
                  ),
                  // SizedBox(
                  //   height: 30,

                  // child: DropdownButtonHideUnderline(
                  //
                  //   child: DropdownButton<String>(
                  //     value: null,
                  //     icon: Container(
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  //         child: Icon(Icons.more_horiz),
                  //       ),
                  //       decoration: BoxDecoration(
                  //         color: Colors.grey[200],
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //     ),isExpanded: false,
                  //
                  //     onChanged: (String newValue) {
                  //       switch (newValue) {
                  //         case 'Delete':
                  //           _deleteComment();
                  //           break;
                  //         case 'Edit':
                  //           _editComment();
                  //           break;
                  //         case 'Report':
                  //           _reportComment();
                  //           break;
                  //       }
                  //     },
                  //     items: <String>[
                  //       if (MyUser.myUser.id == widget.post.idOwner ||
                  //           MyUser.myUser.isAdmin())
                  //         'Edit',
                  //       if (MyUser.myUser.id == widget.post.idOwner ||
                  //           MyUser.myUser.isAdmin())
                  //         'Delete',
                  //       if (MyUser.myUser.id != widget.post.idOwner) 'Report',
                  //     ].map<DropdownMenuItem<String>>((String value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value,
                  //         child: Text(value),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteComment() async {
    await _postsController.deleteComment(
      post_id: widget.post.id,
      comment_id: widget.comment.id,
      group_id: widget.group.id,
    );
    widget.deleteComment(widget.doc);
  }

  void _editComment() {}

  void _reportComment() {}
}
