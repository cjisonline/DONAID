import 'package:donaid/Chat/conversation.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:flutter/material.dart';

class ButtomNavigation extends StatefulWidget {
  const ButtomNavigation({Key? key}) : super(key: key);
import '../../home_screen.dart';

class OrganizationBottomNavigation extends StatelessWidget {
  const OrganizationBottomNavigation({Key? key}) : super(key: key);

  @override
  State<ButtomNavigation> createState() => _ButtomNavigationState();
}

class _ButtomNavigationState extends State<ButtomNavigation> {
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
            Text('Home',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 35,
              ),
            ),
            Text('Search',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
              },
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 35),
            ),
            Text('Notifications',
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
            Text('Messages',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ],
      ),
    );
  }
}