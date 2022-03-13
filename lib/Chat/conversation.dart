import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Chat/chat.dart';
import 'package:donaid/Controller/conController.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Widgets/conversation.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Donor/DonorWidgets/donor_drawer.dart';
import '../Organization/OrganizationWidget/organization_drawer.dart';

class ResetWidget extends StatelessWidget {
  String currentUid = "", type = "";
  ResetWidget(this.currentUid, this.type);
  @override
  Widget build(BuildContext context) => Conversation(currentUid, type);
}

class Conversation extends StatefulWidget {
  String currentUid = "", type = "";
  Conversation(this.currentUid, this.type);

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  _refresh() {
    Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) =>
                ResetWidget(widget.currentUid, widget.type)));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConController>(
      init: ConController(widget.type),
      builder: (homeCon) => Scaffold(
        appBar: AppBar(title:  Text('message'.tr), actions: <Widget>[
          widget.type == "OrganizationUsers"
              ? IconButton(
                  icon: const Icon(Icons.add, size: 30),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ConversationScreen(widget.currentUid, widget.type);
                    }));
                  })
              : Container()
        ]),
        body: RefreshIndicator(
          onRefresh: () async {
            _refresh();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: Obx(
                    () => ListView(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        children: homeCon.friendList
                            .map(
                              (e) => Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    conversation(
                                        e.organizationName
                                                .toString()
                                                .split('.')[0]
                                                .capitalizeFirst ??
                                            "",
                                        MyGlobals.allMessages
                                            .where(
                                                (p0) => p0.receiverId == e.uid)
                                            .toList()
                                            .last
                                            .body, () {
                                      Get.to(Chat(e.uid, e.organizationName,
                                          widget.currentUid));
                                    }, () async {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CupertinoAlertDialog(
                                                  title: Text(
                                                      "${e.organizationName}"),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        child: Text("No".tr)),
                                                    CupertinoDialogAction(
                                                        onPressed: () async {
                                                          await FirebaseDatabase
                                                              .instance
                                                              .ref()
                                                              .child('chat')
                                                              .child(widget
                                                                  .currentUid)
                                                              .child(e.uid)
                                                              .remove();
                                                          homeCon.friendList
                                                              .removeWhere(
                                                                  (element) =>
                                                                      element
                                                                          .uid ==
                                                                      e.uid);
                                                          MyGlobals.allMessages
                                                              .removeWhere((p0) =>
                                                                  p0.receiverId ==
                                                                  e.uid);
                                                          Get.back();
                                                          setState(() {});
                                                        },
                                                        child: Text("yes".tr))
                                                  ],
                                                  content: Text(
                                                      "do_you_want_to_delete_conversation".tr)));
                                    }, messageSeen: false),
                                    Divider(color: Colors.grey)
                                  ],
                                ),
                              ),
                            )
                            .toList()),
                  ),
                ),
              )
            ],
          ),
        ),
        drawer: (this.widget.type == "OrganizationUsers") ? DonorDrawer() : OrganizationDrawer(),
        bottomNavigationBar: (this.widget.type == "OrganizationUsers") ? DonorBottomNavigationBar() : OrganizationBottomNavigation(),
      ),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  String currentUid = "", type = "";
  ConversationScreen(this.currentUid, this.type);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Organization> organizations = [];
  List<String> orgIDs = [];
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  initState() {
    super.initState();
    _getOrganizationsFromDonations();
  }

  _getOrganizationsFromDonations() async {
    var ret = await _firestore
        .collection('Donations')
        .where('donorID', isEqualTo: _auth.currentUser?.uid)
        .get();

    for (var element in ret.docs) {
      var orgDocRef = await _firestore
          .collection('OrganizationUsers')
          .where('uid', isEqualTo: element.data()['organizationID'])
          .get();

      for (var org in orgDocRef.docs) {
        Organization organization = Organization(
            organizationEmail: org.data()['organizationEmail'],
            organizationName: org.data()['organizationName'],
            phoneNumber: org.data()['phoneNumber'],
            uid: org.data()['uid'],
            organizationDescription: org.data()['organizationDescription'],
            country: org.data()['country'],
            gatewayLink: org.data()['gatewayLink'],
            id: org.data()['id']);

        if (!orgIDs.contains(org.data()['uid'].toString())) {
          orgIDs.add(org.data()['uid'].toString());
          organizations.add(organization);
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title:  Text("organization".tr)),
        body: ListView.builder(
            itemCount: organizations.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, int index) {
              return InkWell(
                  onTap: () {
                    Get.to(Chat(
                        organizations[index].uid,
                        organizations[index].organizationName,
                        widget.currentUid));
                  },
                  child: Column(children: [
                    ListTile(
                        title: Text(organizations[index].organizationName),
                        subtitle: Text(organizations[index]
                            .organizationDescription
                            .toString())),
                    const Divider(color: Colors.grey)
                  ]));
            }));
  }
}
