import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/pages/Group/PostWidget.dart';

class PostPage extends StatefulWidget {

  Post post;
  Group group;

  PostPage({this.post, this.group});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: PostWidget(post: widget.post,),
    );
  }
}
