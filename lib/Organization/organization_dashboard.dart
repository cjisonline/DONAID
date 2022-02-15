import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/campaign_card.dart';
import 'package:donaid/Organization/OrganizationWidget/urgent_case_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/beneficiary_card.dart';
import 'OrganizationWidget/button_nav_bar.dart';
import 'OrganizationWidget/organization_drawer.dart';
import 'add_selection_screen.dart';

class OrganizationDashboard extends StatefulWidget {
  static const id = 'organization_dashboard';

  const OrganizationDashboard({Key? key}) : super(key: key);

  @override
  _OrganizationDashboardState createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<OrganizationDashboard> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<Campaign> campaigns = [];
  List<UrgentCase> urgentCases = [];

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getCampaign();
    _getUrgentCases();
    _getBeneficiaries();
  }

  _getCampaign() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .get();
    ret.docs.forEach((element) {
      Campaign campaign = Campaign(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']);
      campaigns.add(campaign);
    });

    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .get();

    ret.docs.forEach((element) {
      UrgentCase urgentCase = UrgentCase(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']);
      urgentCases.add(urgentCase);
    });

    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .get();

    ret.docs.forEach((element) {
      Beneficiary beneficiary = Beneficiary(
          name: element.data()['name'],
          biography: element.data()['biography'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID:
              element.data()['organizationID']); // need to add category
      beneficiaries.add(beneficiary);
    });

    print('Beneficiaries list: $beneficiaries');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushNamed(context, OrgAddSelection.id);
              }),
        ],
      ),
      drawer: OrganizationDrawer(),
      body: _body(),
      bottomNavigationBar: ButtomNavigation(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Campaign',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'See more >',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 325.0,
              child: ListView.builder(
                itemCount: campaigns.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return CampaignCard(
                      campaigns[index].title,
                      campaigns[index].description,
                      campaigns[index].goalAmount,
                      campaigns[index].amountRaised);
                },
              )),

          // organization list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Urgent Cases',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'See more >',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 325.0,
              child: ListView.builder(
                itemCount: urgentCases.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return UrgentCaseCard(
                      urgentCases[index].title,
                      urgentCases[index].description,
                      urgentCases[index].goalAmount,
                      urgentCases[index].amountRaised);
                },
              )),

          // urgent case list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Beneficiary',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'See more >',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 325.0,
              child: ListView.builder(
                itemCount: beneficiaries.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return BeneficiaryCard(
                      beneficiaries[index].name,
                      beneficiaries[index].biography,
                      beneficiaries[index].goalAmount,
                      beneficiaries[index].amountRaised);
                },
              )),
        ],
      ),
    );
  }
}
