import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/main.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(context, "setting")),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Change the language"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Change the language"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text("English"),
                          onTap: () {
                            MyAppState.myAppState.setState(() {
                              new StorageController().setLang('en');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text("عربي"),
                          onTap: () {},
                        ),
                        ListTile(
                          title: Text("تركي"),
                          onTap: () {},
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text("Change the theme"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
