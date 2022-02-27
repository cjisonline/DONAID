import 'dart:async';
import 'package:donaid/Models/message.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<String> list = [];
  String currentUserId = "";
  bool visibleActions = false;
  bool x = false;
  List<String> ids = [];
  ScrollController scrollController = ScrollController();
  ChatController(id) {
    currentUserId = id;
  }
  sendMessage(String uiDfriend) async {
    if (textController.text.trim() == "") {
    } else {
      MessageModel message = MessageModel();
      message.body = textController.text;
      message.senderId = currentUserId;
      message.type = 'text';
      message.receiverId = uiDfriend;
      textController.text = "";
      update();
      await Get.find<ChatService>().sendMessage(message);
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    Timer(
        Duration(milliseconds: 500),
        () =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent));
  }
}
