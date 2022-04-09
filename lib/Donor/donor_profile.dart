import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/Donor/donor_edit_profile.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  _refreshPage(){
    _getCurrentUser();
    _getDonorInformation();
    setState(() {});
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  // Get current logged in donor's information from Firebase
  _getDonorInformation() async {
    var ret = await _firestore.collection('DonorUsers').where('uid', isEqualTo: loggedInUser?.uid).get();
    final doc = ret.docs[0];
    donor = Donor(
        email: doc['email'],
        firstName: doc['firstName'],
        lastName: doc['lastName'],
        phoneNumber: doc['phoneNumber'],
        id: doc['id']
      );
    setState(() {});
  }

  // Display profile page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Display back button in top app bar
        // On pressed, navigate to previous screen
        title:  Text('profile'.tr),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          actions: [
            // Display edit button in top app bar
            // On pressed, navigate to edit profile screen
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DonorEditProfile())).then((value) => _refreshPage());
              },
              child:  Text('edit'.tr,
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          ]),
      drawer: const DonorDrawer(),
      body: _body(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }

  // Display profile page
  _body() {
    return  SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children:  [
                // Display donor's email, first name, last name, and phone number
                ProfileRow('email'.tr.toUpperCase(), donor.email),
                ProfileRow('first_name'.tr.toUpperCase(), donor.firstName),
                ProfileRow('last_name'.tr.toUpperCase(), donor.lastName),
                ProfileRow('phone_number'.tr.toUpperCase(), donor.phoneNumber),
              ],
            )
        );
  }
}
