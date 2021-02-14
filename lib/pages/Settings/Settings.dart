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
    StorageController storageController = new StorageController();

    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(context, "setting")),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(Languages.translate(context, "change_lang")),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text(Languages.translate(context, "change_lang")),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text("عربي"),
                          onTap: () {
                            //TODO: Save language code in sharedPreferences
                            storageController.setLang('ar');
                            MyAppState.myAppState.setState(() {
                              MyAppState.locale = Locale('ar');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text("Türkçe"),
                          onTap: () {
                            storageController.setLang('tr');
                            MyAppState.myAppState.setState(() {
                              MyAppState.locale = Locale('tr');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text("English"),
                          onTap: () {
                            //TODO: Save language code in sharedPreferences
                            storageController.setLang('en');
                            MyAppState.myAppState.setState(() {
                              MyAppState.locale = Locale('en');
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          //TODO: Change The Theme
          // Divider(),
          // ListTile(
          //   title: Text("Change the theme"),
          //   onTap: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           scrollable: true,
          //           title: Text("Change the theme"),
          //           content: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               ListTile(
          //                 title: Text("Normal theme"),
          //                 onTap: () {},
          //               ),
          //               ListTile(
          //                 title: Text("Dark theme"),
          //                 onTap: () {},
          //               ),
          //             ],
          //           ),
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
