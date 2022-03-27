
import 'package:donaid/Chat/conversation.dart';
import 'package:donaid/Organization/notifications_page.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../organization_dashboard.dart';
import '../search_page.dart';

class OrganizationBottomNavigation extends StatefulWidget {
  const OrganizationBottomNavigation({Key? key}) : super(key: key);

  @override
  State<OrganizationBottomNavigation> createState() => _OrganizationBottomNavigationState();
}

class _OrganizationBottomNavigationState extends State<OrganizationBottomNavigation> {
  final _auth = FirebaseAuth.instance;
  ///Author: Raisa Zaman
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName(OrganizationDashboard.id));
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 35),
            ),
            Text('home'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.pushNamed(context, OrgSearchPage.id);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 35,
              ),
            ),
            Text('search'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.pushNamed(context, OrganizationNotificationPage.id);
              },
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 35),
            ),
            Text('notifications'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return(Conversation(_auth.currentUser!.uid, "DonorUsers"));
                }));
              },
              icon: const Icon(Icons.message, color: Colors.white, size: 35),
            ),
            Text('message'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ],
      ),
    );
  }
}