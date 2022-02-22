import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/category_card.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Donor/DonorWidgets/organization_card.dart';
import 'package:donaid/Donor/DonorWidgets/urgent_case_card.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/Donor/donor_edit_profile.dart';
import 'package:donaid/Models/CharityCategory.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DonorWidgets/profile_list_row.dart';

class DonorProfile extends StatefulWidget {
  static const id = 'donor_profile';

  const DonorProfile({Key? key}) : super(key: key);

  @override
  _DonorProfileState createState() => _DonorProfileState();
}

class _DonorProfileState extends State<DonorProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  Donor donor = Donor.c1();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getDonorInformation();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getDonorInformation() async {
    var ret = await _firestore.collection('DonorUsers').where('uid', isEqualTo: loggedInUser?.uid).get();
    final doc = ret.docs[0];
    donor = Donor(
          doc['email'],
        doc['firstName'],
        doc['lastName'],
           doc['phoneNumber'],
      doc['id']
      );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, DonorEditProfile.id);
              },
              child: const Text('Edit',
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          ]),
      drawer: const DonorDrawer(),
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  _body() {
    return  SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children:  [
                ProfileRow('YOUR EMAIL', donor.email),
                ProfileRow('FIRST NAME', donor.firstName),
                ProfileRow('LAST NAME', donor.lastName),
                ProfileRow('YOUR PHONE', donor.phoneNumber),
              ],
            )
        );
  }

  _bottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.pushNamed(context, DonorDashboard.id);
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 35),
            ),
            const Text('Home',
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
            const Text('Search',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 35),
            ),
            const Text('Notifications',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.message, color: Colors.white, size: 35),
            ),
            const Text('Messages',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ],
      ),
    );
  }
}
