import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/GroupsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class MembersTab extends StatefulWidget {
  Group group;

  MembersTab(this.group);

  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;

  GroupsController _groupsController = GroupsController();

  AuthController _authController = AuthController();

  List<DocumentSnapshot> members = [null, null];

  @override
  void initState() {
    getMembers();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (_, index) {
        if (index == 0)
          return SizedBox(
            height: 20,
          );
        else if (index == members.length - 1) {
          if (isLoading)
            return Center(child: CircularProgressIndicator());
          else if (hasMore)
            return FlatButton(
              onPressed: () {
                getMembers();
              },
              child: Text(Languages.translate(context, "load_more")),
            );
          return Container();
        }
        return FutureBuilder(
            future: _authController.getUserInfo(members[index].id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                try {
                  print(snapshot.data);
                  User user = User()
                      .fromMap(snapshot.data.data())
                      .setId(snapshot.data.id);
                  print(user.id);
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/ProfilePage',
                        arguments: {
                          'id_user': user.id,
                          'user': user,
                        },
                      );
                    },
                    title: Text(user.firstName + ' ' + user.secondName),
                    subtitle: Text(Languages.translate(
                      context,
                      user.tag,
                    )),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(57),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Center(
                          child: Image.asset(ConstValues.userImage),
                        ),
                        imageUrl:
                            user.img != null ? user.img : ConstValues.userImage,
                        fit: BoxFit.cover,
                        width: 57,
                        height: 57,
                      ),
                    ),
                  );
                } catch (e) {
                  return Container();
                }
              }
              return UserPlaceholder();
            });
      },
    );
  }

  getMembers() async {
    if (!hasMore) {
      print('No More members');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    querySnapshot = await _groupsController.getMembers(
      limit: documentLimit,
      last: lastDocument,
      group: widget.group,
    );

    setState(() {
      members.insertAll(members.length - 1, querySnapshot.docs);
      isLoading = false;

      if (querySnapshot.docs.length < documentLimit)
        hasMore = false;
      else
        lastDocument = querySnapshot.docs.last;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
