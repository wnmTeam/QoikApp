import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/main.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<bool> notifications = [true, true, true];

  bool xx = true;
  StorageController storageController = new StorageController();
  AuthController authController = new AuthController();

  // getAllNotificationSetting() async {
  //   var d = await authController.getAllNotificationSetting();
  //   print("d $d");
  //   print(notifications);
  //   notifications = await storageController.getAllNotificationSetting();
  //   print(notifications);
  //   return notifications;
  // }

  @override
  Widget build(BuildContext context) {
    // getAllNotificationSetting();
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(context, "setting")),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          ListTile(
            title: Text(Languages.translate(context, "change_lang")),
            leading: Icon(Icons.translate_outlined),
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
                          selected: storageController.getLang() == 'ar',
                          onTap: () async {
                            await storageController.setLang('ar');
                            MyAppState.myAppState.setState(() {
                              MyAppState.locale = Locale('ar');
                            });
                            print(storageController.getLang());
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text("Türkçe"),
                          selected: storageController.getLang() == 'tr',
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
                          selected: storageController.getLang() == 'en',
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
          // Divider(),
          // ListTile(
          //   title: Text(Languages.translate(context, "change_theme")),
          //   leading: Icon(Icons.style_outlined),
          //   onTap: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           scrollable: true,
          //           title: Text(Languages.translate(context, "change_theme")),
          //           content: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               ListTile(
          //                 title:
          //                 Text(Languages.translate(context, "light_theme")),
          //                 selected: storageController.getTheme() == 'light',
          //                 onTap: () async {
          //                   await storageController.setTheme('light');
          //
          //                   MyAppState.myAppState.setState(() {
          //                     MyAppState.isDark = false;
          //                   });
          //                   Navigator.pop(context);
          //                 },
          //               ),
          //               ListTile(
          //                 title:
          //                 Text(Languages.translate(context, "dark_theme")),
          //                 selected: storageController.getTheme() == 'dark',
          //                 onTap: () async {
          //                   await storageController.setTheme('dark');
          //                   MyAppState.myAppState.setState(() {
          //                     MyAppState.isDark = true;
          //                   });
          //                   Navigator.pop(context);
          //                 },
          //               ),
          //             ],
          //           ),
          //         );
          //       },
          //     );
          //   },
          // ),
          Divider(),
          ListTile(
            title: Text(Languages.translate(context, "notifications")),
            leading: Icon(Icons.notifications_active_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text(Languages.translate(context, "notifications")),
                    actions: [
                      ElevatedButton(
                          onPressed: () async {
                            await authController
                                .setAllNotificationSetting(<String, bool>{
                              "chat&roomsNotif": true,
                              "groupsNotif": true,
                              "homeNotif": false,
                            });
                          },
                          child: Text("Save"))
                    ],
                    content: StatefulBuilder(
                      builder: (context, setState) {
                        return FutureBuilder(
                          future: authController.getAllNotificationSetting(),
                          builder: (context, snapshot) {
                            print("snapshot $snapshot");
                            print(
                                "snapshot.connectionState ${snapshot.connectionState}");
                            print("snapshot.hasData ${snapshot.hasData}");
                            print("snapshot.data ${snapshot.data}");
                            print(
                                "snapshot.requireData ${snapshot.requireData}");
                            print(
                                "snapshot.runtimeType ${snapshot.runtimeType}");
                            print("snapshot.hasError ${snapshot.hasError}");

                            var data;
                            try {
                              data = snapshot.data;
                              var xx = snapshot.data["chat&roomsNotif"];
                            } catch (e) {
                              data = <String, bool>{
                                "chat&roomsNotif": true,
                                "groupsNotif": true,
                                "homeNotif": true,
                              };
                            }

                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SwitchListTile(
                                    activeColor: Theme.of(context).primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(Languages.translate(
                                        context, "chat_rooms_notifications")),
                                    value: data["chat&roomsNotif"],
                                    onChanged: (newValue) async {
                                      await authController
                                          .setAllNotificationSetting(<String,
                                              bool>{
                                        "chat&roomsNotif": newValue,
                                        "groupsNotif": data["groupsNotif"],
                                        "homeNotif": data["homeNotif"],
                                      });
                                      setState(() {});
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                  ),
                                  SwitchListTile(
                                    activeColor: Theme
                                        .of(context)
                                        .primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(Languages.translate(
                                        context, "groups_notifications")),
                                    value: data["groupsNotif"],
                                    onChanged: (newValue) async {
                                      await authController
                                          .setAllNotificationSetting(
                                          <String, bool>{
                                            "chat&roomsNotif": data["chat&roomsNotif"],
                                            "groupsNotif": newValue,
                                            "homeNotif": data["homeNotif"],
                                          }
                                      );
                                      setState(() {

                                      }
                                      );
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                  ),
                                  SwitchListTile(
                                    activeColor: Theme
                                        .of(context)
                                        .primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(Languages.translate(
                                        context, "home_notifications")),
                                    value: data["homeNotif"],
                                    onChanged: (newValue) async {
                                      await authController
                                          .setAllNotificationSetting(
                                          <String, bool>{
                                            "chat&roomsNotif": data["chat&roomsNotif"],
                                            "groupsNotif": data["groupsNotif"],
                                            "homeNotif": newValue,
                                          }
                                      );
                                      setState(() {

                                      }

                                      );
                                    },
                                    controlAffinity:
                                    ListTileControlAffinity.trailing,
                                  ),
                                ],
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            title: SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.zero,
              title: Text(Languages.translate(context, "dark_theme")),
              secondary: Icon(Icons.nights_stay),
              value: storageController.getTheme() == 'dark',
              onChanged: (newValue) async {
                if (newValue) {
                  await storageController.setTheme('dark');
                  MyAppState.myAppState.setState(() {
                    MyAppState.isDark = true;
                  });
                } else {
                  await storageController.setTheme('light');

                  MyAppState.myAppState.setState(() {
                    MyAppState.isDark = false;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ),
        ],
      ),
    );
  }
}
