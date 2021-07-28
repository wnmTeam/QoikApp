import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/localization.dart';

class EditPostPage extends StatefulWidget {
  Post post;
  Group group;
  Function editPost;

  EditPostPage({this.post, this.group, this.editPost});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  TextEditingController _postTextController;

  PostsController _postsController = PostsController();

  bool loading = false;

  @override
  void initState() {
    _postTextController = TextEditingController(text: widget.post.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(context, "Post_editing")),
        centerTitle: true,
        actions: [
          Tooltip(
            message: Languages.translate(context, "save"),
            child: FlatButton(
                onPressed: () async {
                  if (loading) return;

                  setState(() {
                    loading = true;
                  });
                  await _postsController.updatePost(
                    groupId: widget.group.id,
                    postId: widget.post.id,
                    text: _postTextController.text,
                  );
                  Navigator.pop(
                    context,
                    _postTextController.text,
                  );
                },
                child: Icon(
                  loading ? Icons.watch_later_outlined : Icons.save,color: Colors.white70,
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              // color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: Languages.translate(
                    context,
                    'type_some_thing',
                  ),
                ),
                autofocus: true,
                controller: _postTextController,
                maxLines: 17,
              ),
            ),
            // Container(
            //   alignment: Alignment.center,
            //   child: RaisedButton(
            //       onPressed: () async {
            //         setState(() {
            //           loading = true;
            //         });
            //         await _postsController.updatePost(
            //           id_group: widget.group.id,
            //           id_post: widget.post.id,
            //           text: _postTextController.text,
            //         );
            //         Navigator.pop(
            //           context,
            //           _postTextController.text,
            //         );
            //       },
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30.0),
            //       ),
            //       color: ConstValues.firstColor,
            //       child: Text(
            //         loading
            //             ? Languages.translate(
            //                 context,
            //                 'whaiting',
            //               )
            //             : Languages.translate(
            //                 context,
            //                 'save',
            //               ),
            //         style: TextStyle(
            //           fontSize: 20,
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       )),
            // ),
          ],
        ),
      ),
    );
  }
}
