import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth.dart';

class GroupsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Auth auth = Auth();

  Stream getMyGroups() {
    return _firestore.collection('groups').snapshots();
  }



}
