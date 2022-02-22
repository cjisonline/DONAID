import 'package:donaid/Chat/chat.dart';
import 'package:donaid/Controller/conController.dart';
import 'package:donaid/Donor/DonorWidgets/category_card.dart';
import 'package:donaid/Donor/DonorWidgets/organization_card.dart';
import 'package:donaid/Models/CharityCategory.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Widgets/conversation.dart';
import 'package:donaid/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class Conversation extends StatelessWidget {
  String currentUid = "", type = "";
  Conversation(this.currentUid, this.type);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConController>(
        init: ConController(type),
        builder: (homeCon) => Scaffold(
                body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0))),
                          child: Obx(() => ListView(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              children: homeCon.friendList
                                  .map((e) => Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(children: [
                                        conversation(
                                            e.organizationName
                                                    .toString()
                                                    .split('.')[0]
                                                    .capitalizeFirst ??
                                                "",
                                            MyGlobals.allMessages
                                                .where((p0) =>
                                                    p0.receiverId == e.uid)
                                                .toList()
                                                .last
                                                .body, () {
                                          Get.to(Chat(e.uid, e.organizationName,
                                              currentUid));
                                        }, messageSeen: false),
                                        Divider(color: Colors.grey)
                                      ])))
                                  .toList()))))
                ])));
  }
}

class ConversationScreen extends StatelessWidget {
  String currentUid = "", type = "";
  List<Organization> organizations;
  ConversationScreen(this.currentUid, this.type, this.organizations);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Organizations")),
        body: ListView.builder(
            itemCount: organizations.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, int index) {
              return InkWell(
                  onTap: () {
                    Get.to(Chat(organizations[index].uid,
                        organizations[index].organizationName, currentUid));
                  },
                  child:
                      OrganizationCard(organizations[index].organizationName));
            }));
  }
}
