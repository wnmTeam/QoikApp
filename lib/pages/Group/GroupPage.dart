import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/Group/tabs/MembersTabView.dart';
import 'package:stumeapp/pages/Group/tabs/PostsTabView.dart';

class GroupPage extends StatefulWidget {
  final Group group;

  GroupPage(this.group);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;

  AuthController _authController = AuthController();

  bool tt = true;

  @override
  void initState() {
    print(widget.group.toMap());
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(Theme
        .of(context)
        .primaryTextTheme
        .headline6);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {},
            title: widget.group.type == Group.TYPE_UNIVERSITY
                ? Text(
              Languages.translate(
                context,
                'my_university',
              ),
              style: Theme
                  .of(context)
                  .textTheme
                  .copyWith(subtitle1: TextStyle(color: Colors.white))
                  .subtitle1,
            )
                : widget.group.type == Group.TYPE_COLLEGE
                ? Text(Languages.translate(
              context,
              'my_college',
            ), style: Theme
                .of(context)
                .textTheme
                .copyWith(subtitle1: TextStyle(color: Colors.white))
                .subtitle1,)
                : widget.group.type == 'city'
                ? Text(Languages.translate(
              context,
              'my_city',
            ), style: Theme
                .of(context)
                .textTheme
                .copyWith(subtitle1: TextStyle(color: Colors.white))
                .subtitle1,)
                : Text(Languages.translate(
              context,
              widget.group.id,
            ), style: Theme
                .of(context)
                .textTheme
                .copyWith(subtitle1: TextStyle(color: Colors.white))
                .subtitle1,),
            subtitle: widget.group.type == 'G' ||
                widget.group.type == Group.TYPE_MOFADALAH ||
                widget.group.type == 'test'
                ? null
                : Text(
              widget.group.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .copyWith(caption: TextStyle(color: Colors.white))
                  .caption,
            ),
            leading: Container(
              width: 38,
              height: 38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/col.svg',
                    color: Theme
                        .of(context)
                        .primaryColor,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white70,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.error_outline, color: Colors.white70),
              onPressed: (){
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(' '),
                        content: Text(
                          Languages.translate(
                            context,
                            'group_info_${widget.group.type}',
                          ),
                        ),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child: Text(
                              Languages.translate(
                                context,
                                'ok',
                              ),
                            ),
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white70,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 30),
            controller: _tabController,
            tabs: [
              Tab(
                // icon: Icon(
                //   Icons.chat,
                //   color: Colors.indigo,
                // ),
                child: Text(
                  Languages.translate(
                    context,
                    'posts',
                  ),
                ),
              ),
              Tab(
                child: Text(
                  Languages.translate(
                    context,
                    'members',
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            PostsTab(widget.group),
            MembersTab(widget.group),
          ],
        ),
      ),
    );
  }
}
