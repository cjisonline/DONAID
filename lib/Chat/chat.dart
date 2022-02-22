import 'dart:async';
import 'package:donaid/Controller/chatController.dart';
import 'package:donaid/globals.dart';
import 'package:donaid/Widgets/messageBubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Chat extends StatelessWidget {
  final String uIdFriend;
  final String currentUserId;
  final String name;
  Chat(this.uIdFriend, this.name, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
        init: ChatController(currentUserId),
        builder: (chatController) {
          Timer(
              Duration(seconds: 1),
              () => chatController.scrollController.jumpTo(
                  chatController.scrollController.position.maxScrollExtent));
          return WillPopScope(
              onWillPop: () async {
                // await homeCon.updateScreen();
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
                return true;
              },
              child: Stack(children: [
                Scaffold(
                    // backgroundColor: Colors.black,
                    appBar: AppBar(
                        title: Text(name.capitalizeFirst ?? "",
                            style: TextStyle(
                                // color: Colors.white,
                                fontSize: 18.5,
                                fontWeight: FontWeight.w400))),
                    body: SafeArea(
                        child: Container(
                            // padding: const EdgeInsets.only(left: 8, right: 8),
                            height: MediaQuery.of(context).size.height,
                            // width: MediaQuery.of(context).size.width,
                            child: Column(children: [
                              Expanded(
                                  child: Obx(() => Column(children: [
                                        Expanded(
                                            child: ListView(
                                                controller: chatController
                                                    .scrollController,
                                                padding: EdgeInsets.only(
                                                    left: 20, right: 20),
                                                children: MyGlobals.allMessages
                                                        .where((e) =>
                                                            e.receiverId ==
                                                            uIdFriend)
                                                        .toList()
                                                        .isNotEmpty
                                                    ? MyGlobals.allMessages
                                                        .where((e) =>
                                                            e.receiverId ==
                                                            uIdFriend)
                                                        .toList()
                                                        .map((e) {
                                                        if (e.senderId ==
                                                            currentUserId)
                                                          return senderBubble(
                                                              e.body,
                                                              e.creationDate,
                                                              e.type == "level"
                                                                  ? true
                                                                  : false,
                                                              context);
                                                        else
                                                          return reciverBubble(
                                                              e.body,
                                                              e.creationDate,
                                                              e.type == "level"
                                                                  ? true
                                                                  : false,
                                                              context);
                                                      }).toList()
                                                    : []))
                                      ]))),
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                      height: 70,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 12, right: 12),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Card(
                                                          color: Colors
                                                              .grey.shade200,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 3,
                                                                  right: 3,
                                                                  top: 3,
                                                                  bottom: 3),
                                                          shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  width: 1.5,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade500),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25)),
                                                          child: Theme(
                                                              child: TextFormField(
                                                                  controller: chatController.textController,
                                                                  focusNode: chatController.focusNode,
                                                                  showCursor: true,
                                                                  textAlignVertical: TextAlignVertical.center,
                                                                  keyboardType: TextInputType.multiline,
                                                                  maxLines: 2,
                                                                  minLines: 1,
                                                                  style: TextStyle(color: Colors.black),
                                                                  onChanged: (value) {},
                                                                  decoration: InputDecoration(
                                                                      focusedBorder: InputBorder.none,
                                                                      enabledBorder: InputBorder.none,
                                                                      border: InputBorder.none,
                                                                      disabledBorder: InputBorder.none,
                                                                      hintText: "Type a message",
                                                                      hintStyle: TextStyle(color: Colors.grey.shade700),
                                                                      suffixIcon: Padding(
                                                                          padding: EdgeInsets.only(bottom: 2, top: 2, right: 2),
                                                                          child: CircleAvatar(
                                                                              radius: 21,
                                                                              backgroundColor: Colors.green.shade400,
                                                                              child: IconButton(
                                                                                icon: Icon(chatController.visibleActions ? Icons.north_outlined : Icons.north_east, color: Colors.white),
                                                                                onPressed: () => chatController.sendMessage(uIdFriend),
                                                                              ))),
                                                                      contentPadding: EdgeInsets.all(15))),
                                                              data: ThemeData(cardColor: Colors.black, focusColor: Colors.grey, primaryColor: Colors.grey))))
                                                ])
                                          ]))),
                            ]))))
              ]));
        });
  }
}
