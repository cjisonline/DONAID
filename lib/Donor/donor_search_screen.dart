import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'DonorWidgets/donor_drawer.dart';
import 'beneficiary_donate_screen.dart';
import 'campaign_donate_screen.dart';
import 'organization_tab_view.dart';

class ResetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const DonorSearchScreen();
}

class DonorSearchScreen extends StatefulWidget {
  static const id = 'donor_search_screen';
  const DonorSearchScreen({Key? key}) : super(key: key);

  @override
  _DonorSearchScreenState createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<String> beneficiariesID = [];
  List<Campaign> campaigns = [];
  List<String> campaignsID = [];
  List<UrgentCase> urgentCases = [];
  List<String> urgentCasesID = [];
  List<Organization> organizations = [];
  List<String> organizationsID = [];
  List<Map<String, dynamic>> _foundUsers = [];
  final List<Map<String, dynamic>> _allUsers = [];
  var campaignCategory = [];
  var campaignType = ["Urgent Case", "Campaign", "Beneficiary"];
  List<String> moneyPercentChoice = ['0-25%', '25-50%', '50-75%', '75-99%'];
  List<String> endDateRangeChoices = [
    'This Week',
    'This Month',
    '3 months',
    '6 months'
  ];
  var f = NumberFormat("###,###.00#", "en_US");
  var searchFieldController = TextEditingController();
  var categoryFilterController = TextEditingController();
  var moneyRaisedFilterController = TextEditingController();
  var charityTypeFilterController = TextEditingController();
  var endDateFilterController = TextEditingController();

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  @override
  initState() {
    _getCurrentUser();
    _getCategories();
    _foundUsers = _allUsers;
    super.initState();
  }

  _getCategories() async {
    var ret = await _firestore.collection('CharityCategories').get();
    ret.docs.forEach((element) {
      campaignCategory.add(element.data()['name']);
    });
    _getOrganizationUsers();

    setState(() {});
  }

