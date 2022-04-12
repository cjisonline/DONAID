
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/updateFavorite.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'beneficiary_donate_screen.dart';
import 'campaign_donate_screen.dart';
// Reset the page
class ResetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DonorFavoritePage();
}

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
  List<Map<String, dynamic>> _favUserUrgentCase = [];
  List<Map<String, dynamic>> _favUserBeneficiary = [];
  List<Map<String, dynamic>> _favUserCampaign = [];
  final List<Map<String, dynamic>> _allUsers = [];
  var pointlist = [];

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }
// Initiate the functions when the page loads
  @override
  initState() {
    _getCurrentUser();
    _getCampaign();
    super.initState();
  }

  _refresh(){
    setState(() {
      pointlist.clear();
      _favUserUrgentCase.clear();
      _favUserBeneficiary.clear();
      _favUserCampaign.clear();
      _getFavorite();
    });

  }

// Get campaign from firebase
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

      campaignsID.add(element.data()['id']);
    }
    _getOrganization();
  }
// Get organization from firebase
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
// Get urgent case from firebase
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
          rejected: element.data()['rejected'],
          approved: element.data()['approved']);
      urgentCases.add(urgentCase);

      urgentCasesID.add(element.data()['id']);
    }
    _getBeneficiaries();
  }
// Get beneficiary from firebase
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

      beneficiariesID.add(element.data()['id']);
    }
    _getAllData();
  }
// Combine all the data from firebase
  _getAllData() {
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
        "description": beneficiaries[i].biography,

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
    _getFavorite();
  }
// Get favorites form firebase under the user
  _getFavorite() async {
    await _firestore.collection("Favorite").doc(loggedInUser!.uid).get().then((value){
      setState(() {
        pointlist = List.from(value['favoriteList']);
      });
    });
    _findFavorite();
  }
// Find favorite to get the favorite information
  _findFavorite() {
    List<Map<String, dynamic>> resultsUrgentCase = [];
    List<Map<String, dynamic>> resultsBeneficiary = [];
    List<Map<String, dynamic>> resultsCampaign = [];
    print(pointlist.length);
      for(int i=0; i< pointlist.length; i++){
        resultsUrgentCase.addAll(_allUsers
            .where((user) =>
            user["id"] == pointlist[i].toString() &&  user["charityType"] == "Urgent Case")
            .toList());
        resultsCampaign.addAll(_allUsers
            .where((user) =>
        user["id"] == pointlist[i].toString() &&  user["charityType"] == "Campaigns")
            .toList());
        resultsBeneficiary.addAll(_allUsers
            .where((user) =>
        user["id"] == pointlist[i].toString() &&  user["charityType"] == "Beneficiary")
            .toList());
      }
    setState(() {
      if(resultsUrgentCase.isNotEmpty){
        _favUserUrgentCase = resultsUrgentCase;
      }
      if(resultsCampaign.isNotEmpty){
        _favUserCampaign = resultsCampaign;
      }
      if(resultsBeneficiary.isNotEmpty){
        _favUserBeneficiary = resultsBeneficiary;
      }
    });


  }
// Campaign tab body for favorite that are campaigns
  _campaignsBody(){
    return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                      child: _favUserCampaign.isNotEmpty
                          ? ListView.builder(
                        // Display name
                        itemCount: _favUserCampaign.length,
                        itemBuilder: (context, index) =>
                            Card(
                            key: ValueKey(_favUserCampaign[index]["name"]),
                            child: Column(children: [
                              ListTile(
                                title: Text(
                                  _favUserCampaign[index]["name"].toString(),
                                ),
                                // display description
                                subtitle: Text(_favUserCampaign[index]["description"].toString(),),
                                trailing: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: FavoriteButton(
                                    iconSize: 50,
                                    isFavorite: true,
                                    valueChanged: (_isFavorite) async {
                                      await updateFavorites(loggedInUser!.uid.toString(),_favUserCampaign[index]["id"].toString());
                                      _refresh();
                                    },
                                  ),
                                ),
                                // Go to the selected campaign page
                                onTap: () {
                                    _goToChosenCampaign(
                                        _favUserCampaign[index]['id']);
                                },
                              ),
                              const Divider()
                            ])),
                      )
                          : Center(
                        // No favorite campaign under the user
                            child: Text(
                        'No favorites found'.tr,
                        style: TextStyle(fontSize: 24),
                      ),
                          ),
                    ),
                  ],
                )
    );
  }
