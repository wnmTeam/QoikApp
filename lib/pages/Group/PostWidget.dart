import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/Sounds.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/ImageView/ImageView.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CommentWidget.dart';

class PostWidget extends StatefulWidget {
  Post post;
  Group group;
  Function deletePost;
  Function updatePost;

  PostWidget({
    this.post,
    this.group,
    this.deletePost,
    this.updatePost,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with AutomaticKeepAliveClientMixin {
  bool commentsShow = false;
  List<DocumentSnapshot> comments = [];
  List<DocumentSnapshot> newComments = [];

  int commentsLimit = 5;
  bool hasMoreComments = true;
  bool isLoading = false;

  bool _isExbended = false;
  bool _isCommentExpended = false;

  TextEditingController _commentController = TextEditingController();

  PostsController _postsController = PostsController();
  AuthController _authController = AuthController();

  Size size;

  User user;

  Future _getUser;

  bool tag = true;
  Sounds sounds = Sounds();

  Color buttonsColor;

  @override
  void dispose() {
    sounds.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getUser = _authController.getUserInfo(widget.post.idOwner);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

//  @override
//  Widget build(BuildContext context) {
//    size = MediaQuery.of(context).size;
//    return FutureBuilder(
//        future: _getUser,
//        builder: (context, snapshot) {
//          if (user != null) {
//            comments.insertAll(0, newComments);
//            newComments = [];
//            return _postBuilder(widget.post);
//          }
//          if (snapshot.hasData) {
//            user = User().fromMap(snapshot.data)..setId(snapshot.data.id);
//            return _postBuilder(widget.post);
//          }
//          return Container();
//        });
//  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    buttonsColor = Colors.grey[200];

    return _postBuilder(widget.post);
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
      last: comments.length == 0 ? null : comments.last,
      limit: commentsLimit,
    )
        .then((value) {
      setState(() {
        print('comments');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: size.width - 24,
            child: Column(
              children: [
                FutureBuilder(
                    future: _getUser,
                    builder: (context, snapshot) {
                      if (user != null) {
                        comments.insertAll(0, newComments);
                        newComments = [];
                        return _userWidget();
                      }
                      if (snapshot.hasData) {
                        user = User().fromMap(snapshot.data)
                          ..setId(snapshot.data.id);
                        return _userWidget();
                      }
                      return UserPlaceholder();
//                    return CircularProgressIndicator();
                    }),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                post.text.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExbended = !_isExbended;
                          });
                        },
                        onLongPress: () {
                          Clipboard.setData(
                              ClipboardData(text: post.text))
                              .then((value) {
                            Toast.show(
                              Languages.translate(
                                  context, 'text_copied'),
                              context,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Theme
                                  .of(context)
                                  .primaryColor,
                            );

                            // Scaffold.of(context).showSnackBar(
                            //     SnackBar(content:Text('The text copied')));
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 10,
                          ),
                          child: Linkify(
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
                            text: post.text,
                            maxLines: _isExbended ? 10000 : 5,
                            overflow: TextOverflow.ellipsis,

                          ),
                        ),
                      ),
                      !_isExbended
                          ? post.text.length > 200
                          ? InkWell(
                        onTap: () {
                          setState(() {
                            _isExbended = !_isExbended;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 10,
                          ),
                          child: Text(
                            "عرض المزيد",
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                          : Container()
                          : Container(),
                    ],
                  ),
                )
                    : Container(),
                SizedBox(
                  height: 6,
                ),
                if (widget.post.images != null && widget.post.images.length > 0)
                  imagesBuilder(widget.post.images),
                if (widget.post.images != null && widget.post.images.length > 0)
                  SizedBox(
                    height: 6,
                  ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StreamBuilder(
                      stream: _postsController.isLikePost(
                          id_user: _authController.getUser.uid,
                          group: widget.group,
                          id_post: widget.post.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.data() != null &&
                              snapshot.data.data()['exists'] == 1)
                            widget.post.setIsLiked = true;
                          else
                            widget.post.setIsLiked = false;
                        }
                        return RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          onPressed: () async {
                            setState(() {
                              if (!widget.post.isLiked)
                                widget.post.likeCount++;
                              else
                                widget.post.likeCount--;
                            });
                            await _postsController.setLike(
                                id_user: _authController.getUser.uid,
                                group: widget.group,
                                id_post: widget.post.id);

                            DocumentSnapshot d =
                            await _postsController.getPostChanges(
                              id_post: widget.post.id,
                              group: widget.group,
                            );
                            if (d.data() != null) {
                              widget.updatePost(d);

                              if (widget.post.isLiked) {
                                sounds.likeSound();
                              } else {
                                sounds.disLikeSound();
                              }
                            }
                          },
                          color: widget.post.getIsLiked
                              ? Theme
                              .of(context)
                              .primaryColor
                              .withOpacity(0.7)
                              : buttonsColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/like.svg',
                                  width: 20,
                                  height: 20,
                                  color: widget.post.getIsLiked
                                      ? Colors.white
                                      : ConstValues.secondColor,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(post.likeCount.toString(),
                                  style: TextStyle(
                                    color: widget.post.getIsLiked
                                        ? Colors.white : ConstValues
                                        .secondColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                      color: buttonsColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: ConstValues.secondColor,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(post.commentCount.toString(),
                              style: TextStyle(color: ConstValues.secondColor,
                              ),),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: _postsController.isFollowPost(
                          id_user: _authController.getUser.uid,
                          group: widget.group,
                          id_post: widget.post.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.data() != null &&
                              snapshot.data.data()['exists'] == 1)
                            widget.post.setIsFollowed = true;
                          else
                            widget.post.setIsFollowed = false;
                        }
                        return RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          onPressed: () async {
                            await _postsController.followPost(
                              id_user: _authController.getUser.uid,
                              group: widget.group,
                              id_post: widget.post.id,
                            );

                            DocumentSnapshot d =
                            await _postsController.getPostChanges(
                              id_post: widget.post.id,
                              group: widget.group,
                            );
                            if (d.data() != null)
                              setState(() {
                                widget.post = Post().fromMap(d.data())
                                  ..setId(widget.post.id);
                              });
                          },
                          color: widget.post.getIsFollowed
                              ? Theme
                              .of(context)
                              .primaryColor
                              .withOpacity(0.7)
                              : buttonsColor
                              .withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.add_box,
                                  color: widget.post.getIsFollowed ? Colors
                                      .white : ConstValues.secondColor,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(post.followCount.toString(),
                                  style: TextStyle(
                                    color: widget.post.getIsFollowed ? Colors
                                        .white : ConstValues.secondColor,
                                  ),),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (commentsShow && hasMoreComments)
                  FlatButton(
                    child: Text(Languages.translate(
                      context,
                      'load_more',
                    )),
                    onPressed: () {
                      _loadComments();
                    },
                  ),
                if (commentsShow)
                  for (int i = comments.length - 1; i >= 0; i--)
                    CommentWidget(
                      comment: Comment().fromMap(comments[i].data())
                        ..setId(comments[i].id),
                      post: widget.post,
                      group: widget.group,
                      addPoint: (id) async {
                        var d = await _postsController.getPostChanges(
                          group: widget.group,
                          id_post: widget.post.id,
                        );
                        if (d.data() != null) widget.updatePost(d);
                      },
                      deletePoint: () async {
                        var d = await _postsController.getPostChanges(
                          group: widget.group,
                          id_post: widget.post.id,
                        );
                        if (d.data() != null) widget.updatePost(d);
                      },
                    ),
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
                                    CommentWidget(
                                      comment: Comment()
                                          .fromMap(newComments[i].data())
                                        ..setId(newComments[i].id),
                                      post: widget.post,
                                      group: widget.group,
                                      addPoint: (id) async {
                                        var d = await _postsController
                                            .getPostChanges(
                                          group: widget.group,
                                          id_post: widget.post.id,
                                        );
                                        if (d.data() != null)
                                          widget.updatePost(d);
                                      },
                                      deletePoint: () async {
                                        var d = await _postsController
                                            .getPostChanges(
                                          group: widget.group,
                                          id_post: widget.post.id,
                                        );
                                        if (d.data() != null)
                                          widget.updatePost(d);
                                      },
                                    ),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(57),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Center(
                            child: Image.asset(ConstValues.userImage),
//                    child: Container(),
                          ),
                          imageUrl: MyUser.myUser.img,
                          fit: BoxFit.cover,
                          width: 45,
                          height: 45,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: Languages.translate(
                                context,
                                'write_comment',
                              )),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                        onPressed: () async {
                          String text = _commentController.text;
                          if (text.isEmpty) return;
                          _commentController.clear();
                          if (!_authController.isBan()) {
                            await _postsController.createComment(
                              text: text,
                              post: widget.post,
                              group: widget.group,
                            );
                            sounds.commentSound();
                          } else
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
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _userWidget() {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/ProfilePage',
          arguments: {'id_user': widget.post.idOwner, 'user': user},
        );
      },
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: CachedNetworkImage(
          placeholder: (context, url) => Center(
            child: Image.asset(ConstValues.userImage),
          ),
          imageUrl: user.img != null ? user.img : ConstValues.userImage,
          fit: BoxFit.cover,
          width: 55,
          height: 55,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.firstName + ' ' + user.secondName,
          ),
          SizedBox(
            height: 30,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: null,
                icon: Icon(Icons.more_horiz),
                onChanged: (String newValue) {
                  switch (newValue) {
                    case 'Delete':
                      _deletePost();
                      break;
                    case 'Edit':
                      _editPost();
                      break;
                    case 'Report':
                      _reportPost();
                      break;
                  }
                },
                items: <String>[
                  if (MyUser.myUser.id == widget.post.idOwner) 'Edit',
                  if (MyUser.myUser.id == widget.post.idOwner) 'Delete',
                  if (MyUser.myUser.id != widget.post.idOwner) 'Report',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.userTag == 'admin'
                ? Languages.translate(
              context,
              user.userTag,
            )
                : Languages.translate(
              context,
              user.tag,
            ),
            style: TextStyle(fontSize: 12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              widget.post.getStringDate,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  _deletePost() async {
    await _postsController.deletePost(
      id_group: widget.group.id,
      id_post: widget.post.id,
    );
    widget.deletePost();
  }

  _reportPost() {}

  _editPost() async {
    await Navigator.pushNamed(
      context,
      '/EditPostPage',
      arguments: {
        'post': widget.post,
        'group': widget.group,
        'editPost': (text) {}
      },
    );

    DocumentSnapshot d = await _postsController.getPostChanges(
      id_post: widget.post.id,
      group: widget.group,
    );
    if (d.data() != null) widget.updatePost(d);
  }

  Widget imagesBuilder(List<dynamic> images) {
    List<Widget> dd = new List();

    for (String image in images) {
      dd.add(GestureDetector(
        onTap: () {
          print("------------------------");
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ImageView(image)));
        },
        child: Hero(
          tag: image,
          child: CachedNetworkImage(
            placeholder: (context, url) => Center(
              child: Container(
                width: size.width,
                height: size.width - 100,
                color: Colors.grey[200],
              ),
            ),
            imageUrl: image,
          ),
        ),
      ));
      dd.add(SizedBox(
        height: 2,
      ));
    }
    return Column(
      children: dd,
    );
  }
}
