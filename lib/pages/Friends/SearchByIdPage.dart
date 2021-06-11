import 'package:flutter/material.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';

import '../../localization.dart';

import 'package:share/share.dart';

class Code extends StatefulWidget {

  @override
  _CodeState createState() => _CodeState();
}

class _CodeState extends State<Code> {
  TextEditingController _controller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthController _authController = new AuthController();
  bool loading = false;
  String errorMessage = '';

  Size size;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          Languages.translate(context, 'friend_code'),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: friendCode(),
      ),
    );
  }

  friendCode() => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Form(
      key: _formKey,
      child: Column(
        children: [
          Image.asset(
            'assets/images/code.png',
          ),
          SizedBox(
            height: 300,
          ),
          Text(
            '${Languages.translate(context, "add_friend_by_code")}',
            style: TextStyle(color: Colors.black45),
          ),
          Text(
            '${Languages.translate(context, "ask_friend_for_the_code")}',
            style: TextStyle(color: Colors.black45, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(200)),
              color: Colors.grey[200],
            ),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value.trim().isEmpty) {
                  return Languages.translate(
                    context,
                    'field_required',
                  );
                }
                return null;
              },
            ),
          ),

          SizedBox(
            height: 20,
          ),

          //Error message
          errorMessage == ""
              ? Container()
              : Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            margin: EdgeInsets.symmetric(vertical: 10),
            color: Theme.of(context).errorColor,
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              if (loading) return;

              setState(() {
                errorMessage = '';
                loading = true;
              });
              var data;
              if (_formKey.currentState.validate()) {
                try {
                  data = await _authController
                      .getUserInfo(_controller.text.trim());
                } catch (e) {
                  print('\n\n\n\ne $e\n\n\n\n');
                  setState(() {
                    errorMessage = e.toString();
                  });
                }

                try {
                  if (data.data() != null) {
                    User user = User().fromMap(data.data()).setId(data.id);
                    Navigator.pushNamed(context, '/ProfilePage', arguments: {'user': user},);
                  }
                } catch (e) {
                  print('\n\n\n\nerror $e\n');
                }
              }
              setState(() {
                loading = false;
              });
            },
            child: loading
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${Languages.translate(context, 'search')}',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            )
                : Text(
              '${Languages.translate(context, 'search')}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextButton.icon(
            icon: Icon(
              Icons.share,
            ),
            label: Text(
              '${Languages.translate(context, 'share_my')}',
            ),
            onPressed: () {
              Share.share('This is my Qoiq code:\n${MyUser.myUser.id}');
            },
          ),
        ],
      ),
    ),
  );

  // myCode() => Padding(
  //   padding: const EdgeInsets.all(20.0),
  //   child: Form(
  //     key: _formKey,
  //     child: Column(
  //       children: [
  //         Image.asset(
  //           'assets/login.png',
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         Text(
  //           '${Languages.translate(context, "copy_code")}',
  //           style: TextStyle(color: Colors.black45),
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         SelectableText(
  //           '${MyUser.myUser.id}',
  //           style:
  //           TextStyle(color: Colors.black, fontSize: size.width / 25),
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         ElevatedButton.icon(
  //           icon: Icon(
  //             Icons.share,
  //             color: Colors.white,
  //           ),
  //           label: Text(
  //             '${Languages.translate(context, 'share')}',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //           onPressed: () {
  //             Share.share('This is my WhosChat code:\n${MyUser.myUser.id}');
  //           },
  //         ),
  //       ],
  //     ),
  //   ),
  // );
}