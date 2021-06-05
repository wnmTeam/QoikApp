import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:stumeapp/const_values.dart';
import 'package:url_launcher/url_launcher.dart';

class MyEditController extends TextEditingController {
  List mentions = [];
  String _oldText;

  MyEditController() {
    addListener(() {
      int cursorPos = selection.base.offset;
      print(cursorPos);
      for (int i = 0; i < mentions.length; i++) {
        print('deleting');
        if (!text.contains('@' + mentions[i]['user'].fullName)) {
          try {
            mentions.removeAt(i);
            i--;
          } catch (e) {}
        }
      }
      if (_oldText != null && _oldText.length > text.length) {
        for (int i = 0; i < mentions.length; i++) {
          if (mentions[i]['start_at'] >= cursorPos) {
            mentions[i]['start_at']--;
            mentions[i]['end_at']--;
          }
        }
      } else if (_oldText != null && _oldText.length < text.length) {
        for (int i = 0; i < mentions.length; i++) {
          if (mentions[i]['start_at'] >= cursorPos) {
            mentions[i]['start_at']++;
            mentions[i]['end_at']++;
          }
        }
      }
      _oldText = text;
    });
  }

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    List<TextSpan> content = [];
    print(text);

    if (mentions != null && mentions.length > 0)
      for (int i = 0; i < mentions.length; i++) {
        if (i == 0) {
          content.add(_normalText(text.substring(0, mentions[i]['start_at'])));
        } else
          content.add(_normalText(text.substring(
              mentions[i - 1]['end_at'], mentions[i]['start_at'])));
        content.add(_mentionText(
            text.substring(mentions[i]['start_at'], mentions[i]['end_at'])));
        if (i == mentions.length - 1)
          content.add(
              _normalText(text.substring(mentions[i]['end_at'], text.length)));
      }
    else
      content.add(_normalText(text));

    return TextSpan(style: style, children: content);
  }

  _mentionText(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(color: ConstValues.firstColor
          // decorationStyle: TextDecorationStyle(),
          ),
    );
  }

  _normalText(String text) {
    return TextSpan(
      text: text,
    );
  }

  addMention(Map mention) {
    print('add mention');
    text = text + '@' + mention['user'].fullName;
    selection = TextSelection.fromPosition(TextPosition(offset: text.length));
    mentions.add(mention);
  }
}

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.data, {
    Key key,
    this.style,
  }) : super(key: key);

  final String data;
  final TextStyle style;

  @override
  _ExpandableTextState createState() => new _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  static const defaultLines = 5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: widget.data, style: widget.style);
      final tp = TextPainter(
          text: span, textDirection: TextDirection.ltr, maxLines: defaultLines);
      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        // The text has more than three lines.
        // TODO: display the prompt message
        return Column(
          children: <Widget>[
            new Linkify(
              text: widget.data,
              style: widget.style,
              maxLines: _isExpanded ? null : defaultLines,
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: ConstValues.firstColor[500],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0.5,
                  child: Container(
                    // color: ConstValues.firstColor[300],
                    child: InkWell(
                      onTap: _handleOnTap,
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                    ),
                  )),
            )
          ],
        );
      } else {
        return Linkify(
          text: widget.data,
          style: widget.style,
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
        );
      }
    });
//    return Column(
//      children: <Widget>[
//        new Text(
//          widget.data,
//          style: widget.style,
//          maxLines: _isExpanded ? null : defaultLines,
//        ),
//        Material(
//          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//          elevation: 0.5,
//          child:  InkWell(
//            onTap: _handleOnTap,
//            child: Icon( _isExpanded ? Icons.expand_less : Icons.expand_more,
//              color: Colors.grey.withOpacity(0.6),),
//          )
//        )
//      ],
//    );
  }

  void _handleOnTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}