  _getOrganizationUsers() async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('approved', isEqualTo: true)
        .get();
    for (var element in ret.docs) {
      Organization organization = Organization(
        organizationName: element.data()['organizationName'],
        uid: element.data()['uid'],
        id: element.data()['id'],
        organizationDescription: element.data()['organizationDescription'],
        country: element.data()['country'],
        gatewayLink: element.data()['gatewayLink'],
      );
      organizations.add(organization);
      organizationsID.add(element.data()['id']);
    }
    _getCampaign();
    setState(() {});
  }

  _getCampaign() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('active', isEqualTo: true)
        .get();

    for (var element in ret.docs) {
      Campaign campaign = Campaign(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID'],
          active: element.data()['active']);
      campaigns.add(campaign);
      campaignsID.add(element.data()['id']);
    }
    _getUrgentCases();
    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('approved', isEqualTo: true)
        .where('active', isEqualTo: true)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate', descending: false)
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
          approved: element.data()['approved']);
      urgentCases.add(urgentCase);
      urgentCasesID.add(element.data()['id']);
      // moneyRaisedChoices.add(element.data()['amountRaised'].toString());

    }
    _getBeneficiaries();
    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('active', isEqualTo: true)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate', descending: false)
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
          active: element.data()['active']);
      beneficiaries.add(beneficiary);
      beneficiariesID.add(element.data()['id']);
      // moneyRaisedChoices.add(element.data()['amountRaised'].toString());

    }
    setState(() {});
    _getAllData();
  }

  _getAllData() {
    for (var i = 0; i < organizations.length; i++) {
      _allUsers.add({
        "id": organizations[i].id,
        "name": organizations[i].organizationName,
        "goal": "",
        "endDate": "",
        "collection": "OrganizationUsers",
        "category": "",
        "charityType": "",
        "amountRaised": "",
        "amountRaisedPercent": "",
        "endDateFromNow": ""
      });
    }
    for (var i = 0; i < urgentCases.length; i++) {
      _allUsers.add({
        "amountRaised": urgentCases[i].amountRaised,
        "id": urgentCases[i].id,
        "name": urgentCases[i].title,
        "goal": urgentCases[i].goalAmount,
        "endDate": urgentCases[i].endDate,
        "collection": "UrgentCases",
        "category": urgentCases[i].category,
        "charityType": "Urgent Case",
        "amountRaisedPercent":
            ((urgentCases[i].amountRaised / urgentCases[i].goalAmount) * 100)
                .toStringAsFixed(0),
        "endDateFromNow": (DateTime.parse((urgentCases[i]
                    .endDate
                    .toDate()
                    .toString()
                    .substring(
                        0,
                        urgentCases[i]
                            .endDate
                            .toDate()
                            .toString()
                            .indexOf(' '))))
                .difference(DateTime.now())
                .inDays)
            .toString()
      });
    }
    for (var i = 0; i < campaigns.length; i++) {
      _allUsers.add({
        "amountRaised": campaigns[i].amountRaised,
        "id": campaigns[i].id,
        "name": campaigns[i].title,
        "goal": campaigns[i].goalAmount,
        "endDate": campaigns[i].endDate,
        "collection": "Campaigns",
        "category": campaigns[i].category,
        "charityType": "Campaign",
        "amountRaisedPercent":
            ((campaigns[i].amountRaised / campaigns[i].goalAmount) * 100)
                .toStringAsFixed(0),
        "endDateFromNow": (DateTime.parse((campaigns[i]
                    .endDate
                    .toDate()
                    .toString()
                    .substring(0,
                        campaigns[i].endDate.toDate().toString().indexOf(' '))))
                .difference(DateTime.now())
                .inDays)
            .toString()
      });
    }
    for (var i = 0; i < beneficiaries.length; i++) {
      _allUsers.add({
        "amountRaised": beneficiaries[i].amountRaised,
        "id": beneficiaries[i].id,
        "name": beneficiaries[i].name,
        "goal": beneficiaries[i].goalAmount,
        "endDate": beneficiaries[i].endDate,
        "collection": "Beneficiaries",
        "category": beneficiaries[i].category,
        "charityType": "Beneficiary",
        "amountRaisedPercent":
            ((beneficiaries[i].amountRaised / beneficiaries[i].goalAmount) *
                    100)
                .toStringAsFixed(0),
        "endDateFromNow": (DateTime.parse((beneficiaries[i]
                    .endDate
                    .toDate()
                    .toString()
                    .substring(
                        0,
                        beneficiaries[i]
                            .endDate
                            .toDate()
                            .toString()
                            .indexOf(' '))))
                .difference(DateTime.now())
                .inDays)
            .toString()
      });
    }
  }

  void _searchResults(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundUsers = results;
    });
  }

  void _charityTypeResult() {
    if(charityTypeFilterController.text.isNotEmpty){
      List<Map<String, dynamic>> results = [];
      results = _foundUsers
          .where(
              (user) => user["charityType"].contains(charityTypeFilterController.text))
          .toList();
      setState(() {
        _foundUsers = results;
      });
    }
  }

  void _categoryResult() {
    if(categoryFilterController.text.isNotEmpty){
      List<Map<String, dynamic>> results = [];
      results = _foundUsers
          .where((user) => (user['collection'] != 'OrganizationUsers'))
          .where((user) => user["category"].contains(categoryFilterController.text))
          .toList();
      setState(() {
        _foundUsers = results;
      });
    }
  }

  void _goalAmountResults() {
    if(moneyRaisedFilterController.text.isNotEmpty){
      List<Map<String, dynamic>> results = [];
      if (moneyRaisedFilterController.text == '0-25%') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) =>
        (user['amountRaised'] / user['goal']) >= 0 &&
            (user['amountRaised'] / user['goal']) <= 0.25)
            .toList();
      }
      if (moneyRaisedFilterController.text == '25-50%') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) =>
        (user['amountRaised'] / user['goal']) >= .25 &&
            (user['amountRaised'] / user['goal']) <= 0.50)
            .toList();
      }
      if (moneyRaisedFilterController.text == '50-75%') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) =>
        (user['amountRaised'] / user['goal']) >= .50 &&
            (user['amountRaised'] / user['goal']) <= 0.75)
            .toList();
      }
      if (moneyRaisedFilterController.text == '75-99%') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) =>
        (user['amountRaised'] / user['goal']) >= .75 &&
            (user['amountRaised'] / user['goal']) <= 0.99)
            .toList();
      }
      setState(() {
        _foundUsers = results;
      });
    }
  }

  void _endDateResults() {
    if (endDateFilterController.text.isNotEmpty){
      List<Map<String, dynamic>> results = [];
      if (endDateFilterController.text == 'This Week') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) => ((user['endDate']
            .toDate()
            .difference(Timestamp.now().toDate())
            .inDays <=
            7)))
            .toList();
      } else if (endDateFilterController.text == 'This Month') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) => ((user['endDate']
            .toDate()
            .difference(Timestamp.now().toDate())
            .inDays <=
            30)))
            .toList();
      } else if (endDateFilterController.text == '3 months') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) => ((user['endDate']
            .toDate()
            .difference(Timestamp.now().toDate())
            .inDays <=
            90)))
            .toList();
      } else if (endDateFilterController.text == '6 months') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) => ((user['endDate']
            .toDate()
            .difference(Timestamp.now().toDate())
            .inDays <=
            180)))
            .toList();
      }
      setState(() {
        _foundUsers = results;
      });
    }
  }
  _filterResults(){
    _foundUsers = _allUsers;
    _charityTypeResult();
    _categoryResult();
    _goalAmountResults();
    _endDateResults();
  }

  _goToChosenOrganization(String id) async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('id', isEqualTo: id)
        .get();
    var doc = ret.docs[0];
    Organization organization = Organization(
      organizationName: doc.data()['organizationName'],
      uid: doc.data()['uid'],
      id: doc.data()['id'],
      organizationDescription: doc.data()['organizationDescription'],
      country: doc.data()['country'],
      gatewayLink: doc.data()['gatewayLink'],
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (OrganizationTabViewScreen(organization: organization));
    }));
  }

  _goToChosenCampaign(String id) async {
    var ret = await _firestore
        .collection('Campaigns')
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
        active: doc.data()['active']);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (CampaignDonateScreen(campaign));
    }));
  }

  _goToChosenBeneficiary(String id) async {
    var ret = await _firestore
        .collection('Beneficiaries')
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
        active: doc.data()['active']);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (BeneficiaryDonateScreen(beneficiary));
    }));
  }

  _goToChosenUrgentCase(String id) async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('id', isEqualTo: id)
        .get();
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
        approved: doc.data()['approved']);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (UrgentCaseDonateScreen(urgentCase));
    }));
  }

  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => ResetWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:  Text('donaid'.tr),
          actions: <Widget>[
            TextButton(
                onPressed: _reset,
                child:
                    Text('reset'.tr, style: const TextStyle(color: Colors.white))),
          ],
        ),
        drawer: const DonorDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                onChanged: (val) {
                  _searchResults(val.toString());
                },
                controller: searchFieldController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            label: Center(
                              child: RichText(
                                  text: TextSpan(
                                text: 'category'.tr,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12.0),
                              )),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: campaignCategory == null
                            ? []
                            : campaignCategory.map((items) {
                                return DropdownMenuItem<String>(
                                  child: Text(items),
                                  value: items,
                                );
                              }).toList(),
                        onChanged: (val) => setState(() {
                          categoryFilterController.text = val.toString();
                          _filterResults();
                        }),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            label: Center(
                              child: RichText(
                                  text: TextSpan(
                                text: 'charity_type'.tr,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12.0),
                              )),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: campaignType == null
                            ? []
                            : campaignType.map((items) {
                                return DropdownMenuItem<String>(
                                  child: Text(items),
                                  value: items,
                                );
                              }).toList(),
                        onChanged: (val) => setState(() {
                          charityTypeFilterController.text = val.toString();
                          _filterResults();
                        }),
                      )),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            label: Center(
                              child: RichText(
                                  text: TextSpan(
                                text: '% raised'.tr,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12.0),
                              )),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: moneyPercentChoice.map((items) {
                          return DropdownMenuItem<String>(
                            child: Text(items),
                            value: items,
                          );
                        }).toList(),
                        onChanged: (val) => setState(() {
                          moneyRaisedFilterController.text = val.toString();
                          _filterResults();
                        }),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            label: Center(
                              child: RichText(
                                  text: TextSpan(
                                text: 'end_date'.tr,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12.0),
                              )),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: endDateRangeChoices.map((items) {
                          return DropdownMenuItem<String>(
                            child: Text(items),
                            value: items,
                          );
                        }).toList(),
                        onChanged: (val) => setState(() {
                          endDateFilterController.text = val.toString();
                          _filterResults();

                        }),
                      )),
                ],
              ),
              Expanded(
                child: _foundUsers.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundUsers.length,
                        itemBuilder: (context, index) {
                          if (_foundUsers[index]["collection"] ==
                              "OrganizationUsers") {
                            return Card(
                                key: ValueKey(_foundUsers[index]["name"]),
                                child: Column(children: [
                                  ListTile(
                                    title: Text(
                                      _foundUsers[index]["name"].toString(),
                                    ),
                                    onTap: () {
                                      if (organizationsID
                                          .contains(_foundUsers[index]['id'])) {
                                        _goToChosenOrganization(
                                            _foundUsers[index]['id']);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  const Divider()
                                ]));
                          } else {
                            return Card(
                                key: ValueKey(_foundUsers[index]["name"]),
                                child: Column(children: [
                                  ListTile(
                                    title: Text(
                                      _foundUsers[index]["name"].toString(),
                                    ),
                                    subtitle: Text('\$' +
                                        f.format(_foundUsers[index]['goal'])),
                                    trailing: Text(DateFormat('yyyy-MM-dd')
                                        .format((_foundUsers[index]["endDate"]
                                            .toDate()))),
                                    onTap: () {
                                      if (campaignsID
                                          .contains(_foundUsers[index]['id'])) {
                                        _goToChosenCampaign(
                                            _foundUsers[index]['id']);
                                      } else if (beneficiariesID
                                          .contains(_foundUsers[index]['id'])) {
                                        _goToChosenBeneficiary(
                                            _foundUsers[index]['id']);
                                      } else if (urgentCasesID
                                          .contains(_foundUsers[index]['id'])) {
                                        _goToChosenUrgentCase(
                                            _foundUsers[index]['id']);
                                      }
                                      setState(() {
                                        //Add the extended view page here
                                      });
                                    },
                                  ),
                                ]));
                          }
                        },
                      )
                    :  Text(
                        'no_results_found'.tr,
                        style: TextStyle(fontSize: 24),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: DonorBottomNavigationBar());
  }
}
