import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/profile_list_row.dart';
import 'organization_edit_profile.dart';
import 'package:get/get.dart';

class OrganizationProfile extends StatefulWidget {
  static const id = 'organization_profile';

  const OrganizationProfile({Key? key}) : super(key: key);

  @override
  _OrganizationProfileState createState() => _OrganizationProfileState();
}

class _OrganizationProfileState extends State<OrganizationProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  Organization? organization;

  double p1 = 0.0, p2 = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getOrganizationInformation();
    getInfo();
  }

  getInfo() async {
    p1 = 0.0;
    p2 = 0.0;
    var ret3 = await _firestore
        .collection("Donations")
        .where("organizationID", isEqualTo: _auth.currentUser?.uid ?? "")
        .get();

    //amountRaised
    for (var item in ret3.docs) {
      p1 = p1 + (double.tryParse(item['donationAmount']) ?? 0.0);
    }


    var ret2 = await _firestore
        .collection("Donations")
        .where("organizationID", isEqualTo: _auth.currentUser?.uid ?? "")
        .get();
    p2 = ret2.docs.length + .0;
    setState(() {});
  }

  _refreshPage() {
    _getOrganizationInformation();
    setState(() {});
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getOrganizationInformation() async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('uid', isEqualTo: loggedInUser?.uid)
        .get();
    final doc = ret.docs[0];
    organization = Organization(
        organizationEmail: doc['email'],
        organizationName: doc['organizationName'],
        phoneNumber: doc['phoneNumber'],
        uid: doc['uid'],
        organizationDescription: doc['organizationDescription'],
        country: doc['country'],
        gatewayLink: doc['gatewayLink'],
        profilePictureDownloadURL: doc['profilePictureDownloadURL']);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('profile'.tr), actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrganizationEditProfile()))
                  .then((value) => _refreshPage());
            },
            child: Text('edit'.tr,
                style: TextStyle(fontSize: 15.0, color: Colors.white)),
          ),
        ]),
        drawer: const OrganizationDrawer(),
        body: _body(),
        bottomNavigationBar: OrganizationBottomNavigation());
  }

  Widget _buildProfilePictureDisplay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
      child: (organization?.profilePictureDownloadURL == null ||
          organization!.profilePictureDownloadURL.toString().isEmpty)
          ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 150,
              height: 150,
              child: Icon(Icons.person, size: 150),
            ),
          ])
          : (organization!.profilePictureDownloadURL.toString().isNotEmpty)
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Image.network(
              organization!.profilePictureDownloadURL.toString(),
              fit: BoxFit.contain,
            ),
          ),
        ],
      )
          : Container(),
    );
  }

  Widget _buildUnitedStatesProfile() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _buildProfilePictureDisplay(),
            ProfileRow('YOUR EMAIL', organization?.organizationEmail ?? 'N/A'),
            ProfileRow('NAME', organization?.organizationName ?? 'N/A'),
            ProfileRow('YOUR PHONE', organization?.phoneNumber ?? 'N/A'),
            ProfileRow(
                'DESCRIPTION', organization?.organizationDescription ?? 'N/A'),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  margin: const EdgeInsets.only(
                      left: 30.0, right: 30.0, bottom: 10.0, top: 10.0),
                  child: Text(
                    "Statistics".toUpperCase(),
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ))
            ]),
            ProfileRow('Total Money Raised', p1.toStringAsFixed(2)),
            ProfileRow('Number of donors', p2.toStringAsFixed(0)),
            SizedBox(height: 10),
          ],
        ));
  }

  Widget _buildOutsideUnitedStatesProfile() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _buildProfilePictureDisplay(),
            ProfileRow('YOUR EMAIL', organization?.organizationEmail ?? 'N/A'),
            ProfileRow('NAME', organization?.organizationName ?? 'N/A'),
            ProfileRow('YOUR PHONE', organization?.phoneNumber ?? 'N/A'),
            ProfileRow(
                'DESCRIPTION', organization?.organizationDescription ?? 'N/A'),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  margin: const EdgeInsets.only(
                      left: 30.0, right: 30.0, bottom: 10.0, top: 10.0),
                  child: Text(
                    "Statistics".toUpperCase(),
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ))
            ]),
            ProfileRow('Total Money Raised', p1.toStringAsFixed(2)),
            ProfileRow('Number of donors', p2.toStringAsFixed(0)),
            SizedBox(height: 10),
          ],
        ));
  }

  _body() {
    if (organization?.country == 'United States') {
      return _buildUnitedStatesProfile();
    } else {
      return _buildOutsideUnitedStatesProfile();
    }
  }
}
