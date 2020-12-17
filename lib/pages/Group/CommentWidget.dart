import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Comment.dart';

class CommentWidget extends StatefulWidget {
  Comment comment;

  CommentWidget(this.comment);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        onTap: () {},
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
              Text('Omar alkadi'),
              SizedBox(
                height: 3,
              ),
              Text(
                widget.comment.text,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: 4,
              ),
              InkWell(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6),
                    child: Text(
                      'Like  ${widget.comment.likeCount.toString()}',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
