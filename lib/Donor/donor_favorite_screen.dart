import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/urgent_cases_expanded_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/organization_beneficiary_full.dart';
import 'package:donaid/Organization/organization_campaign_full.dart';
import 'package:donaid/Organization/organization_urgentcase_full.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'beneficiaries_expanded_screen.dart';
import 'campaign_donate_screen.dart';


//Start here
class DonorFavoritePage extends StatefulWidget {
  static const id = 'donor_favorite_screen';
  const DonorFavoritePage({Key? key}) : super(key: key);

  @override
  _DonorFavoritePageState createState() => _DonorFavoritePageState();
}

class _DonorFavoritePageState extends State<DonorFavoritePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<Organization> organizations = [];
  List<String> organizationsID = [];
  List<String> beneficiariesID = [];
  List<Campaign> campaigns = [];
  List<String> campaignsID = [];
  List<UrgentCase> urgentCases = [];
  List<String> urgentCasesID = [];
  var f = NumberFormat("###,###.00#", "en_US");
  List<Map<String, dynamic>> _favUser = [];
  final List<Map<String, dynamic>> _allUsers = [];
  var pointlist = [];

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  @override
  initState() {
    _getCurrentUser();
    _getCampaign();
    _favUser = _allUsers;
    super.initState();
  }


  _getCampaign() async {
    var ret = await _firestore
        .collection('Campaigns')
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
      print(campaign.title);

      campaignsID.add(element.data()['id']);
    }
    _getOrganization();
  }

  _getOrganization() async {
    var ret = await _firestore.collection('OrganizationUsers').where('approved', isEqualTo: true).get();
    for (var element in ret.docs) {
      Organization organization = Organization(
        organizationName: element.data()['organizationName'],
        uid: element.data()['uid'],
        organizationDescription: element.data()['organizationDescription'],
        country: element.data()['country'],
        gatewayLink: element.data()['gatewayLink'],
      );
      organizations.add(organization);
    }
    setState(() {});
    _getUrgentCases();
  }

  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('approved', isEqualTo: true)
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
      print(urgentCase.title);

      urgentCasesID.add(element.data()['id']);
    }
    _getBeneficiaries();
  }

  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
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
          active: element.data()['active']); // need to add category
      beneficiaries.add(beneficiary);
      print(beneficiary.name);

      beneficiariesID.add(element.data()['id']);
    }
    _getAllData();
  }

  _getAllData() {
    print(urgentCases.length);
    for (var i = 0; i < urgentCases.length; i++) {
      _allUsers.add({
        "charityType": "Urgent Case",
        "name": urgentCases[i].title,
        "id": urgentCases[i].id,
        "description": urgentCases[i].description,
      });
    }
    for (var i = 0; i < campaigns.length; i++) {
      _allUsers.add({
        "charityType": "Campaigns",
        "name": campaigns[i].title,
        "id": campaigns[i].id,
        "description": campaigns[i].description,
      });
    }
    for (var i = 0; i < beneficiaries.length; i++) {
      _allUsers.add({
        "charityType": "Beneficiary",
        "name": beneficiaries[i].name,
        "id": beneficiaries[i].id,
        "description": campaigns[i].description,

      });
    }
      for (var i = 0; i < organizations.length; i++) {
        _allUsers.add({
          "charityType": "Organization",
          "name": organizations[i].organizationName,
          "id": organizations[i].id,
          "description": organizations[i].organizationDescription,

        });
    }
    print(_allUsers.length);
    _getFavorite();
  }

  _getFavorite() async {
    await _firestore.collection("Favorite").doc('HsOStdM6wWOdRL16MCH9zZ8lJDs1').get().then((value){
      setState(() {
        pointlist = List.from(value['favoriteList']);
      });
    });
    _findFavorite();
  }

  _findFavorite() async {
    List<Map<String, dynamic>> results = [];
    print(pointlist.length);
      for(int i=0; i< pointlist.length; i++){
        print(results);
        results.addAll(_allUsers
            .where((user) =>
        user["id"] == pointlist[i].toString())
            .toList());
      }
    setState(() {
      _favUser = results;
      print(_favUser.length);
    });


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
      return CampaignDonateScreen(campaign);
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
      return (BeneficiaryExpandedScreen());
    }));
  }

  _goToChosenUrgentCase(String id) async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('id', isEqualTo: id)
        .get();
    var doc = ret.docs[0];
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (UrgentCasesExpandedScreen ());
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

              Expanded(
                child: _favUser.isNotEmpty
                    ? ListView.builder(
                  itemCount: _favUser.length,
                  itemBuilder: (context, index) => Card(
                      key: ValueKey(_favUser[index]["name"]),
                      child: Column(children: [
                        ListTile(
                          title: Text(
                            _favUser[index]["name"].toString(),
                          ),
                          subtitle: Text(_favUser[index]["description"].toString(),),
                          trailing: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: FavoriteButton(
                              isFavorite: true,
                              valueChanged: (_isFavorite) {
                                // favoriteFunction(_isFavorite);
                                print('Is Favorite : $_isFavorite');
                              },
                            ),
                          ),

                          onTap: () {
                            if (campaignsID
                                .contains(_favUser[index]['id'])) {
                              _goToChosenCampaign(
                                  _favUser[index]['id']);
                            } else if (beneficiariesID
                                .contains(_favUser[index]['id'])) {
                              _goToChosenBeneficiary(
                                  _favUser[index]['id']);
                            } else if (urgentCasesID
                                .contains(_favUser[index]['id'])) {
                              _goToChosenUrgentCase(
                                  _favUser[index]['id']);
                            }
                            setState(() {
                              //Add the extended view page here
                            });
                          },
                        ),
                        const Divider()
                      ])),
                )
                    : const Text(
                  'No favorites found',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: DonorBottomNavigationBar());
  }
}




