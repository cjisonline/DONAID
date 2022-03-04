import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'DonorWidgets/donor_drawer.dart';
import 'beneficiary_donate_screen.dart';
import 'campaign_donate_screen.dart';
import 'organization_tab_view.dart';

class Choice {
  String choice;
  int caseNumber;

  Choice(this.choice, this.caseNumber);

  @override
  String toString() {
    return '{ ${this.choice}, ${this.caseNumber} }';
  }
}

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
  List<Choice> choices = [];
  List<String> beneficiariesID = [];
  List<Campaign> campaigns = [];
  List<String> campaignsID = [];
  List<UrgentCase> urgentCases = [];
  List<String> urgentCasesID = [];
  List<Organization> organizations = [];
  List<String> organizationsID = [];
  List<Map<String, dynamic>> _foundUsers = [];
  final List<Map<String, dynamic>> _allUsers = [];
  Map<String, dynamic> selectedFilter = {
    "category": "",
    "charityType": "",
    "%Raised": "",
    "endDate": ""
  };
  var campaignCategory = [];
  var campaignType = ["Urgent Case", "Campaign", "Beneficiary"];
  List<String> moneyPercentChoice = ['0-25%', '25-50%', '50-75%', '75-99%'];
  List<String> endDateRangeChoices = [
    'This Week',
    'This Month',
    '3 months',
    '6 months'
  ];
  var f = NumberFormat("###,###.0#", "en_US");
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
        .where('approved', isEqualTo: true)
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
      // moneyRaisedChoices.add(element.data()['amountRaised'].toString());
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
        "endDate": urgentCases[i].endDate.toDate().toString().substring(
            0, urgentCases[i].endDate.toDate().toString().indexOf(' ')),
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
        "endDate": campaigns[i].endDate.toDate().toString().substring(
            0, campaigns[i].endDate.toDate().toString().indexOf(' ')),
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
        "endDate": beneficiaries[i].endDate.toDate().toString().substring(
            0, beneficiaries[i].endDate.toDate().toString().indexOf(' ')),
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

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  _goToChosenOrganization(String id) async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('approved', isEqualTo: true)
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
          title: const Text('DONAID'),
          actions: <Widget>[
            FlatButton(
              onPressed: _reset,
              child: Text('RESET'),
            ),
          ],
        ),
        drawer: const DonorDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: (value) => _searchResults(value),
                controller: searchFieldController,
                decoration: InputDecoration(
                    labelText: 'Search',
                    suffix: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _searchResults(searchFieldController.text);
                      },
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(children: <Widget>[
                Container(
                    width: 150.0,
                    height: 60,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: TextSpan(
                              text: 'Category',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 20.0),
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
                        selectedFilter['category'] =
                            categoryFilterController.text;
                        Choice choice =
                            Choice(categoryFilterController.text, 1);
                        choices.add(choice);
                      }),
                    )),
                const SizedBox(
                  width: 20,
                ),
                Container(
                    width: 150.0,
                    height: 60,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: TextSpan(
                              text: 'Charity Type',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 20.0),
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
                        selectedFilter['charityType'] =
                            charityTypeFilterController.text;
                        Choice choice =
                            Choice(charityTypeFilterController.text, 2);
                        choices.add(choice);
                      }),
                    ))
              ]),
              Row(children: <Widget>[
                Container(
                    width: 150.0,
                    height: 60,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: TextSpan(
                              text: '% Raised',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 20.0),
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
                      //   Map<String, dynamic> moneyRaisedChoices = {
                      onChanged: (val) => setState(() {
                        moneyRaisedFilterController.text = val.toString();
                        selectedFilter['%Raised'] =
                            moneyRaisedFilterController.text;

                        Choice choice =
                            Choice(moneyRaisedFilterController.text, 3);
                        choices.add(choice);
                      }),
                    )),
                const SizedBox(
                  width: 20,
                ),
                Container(
                    width: 150.0,
                    height: 60,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: TextSpan(
                              text: 'End Date',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 20.0),
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
                        selectedFilter['endDate'] =
                            endDateFilterController.text;
                        Choice choice = Choice(endDateFilterController.text, 4);
                        choices.add(choice);
                      }),
                    )),
              ]),
              RaisedButton(
                child: Text('SUBMIT'),
                onPressed: () {
                  if (searchFieldController.text.isNotEmpty) {
                    searchFieldController.text;
                    Choice choice = Choice(searchFieldController.text, 0);
                    choices.add(choice);
                    _filterResults(choices);
                  } else {
                    _filterResults(choices);
                  }
                },
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
                                      setState(() {
                                        //Add the extended view page here
                                      });
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
                                        _foundUsers[index]['goal'].toString()),
                                    trailing: Text(_foundUsers[index]["endDate"]
                                        .toString()),
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
                                  const Divider()
                                ]));
                          }
                        })
                    : const Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: DonorBottomNavigationBar());
  }

  void _filterResults(List<Choice> choices) {
    List<Map<String, dynamic>> results = [];
    bool exit = false;
    _foundUsers = _allUsers;
    if (selectedFilter['category'] != '') {
      if (_foundUsers.isNotEmpty && exit != true) {
        if (_foundUsers
                .where((user) =>
                    user["category"].contains(selectedFilter['category']))
                .toList() ==
            false) {
          _foundUsers.clear();
          exit = true;
        } else {
          results = _foundUsers
              .where((user) =>
                  user["category"].contains(selectedFilter['category']))
              .toList();
          _foundUsers = results;
        }
      } else if (_foundUsers.isEmpty && exit != true) {
        results = _allUsers
            .where(
                (user) => user["category"].contains(selectedFilter['category']))
            .toList();
        _foundUsers = results;
      }
    }
    if (selectedFilter['charityType'] != '') {
      if (_foundUsers.isNotEmpty && exit != true) {
        if (_foundUsers
                .where((user) =>
                    user["charityType"].contains(selectedFilter['charityType']))
                .toList() ==
            false) {
          _foundUsers.clear();
          exit = true;
        } else {
          results = _foundUsers
              .where((user) =>
                  user["charityType"].contains(selectedFilter['charityType']))
              .toList();
          _foundUsers = results;
        }
      } else if (_foundUsers.isEmpty && exit != true) {
        results = _allUsers
            .where((user) =>
                user["charityType"].contains(selectedFilter['charityType']))
            .toList();
        _foundUsers = results;
      }
    }
    if (selectedFilter['%Raised'] != '') {
      if (moneyRaisedFilterController.text == '0-25%') {
        print('in 0-25 if');
        print("found users" + _foundUsers.length.toString());
        print("all users" + _allUsers.length.toString());
        results = _foundUsers
            .where((user) {
              // print('in if${user['collection']} ${user['amountRaised']} goal: ${user['goal']}');
              return user['collection'] != 'OrganizationUsers';
            })
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
    }
    if (selectedFilter['endDate'] != '') {
      if (endDateFilterController.text == 'This Week') {
        print(Timestamp.now().toDate().toString());
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) {
          print(DateTime.parse(user['endDate'].toString()));
          int days = DateTime.parse(user['endDate'])
              .difference(Timestamp.now().toDate())
              .inDays;
          print("num days: $days");
          return DateTime.parse(user['endDate'])
                  .difference(Timestamp.now().toDate())
                  .inDays <=
              7;
        }).toList();
      }
      if (endDateFilterController.text == 'This Month') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) =>
        DateTime.parse(user['endDate'])
            .difference(Timestamp.now().toDate())
            .inDays <=
                30)
            .toList();
      }
      if (endDateFilterController.text == '3 months') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) {
          print(DateTime.parse(user['endDate'].toString()));
          int days = DateTime.parse(user['endDate'])
              .difference(Timestamp.now().toDate())
              .inDays;
          print("num days: $days");
       return DateTime.parse(user['endDate'])
            .difference(Timestamp.now().toDate())
            .inDays <=
                90;})
            .toList();
      }
      if (endDateFilterController.text == '6 months') {
        results = _foundUsers
            .where((user) => (user['collection'] != 'OrganizationUsers'))
            .where((user) =>
        DateTime.parse(user['endDate'])
            .difference(Timestamp.now().toDate())
            .inDays <=
                180)
            .toList();
      }
    }
    setState(() {
      _foundUsers = results;
    });
  }
    // Refresh the UI
  }

