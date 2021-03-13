import 'package:day_night_switcher/day_night_switcher.dart';
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
  List<bool> notifications = [true, true, true, true, true];

  bool xx = true;

  @override
  Widget build(BuildContext context) {
    StorageController storageController = new StorageController();

    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(context, "setting")),
        actions: [
          DayNightSwitcherIcon(
            isDarkModeEnabled: storageController.getTheme() == 'dark',
            onStateChanged: (isDarkModeEnabled) {
              setState(() async {
                if (isDarkModeEnabled) {
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
              });
            },
          ),
          SizedBox(
            width: 8,
          ),
        ],
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
          Divider(),
          ListTile(
            title: Text(Languages.translate(context, "change_theme")),
            leading: Icon(Icons.style_outlined),
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
                          selected: storageController.getTheme() == 'light',
                          onTap: () async {
                            await storageController.setTheme('light');

                            MyAppState.myAppState.setState(() {
                              MyAppState.isDark = false;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title:
                          Text(Languages.translate(context, "dark_theme")),
                          selected: storageController.getTheme() == 'dark',
                          onTap: () async {
                            await storageController.setTheme('dark');
                            MyAppState.myAppState.setState(() {
                              MyAppState.isDark = true;
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
            title: Text(Languages.translate(context, "notifications")),
            leading: Icon(Icons.notifications_active_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    scrollable: true,
                    title: Text(Languages.translate(context, "notifications")),
                    content: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SwitchListTile(
                              activeColor: Theme
                                  .of(context)
                                  .primaryColor,
                              contentPadding: EdgeInsets.zero,
                              title: Text(Languages.translate(
                                  context, "chat_rooms_notifications")),
                              value: notifications[0],
                              onChanged: (newValue) {
                                print(newValue);
                                setState(() {
                                  notifications[0] = !notifications[0];
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing,
                            ),
                            SwitchListTile(
                              activeColor: Theme
                                  .of(context)
                                  .primaryColor,
                              contentPadding: EdgeInsets.zero,
                              title: Text(Languages.translate(
                                  context, "groups_notifications")),
                              value: notifications[1],
                              onChanged: (newValue) {
                                setState(() {
                                  notifications[1] = newValue;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing,
                            ),
                            SwitchListTile(
                              activeColor: Theme
                                  .of(context)
                                  .primaryColor,
                              contentPadding: EdgeInsets.zero,
                              title: Text(Languages.translate(
                                  context, "home_notifications")),
                              value: notifications[2],
                              onChanged: (newValue) {
                                setState(() {
                                  notifications[2] = newValue;
                                });
                              },
                              controlAffinity: ListTileControlAffinity
                                  .trailing,
                            ),
                          ],
                        );
                      },
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            //TODO control the notifications
                            Navigator.pop(context);
                          },
                          child: Text(Languages.translate(context, "save"))),
                    ],

                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            title: SwitchListTile(
              activeColor: Theme
                  .of(context)
                  .primaryColor,
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
          Divider(),
          ListTile(
            title: Text(Languages.translate(context, "dark_theme")),
            trailing: DayNightSwitcherIcon(
              isDarkModeEnabled: storageController.getTheme() == 'dark',
              onStateChanged: (isDarkModeEnabled) {
                setState(() async {
                  if (isDarkModeEnabled) {
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
                });
              },
            ),
            leading: Icon(Icons.nights_stay),
          ),
        ],
      ),
    );
  }
}