// Beneficiary tab body for favorite that are beneficiaries
  _beneficiariesBody(){
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: _favUserBeneficiary.isNotEmpty
                  ? ListView.builder(
                // display name
                itemCount: _favUserBeneficiary.length,
                itemBuilder: (context, index) => Card(
                    key: ValueKey(_favUserBeneficiary[index]["name"]),
                    child: Column(children: [
                      ListTile(
                        title: Text(
                          _favUserBeneficiary[index]["name"].toString(),
                        ),
                        //Display description
                        subtitle: Text(_favUserBeneficiary[index]["description"].toString(),),
                        trailing: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FavoriteButton(
                            iconSize: 50,
                            isFavorite: true,
                            valueChanged: (_isFavorite) async {
                              await updateFavorites(loggedInUser!.uid.toString(),_favUserBeneficiary[index]["id"].toString());
                              _refresh();
                            },
                          ),
                        ),
                        // Go to the selected beneficiary page
                        onTap: () {
                            _goToChosenBeneficiary(
                                _favUserBeneficiary[index]['id']);
                        },
                      ),
                      const Divider()
                    ])),
              )
                  : Center(
                    child: Text(
                      // No beneficiary favorite by this user.
                'No favorites found'.tr,
                style: TextStyle(fontSize: 24),
              ),
                  ),
            ),
          ],
        )
    );

  }
// Urgent case tab body for favorite that are beneficiaries
  _urgentCasesBody(){
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: _favUserUrgentCase.isNotEmpty
                  ? ListView.builder(
                itemCount: _favUserUrgentCase.length,
                itemBuilder: (context, index) => Card(
                  // Display urgent case name
                    key: ValueKey(_favUserUrgentCase[index]["name"]),
                    child: Column(children: [
                      ListTile(
                        title: Text(
                          _favUserUrgentCase[index]["name"].toString(),
                        ),
                        // Display urgent case description
                        subtitle: Text(_favUserUrgentCase[index]["description"].toString(),),
                        trailing: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FavoriteButton(
                            iconSize: 50,
                            isFavorite: true,
                            valueChanged: (_isFavorite) async {
                              await updateFavorites(loggedInUser!.uid.toString(),_favUserUrgentCase[index]["id"].toString());
                              _refresh();
                            },
                          ),
                        ),
                        // go to the selected urgent case page
                        onTap: () {
                            _goToChosenUrgentCase(
                                _favUserUrgentCase[index]['id']);;
                        },
                      ),
                      const Divider()
                    ])),
              )
                  : Center(
                    child: Text(
                      // No urgent case favorite found for the user
                'No favorites found'.tr,
                style: TextStyle(fontSize: 24),
              ),
                  ),
            ),
          ],
        )
    );

  }


// Get the information for the selected campaign from firebase
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
// Get the information for the selected beneficiary from firebase
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
// Get the information for the selected urgent case from firebase
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
        rejected: doc.data()['rejected'],
        approved: doc.data()['approved']);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (UrgentCaseDonateScreen(urgentCase));
    }));
  }
// Favorite page UI
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(tabs: [Tab(text: 'campaigns'.tr,), Tab(text: 'beneficiaries'.tr,), Tab(text: 'urgent_cases'.tr,)],),
          title: Text('Favorite Page'.tr),
          leading: IconButton(
            // Go back from favorite page
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        // Display donor drawer
        drawer: const DonorDrawer(),
        //Donor body tab view
        body: TabBarView(
          children: [
            _campaignsBody(),
            _beneficiariesBody(),
            _urgentCasesBody()
          ],
        ),
        //Display donor bottom navigation bar
        bottomNavigationBar: DonorBottomNavigationBar(),
      ),
    );
  }

}




