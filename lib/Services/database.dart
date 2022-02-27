import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/user.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class StoreService {
  FirebaseFirestore _instance = FirebaseFirestore.instance;

  saveUser() async {
    await _instance
        .collection('userProfiles')
        .doc(MyGlobals.currentUser.id)
        .set(MyGlobals.currentUser.toJSON());
    await MyGlobals.myBox
        .write(MyGlobals.currentUser.id, MyGlobals.currentUser.toJSON());
  }

  Future<UserModel> getUser(id) async {
    var data = await MyGlobals.myBox.read(id);
    if (data == null) {
      try {
        DocumentSnapshot dsnap =
            await _instance.collection('userProfiles').doc(id).get();
        if (dsnap.exists) {
          // UserModel user = UserModel.fromJson(dsnap.data() as Map<String, dynamic>);
          return UserModel();
        } else
          return UserModel();
      } catch (e) {
        EasyLoading.showInfo(e.toString(), duration: Duration(seconds: 3));
        return UserModel();
      }
    } else {
      // UserModel user = UserModel.f(data);
      // return user;
      return UserModel();
    }
  }

  Future<List<UserModel>> searchUser(search) async {
    List<UserModel> users = [];
    QuerySnapshot<Map<String, dynamic>> data = await _instance
        .collection('userProfiles')
        .where("searchPatrameters", arrayContains: search.toLowerCase())
        .get();
    for (var item in data.docs) {
      if (item.exists) {
        // UserModel user = UserModel.fromJson(item.data());
        // if (user.id != MyGlobals.currentUser.id)
        //  users.add(user);
      }
    }
    return users;
  }

  Future<String> uploadUrl(File file) async {
    var ref = FirebaseStorage.instance
        .ref('profile/')
        .child('${MyGlobals.currentUser.id}');
    await ref.putFile(file);
    String url = await ref.getDownloadURL();
    return url;
  }
}
