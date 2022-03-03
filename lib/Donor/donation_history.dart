import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Donation.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'package:intl/intl.dart';

import 'beneficiary_donate_screen.dart';
import 'campaign_donate_screen.dart';

class DonationHistory extends StatefulWidget {
  static const id = 'donation_history';
  const DonationHistory({Key? key}) : super(key: key);

  @override
  _DonationHistoryState createState() => _DonationHistoryState();
}

class _DonationHistoryState extends State<DonationHistory> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Donation> donations = [];
  List<Organization> organizations = [];
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getDonationHistory();
  }

  _refreshPage(){
    donations.clear();
    organizations.clear();
    _getDonationHistory();
  }

  _getDonationHistory() async {
    var ret = await _firestore
        .collection('Donations')
        .where('donorID', isEqualTo: _auth.currentUser?.uid)
        .get();

    for (var doc in ret.docs) {
      Donation donation = Donation(
          charityID: doc.data()['charityID'],
          charityName: doc.data()['charityName'],
          donatedAt: doc.data()['donatedAt'],
          donationAmount: double.parse(doc.data()['donationAmount']),
          donorID: doc.data()['donorID'],
          organizationID: doc.data()['organizationID'],
          id: doc.data()['id'],
          category: doc.data()['category'],
          charityType: doc.data()['charityType']);

      donations.add(donation);
    }
    _getDonationOrganizations();
  }

  _getDonationOrganizations() async {
    for (var donation in donations) {
      var ret = await _firestore
          .collection('OrganizationUsers')
          .where('uid', isEqualTo: donation.organizationID)
          .get();
      var doc = ret.docs.first;

      Organization organization = Organization(
        organizationName: doc.data()['organizationName'],
        uid: doc.data()['uid'],
        organizationDescription: doc.data()['organizationDescription'],
        country: doc.data()['country'],
        gatewayLink: doc.data()['gatewayLink'],
      );

      organizations.add(organization);
    }
    setState(() {});
  }

  _goToChosenUrgentCase(String id)async{
    var ret = await _firestore.collection('UrgentCases').where('id',isEqualTo: id).get();
    var doc = ret.docs[0];
    UrgentCase urgentCase = UrgentCase(
        title: doc.data()['title'],
        description: doc.data()['description'],
        goalAmount: doc.data()['goalAmount'].toDouble(),
        amountRaised: doc.data()['amountRaised'].toDouble(),
        category: doc.data()['category'],
        endDate: doc.data()['endDate'],
        dateCreated: doc.data()['dateCreated'],
        id: doc.data()['id'],
        organizationID: doc.data()['organizationID'],
        active: doc.data()['active'],
        approved: doc.data()['approved']
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (UrgentCaseDonateScreen(urgentCase));
    })).then((value) => _refreshPage());
  }

  _goToChosenCampaign(String id)async {
    var ret = await _firestore.collection('Campaigns')
        .where('id', isEqualTo: id)
        .get();
    var doc = ret.docs[0];
    Campaign campaign = Campaign(
      title: doc.data()['title'],
      description: doc.data()['description'],
      goalAmount: doc.data()['goalAmount'].toDouble(),
      amountRaised: doc.data()['amountRaised'].toDouble(),
      category: doc.data()['category'],
      endDate: doc.data()['endDate'],
      dateCreated: doc.data()['dateCreated'],
      id: doc.data()['id'],
      organizationID: doc.data()['organizationID'],
      active: doc.data()['active'],
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (CampaignDonateScreen(campaign));
    })).then((value) => _refreshPage());
  }

  _goToChosenBeneficiary(String id)async {
    var ret = await _firestore.collection('Beneficiaries')
        .where('id', isEqualTo: id)
        .get();
    var doc = ret.docs[0];
    Beneficiary beneficiary = Beneficiary(
      name: doc.data()['name'],
      biography: doc.data()['biography'],
      goalAmount: doc.data()['goalAmount'].toDouble(),
      amountRaised: doc.data()['amountRaised'].toDouble(),
      category: doc.data()['category'],
      endDate: doc.data()['endDate'],
      dateCreated: doc.data()['dateCreated'],
      id: doc.data()['id'],
      organizationID: doc.data()['organizationID'],
      active: doc.data()['active'],
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (BeneficiaryDonateScreen(beneficiary));
    })).then((value) => _refreshPage());
  }

  _donationHistoryBody() {
    return ListView.builder(
        itemCount: donations.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
              child: Column(
            children: [
              (donations[index].charityType == 'UrgentCases')
                  ? ListTile(
                      onTap: () {
                        _goToChosenUrgentCase(donations[index].charityID.toString());
                      },
                      title: Text(donations[index].charityName),
                      subtitle: Text('Urgent Case\n' +
                          organizations[index].organizationName),
                      trailing: Text(
                          "\u0024" + f.format(donations[index].donationAmount)),
                    )
                  : (donations[index].charityType == 'Campaigns')
                      ? ListTile(
                          onTap: () {
                            _goToChosenCampaign(donations[index].charityID.toString());
                          },
                          title: Text(donations[index].charityName),
                          subtitle: Text('Campaign\n' +
                              organizations[index].organizationName),
                          trailing: Text("\u0024" +
                              f.format(donations[index].donationAmount)),
                        )
                      : ListTile(
                onTap: () {
                  _goToChosenBeneficiary(donations[index].charityID.toString());
                },
                title: Text(donations[index].charityName),
                subtitle: Text('Beneficiary\n' +
                    organizations[index].organizationName),
                trailing: Text("\u0024" +
                    f.format(donations[index].donationAmount)),
              ),
              const Divider()
            ],
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _donationHistoryBody(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
