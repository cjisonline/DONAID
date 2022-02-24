import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/category_card.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Donor/DonorWidgets/organization_card.dart';
import 'package:donaid/Donor/DonorWidgets/urgent_case_card.dart';
import 'package:donaid/Donor/beneficiaries_expanded_screen.dart';
import 'package:donaid/Donor/categories_screen.dart';
import 'package:donaid/Donor/organizations_expanded_screen.dart';
import 'package:donaid/Donor/urgent_cases_expanded_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/CharityCategory.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Donor/DonorWidgets/beneficiary_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonorDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';

  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;

  List<Beneficiary> beneficiaries = [];
  List<UrgentCase> urgentCases = [];
  List<Organization> organizations = [];
  List<CharityCategory> charityCategories = [];


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getBeneficiaries();
    _getUrgentCases();
    _getOrganizationUsers();
    _getCharityCategories();
  }

  _refreshPage() {
    beneficiaries.clear();
    urgentCases.clear();
    organizations.clear();
    charityCategories.clear();
    _getCurrentUser();
    _getBeneficiaries();
    _getUrgentCases();
    _getOrganizationUsers();
    _getCharityCategories();
    setState(() {});
}

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getOrganizationUsers() async {
    var ret = await _firestore.collection('OrganizationUsers').where('approved', isEqualTo: true).get();
    for (var element in ret.docs) {
      Organization organization = Organization(
        organizationName: element.data()['organizationName'],
        uid: element.data()['uid'],
        organizationDescription: element.data()['organizationDescription'],
        country: element.data()['country'],
        gatewayLink: element.data()['gatewayLink'],
        profilePictureDownloadURL: element.data()['profilePictureDownloadURL']
      );
      organizations.add(organization);
    }
    setState(() {});
  }


  _getCharityCategories() async {
    var ret = await _firestore.collection('CharityCategories').get();
    for (var element in ret.docs) {
      CharityCategory charityCategory = CharityCategory(
        name: element.data()['name'],
        id: element.data()['id'],
        iconDownloadURL:element.data()['iconDownloadURL']
      );
      charityCategories.add(charityCategory);
    }
    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _firestore.collection('Beneficiaries')
        .where('active',isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
        .get();
    for (var element in ret.docs) {
      Beneficiary beneficiary = Beneficiary(
          name: element.data()['name'],
          biography: element.data()['biography'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID'],
          active: element.data()['active']
      );
      beneficiaries.add(beneficiary);
    }
    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases')
        .where('approved',isEqualTo: true)
        .where('active', isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
        .get();

    for (var element in ret.docs) {
      UrgentCase urgentCase = UrgentCase(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID'],
          active: element.data()['active'],
          approved: element.data()['approved']
      );
      urgentCases.add(urgentCase);
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const DonorDrawer(),
      body: _body(),
      bottomNavigationBar: const DonorBottomNavigationBar(),
    );
  }

  _body() {
    return Container(
    decoration: BoxDecoration(
    color: Colors.blueGrey.shade50,
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    border: Border.all(color: Colors.grey.shade100)),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen())).then((value) => _refreshPage());
                      },
                      child: const Text(
                        'See more >',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 75.0,
              child: ListView.builder(
                itemCount: charityCategories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return CharityCategoryCard(
                      charityCategories[index].name, charityCategories[index].iconDownloadURL);
                },
              )),

          // organization list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Organizations',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizationsExpandedScreen())).then((value) => _refreshPage());
                      },
                      child: const Text(
                        'See more >',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 200.0,
              child: ListView.builder(
                itemCount: organizations.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  print('DOWNLOAD URL: ${organizations[index].profilePictureDownloadURL}');
                  return OrganizationCard(organizations[index]);
                },
              )),

          //beneficiaries list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Beneficiaries',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BeneficiaryExpandedScreen())).then((value) => _refreshPage());
                      },
                      child: const Text(
                        'See more >',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.start,
                      ),
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
                  return BeneficiaryCard(beneficiaries[index]);
                },
              )),

          // urgent case list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Urgent Cases',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UrgentCasesExpandedScreen())).then((value) => _refreshPage());
                      },
                      child: const Text(
                        'See more >',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.start,
                      ),
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
                  return UrgentCaseCard(urgentCases[index]);
                },
              )),
        ],
      ),
    ));
  }
}


