import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/message.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:donaid/Services/database.dart';
import 'package:donaid/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConController extends GetxController {
  RxList<Organization> friendList = <Organization>[].obs;
  FocusNode focusNode = FocusNode();
  ChatService chatService = ChatService();
  TextEditingController textController = TextEditingController();
  String type = "";
  ConController(typ) {
    type = typ;
  }
  friendUser(type) async {
    friendList.clear();
    for (MessageModel item in MyGlobals.allMessages) {
      var list = friendList.where((element) => element.uid == item.receiverId);
      if (list.isEmpty) {
        QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore
            .instance
            .collection(type)
            .where('uid', isEqualTo: item.receiverId)
            .get();
        if (data.docs.first.exists) {
          friendList.add(Organization(
              organizationName: type == "OrganizationUsers"
                  ? data.docs.first.data()['organizationName']
                  : data.docs.first.data()['firstName'] +
                      " " +
                      data.docs.first.data()['lastName'],
              uid: item.receiverId));
          print(friendList);
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    friendUser(type);
  }
}
