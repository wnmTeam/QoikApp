import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/const_values.dart';

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
