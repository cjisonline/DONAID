import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Widgets/horizontal-bar-chart.dart';
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

  double numberOfDonors = 0.0;
  double urgentCasesRaised=0.0;
  double campaignRaised=0.0;
  double beneficiaryRaised=0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getOrganizationInformation();
    getInfo();
  }

  getInfo() async {
    numberOfDonors=0.0;
    urgentCasesRaised=0.0;
    campaignRaised=0.0;
    beneficiaryRaised=0.0;

    var ret3 = await _firestore
        .collection("Donations")
        .where("organizationID", isEqualTo: _auth.currentUser?.uid ?? "")
        .get();

    //amountRaised
    for (var item in ret3.docs) {
      if(item.data()['charityType'] == 'UrgentCases'){
        urgentCasesRaised += double.tryParse(item.data()['donationAmount']) ?? 0.0;
      }
      else if(item.data()['charityType'] == 'Beneficiaries'){
        beneficiaryRaised += double.tryParse(item.data()['donationAmount']) ?? 0.0;
      }
      else if(item.data()['charityType'] == 'Campaigns'){
        campaignRaised += double.tryParse(item.data()['donationAmount']) ?? 0.0;
      }
    }


    //Number of donors
    var ret2 = await _firestore
        .collection("Donations")
        .where("organizationID", isEqualTo: _auth.currentUser!.uid)
        .get();
    numberOfDonors = ret2.docs.length+.0;
    setState(() {});
  }

  _refreshPage() {
    _getOrganizationInformation();
    setState(() {});
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  // Get current logged in organization's information from Firebase
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

  // Display profile page
  _body() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // Display profile information of logged in organization user
            _buildProfilePictureDisplay(),
            Text(
              'your_information'.tr.toUpperCase(),
              style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
            ProfileRow('email'.tr.toUpperCase(), organization?.organizationEmail ?? 'N/A'),
            ProfileRow('name'.tr.toUpperCase(), organization?.organizationName ?? 'N/A'),
            ProfileRow('phone_number'.tr.toUpperCase(), organization?.phoneNumber ?? 'N/A'),
            ProfileRow(
                'description'.tr.toUpperCase(), organization?.organizationDescription ?? 'N/A'),
            const SizedBox(height: 15),


            // Display statistics of logged in organization user
            Text(
              "statistics".tr.toUpperCase(),
              style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height:25),
            Text('donations'.tr.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            Container(
                height: MediaQuery.of(context).size.height*0.5,
                width: MediaQuery.of(context).size.width,
                child: HorizontalBarLabelChart.withData(urgentCasesRaised, beneficiaryRaised, campaignRaised)),
            Text(numberOfDonors.toStringAsFixed(0)+'_unique_donors'.tr.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10),
          ],
        ));
  }
}
