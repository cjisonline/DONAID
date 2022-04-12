import 'package:donaid/Chat/conversation.dart';
import 'package:donaid/Donor/donor_search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../donor_dashboard.dart';
import '../notifications_page.dart';

// Donor bottom navigation bar
class DonorBottomNavigationBar extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  DonorBottomNavigationBar({Key? key}) : super(key: key);

  // Create donor navigation bar
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      // For guest donor users: only display home and search button in navigation bar
      child: (_auth.currentUser!.isAnonymous)
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround  ,
        children: [
          // Display home button
          // On pressed, navigate to the donor dashboard
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName(DonorDashboard.id));
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 35),
            ),
             Text('home'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          // Display search button
          // On pressed, navigate to the search screen
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.pushNamed(context, DonorSearchScreen.id);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 35,
              ),
            ),
             Text('search'.tr,
                textAlign: TextAlign.center,
                style:  TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ],
      )
      :
      // For donor users: display home, search, notifications, and messages buttons in navigation bar
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Display home button
          // On Pressed, navigate to donor dashboard
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName(DonorDashboard.id));
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 35),
            ),
             Text('home'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          // Display search button
          // On pressed, navigate to search screen
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.pushNamed(context, DonorSearchScreen.id);
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 35,
              ),
            ),
             Text('search'.tr,
                textAlign: TextAlign.center,
                style:  TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          // Display notification button
          // On pressed, navigate to the donor's notification page
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return DonorNotificationPage();
                }));
              },
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 35),
            ),
             Text('notifications'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          // Display the messages button
          // On pressed, navigate to the messages page
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return (Conversation(_auth.currentUser!.uid, "OrganizationUsers"));
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
