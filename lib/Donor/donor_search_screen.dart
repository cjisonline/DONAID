import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'beneficiary_donate_screen.dart';
import 'campaign_donate_screen.dart';

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
  List<String> beneficiariesID=[];
  List<Campaign> campaigns = [];
  List<String> campaignsID=[];
  List<UrgentCase> urgentCases = [];
  List<String> urgentCasesID=[];
  List<Map<String, dynamic>> _foundUsers = [];
  final List<Map<String, dynamic>> _allUsers = [];
  var f = NumberFormat("###,###.0#", "en_US");
  var searchFieldController = TextEditingController();

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  @override
  initState() {
    _getCurrentUser();
    _getCampaign();
    _foundUsers = _allUsers;
    super.initState();
  }

  _getCampaign() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('approved',isEqualTo: true)
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
          approved: element.data()['approved']);
      urgentCases.add(urgentCase);
      urgentCasesID.add(element.data()['id']);
    }
    _getBeneficiaries();
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
          active: element.data()['active']);
      beneficiaries.add(beneficiary);
      beneficiariesID.add(element.data()['id']);
    }
    setState(() {});
    _getAllData();
  }

  _getAllData() {
    for (var i = 0; i < urgentCases.length; i++) {
      _allUsers.add({
        "id":urgentCases[i].id,
        "name": urgentCases[i].title,
        "goal": f.format(urgentCases[i].goalAmount).toString(),
        "endDate": urgentCases[i].endDate.toDate().toString().substring(
            0, urgentCases[i].endDate.toDate().toString().indexOf(' '))
      });
    }
    for (var i = 0; i < campaigns.length; i++) {
      _allUsers.add({
        "id":campaigns[i].id,
        "name": campaigns[i].title,
        "goal": f.format(campaigns[i].goalAmount).toString(),
        "endDate": campaigns[i]
            .endDate
            .toDate()
            .toString()
            .substring(0, campaigns[i].endDate.toDate().toString().indexOf(' '))
      });
    }
    for (var i = 0; i < beneficiaries.length; i++) {
      _allUsers.add({
        "id":beneficiaries[i].id,
        "name": beneficiaries[i].name,
        "goal": f.format(beneficiaries[i].goalAmount).toString(),
        "endDate": beneficiaries[i].endDate.toDate().toString().substring(
            0, beneficiaries[i].endDate.toDate().toString().indexOf(' '))
      });
    }
    print("\n\n all users Length: " + _allUsers.length.toString());
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

  _goToChosenCampaign(String id)async {
    var ret = await _firestore.collection('Campaigns').where('id',isEqualTo: id).get();
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

  _goToChosenBeneficiary(String id)async {
    var ret = await _firestore.collection('Beneficiaries').where('id',isEqualTo: id).get();
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

  _goToChosenUrgentCase(String id)async {
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
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DONAID'),
        ),
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
                    labelText: 'Search', suffix: IconButton(icon: Icon(Icons.search), onPressed: (){_searchResults(searchFieldController.text);},)),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _foundUsers.isNotEmpty
                    ? ListView.builder(
                  itemCount: _foundUsers.length,
                  itemBuilder: (context, index) => Card(
                      key: ValueKey(_foundUsers[index]["name"]),

                      child: Column(children:[
                        ListTile(
                          title: Text(
                            _foundUsers[index]["name"].toString(),
                          ),
                          subtitle:
                          Text("\u0024 " + _foundUsers[index]['goal']),
                          trailing:
                          Text(_foundUsers[index]["endDate"].toString()),
                          onTap: () {
                            if(campaignsID.contains(_foundUsers[index]['id'])){
                              _goToChosenCampaign(_foundUsers[index]['id']);

                            }
                            else if(beneficiariesID.contains(_foundUsers[index]['id'])){
                              _goToChosenBeneficiary(_foundUsers[index]['id']);
                            }
                            else if(urgentCasesID.contains(_foundUsers[index]['id'])){
                              _goToChosenUrgentCase(_foundUsers[index]['id']);
                            }
                            setState(() {
                              //Add the extended view page here
                            });
                          },
                        ),
                        const Divider()])
                  ),
                )
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
}
