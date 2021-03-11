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
  List<bool> isSelected = [true, true, true];

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
                          onTap: () async {
                            await storageController.setLang('ar');
                            MyAppState.myAppState.setState(() {
                              MyAppState.locale = Locale('ar');
                            });
                            print('ffffffffffffffffffffffffffffffffffffff');
                            print(storageController.getLang());
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text("Türkçe"),
                          onTap: () async {
                            await storageController.setLang('tr');
                            MyAppState.myAppState.setState(() {
                              MyAppState.locale = Locale('tr');
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text("English"),
                          onTap: () async {
                            await storageController.setLang('en');
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
          Divider(),
          ListTile(
            title: Text(Languages.translate(context, "change_theme")),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text(Languages.translate(context, "change_theme")),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title:
                              Text(Languages.translate(context, "light_theme")),
                          onTap: () async {
                            await storageController.setTheme('light');

                            MyAppState.myAppState.setState(() {
                              MyAppState.isDark = false;
                            });
                          },
                        ),
                        ListTile(
                          title:
                              Text(Languages.translate(context, "dark_theme")),
                          onTap: () async {
                            await storageController.setTheme('dark');
                            MyAppState.myAppState.setState(() {
                              MyAppState.isDark = true;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // ToggleButtons(
          //     children: [
          //       ListTile(
          //         leading: Icon(isSelected[0]? Icons.toggle_on:Icons.toggle_off),
          //         title: Text('Main notification'),
          //       ),
          //
          //       Icon(isSelected[1]? Icons.toggle_on:Icons.toggle_off),
          //       Icon(isSelected[2]? Icons.toggle_on:Icons.toggle_off),
          //     ],
          //   onPressed: (int index) {
          //     setState(() {
          //       isSelected[index] = !isSelected[index];
          //     });
          //   },
          //     isSelected: isSelected
          // ),


        ],
      ),
    );
  }
}
