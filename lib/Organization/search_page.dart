import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_beneficiary_full.dart';
import 'package:donaid/Organization/organization_urgentcase_full.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'organization_campaign_full.dart';
// Reset search page
class ResetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => OrgSearchPage();
}

//search page of organization
class OrgSearchPage extends StatefulWidget {
  static const id = 'search_page';
  const OrgSearchPage({Key? key}) : super(key: key);

  @override
  _OrgSearchPageState createState() => _OrgSearchPageState();
}

class _OrgSearchPageState extends State<OrgSearchPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<Beneficiary> allBeneficiaries = [];

  List<Campaign> campaigns = [];
  List<Campaign> allCampaigns = [];

  List<UrgentCase> urgentCases = [];
  List<UrgentCase> allUrgentCases = [];

  List<String> sortingChoices = [
    'Percent Raised - Ascending',
    'Percent Raised - Descending',
    'End Date - Soonest',
    'End Date - Latest'
  ];
  var f = NumberFormat("###,###.00#", "en_US");
  var searchFieldController = TextEditingController();
  var categoryFilterController = TextEditingController();
  var sortingController = TextEditingController();

  var campaignCategory = [];

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }
// init the data functions
  @override
  initState() {
    _getCurrentUser();
    _getCampaign();
    _getCategories();
    _getUrgentCases();
    _getBeneficiaries();
    super.initState();
  }
//Get category from firebase
  _getCategories() async {
    var ret = await _firestore
        .collection('CharityCategories')
        .get();
    ret.docs.forEach((element) {
      campaignCategory.add(element.data()['name']);
    });

    setState(() {});
  }
//Get campaign get from firebase
  _getCampaign() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
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
      allCampaigns.add(campaign);
    }
    setState(() {});
  }
// Get urgent case data from firebase
  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
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
      allUrgentCases.add(urgentCase);

    }

    setState(() {});
  }
// Get beneficiary from firebase
  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
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
      allBeneficiaries.add(beneficiary);
    }
    setState(() {});
  }
// Search result function that searches and create an array of search results
  void _searchResults(String enteredKeyword) {
    _filterResults();
    if (enteredKeyword.isEmpty) {
      campaigns = allCampaigns;
      beneficiaries = allBeneficiaries;
      urgentCases = allUrgentCases;
    } else {
      campaigns = campaigns
          .where((item) =>
          item.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      beneficiaries = beneficiaries
          .where((item) =>
          item.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      urgentCases = urgentCases
          .where((item) =>
          item.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
    });
  }
// Category results from the filter and create an array of category results
  void _categoryResult() {
    if(categoryFilterController.text.isNotEmpty){
      campaigns = campaigns
          .where((item) => item.category.contains(categoryFilterController.text))
          .toList();

      beneficiaries = beneficiaries
          .where((item) => item.category.contains(categoryFilterController.text))
          .toList();

      urgentCases = urgentCases
          .where((item) => item.category.contains(categoryFilterController.text))
          .toList();


      setState(() {
      });
    }
  }
// sort by date and amount raised results from the sort and create an array of sort results
  void _sortResults(){
    if(sortingController.text.isNotEmpty){

      if(sortingController.text == 'Percent Raised - Ascending'){
        campaigns.sort((a, b) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        beneficiaries.sort((a, b) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        urgentCases.sort((a, b) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
      }
      else if(sortingController.text == 'Percent Raised - Descending'){
        campaigns.sort((b, a) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        beneficiaries.sort((b, a) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        urgentCases.sort((b, a) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
      }
      else if(sortingController.text ==  'End Date - Soonest'){
        campaigns.sort((a, b) => a.endDate.compareTo(b.endDate));
        beneficiaries.sort((a, b) => a.endDate.compareTo(b.endDate));
        urgentCases.sort((a, b) => a.endDate.compareTo(b.endDate));
      }
      else if(sortingController.text == 'End Date - Latest'){
        campaigns.sort((b, a) => a.endDate.compareTo(b.endDate));
        beneficiaries.sort((b, a) => a.endDate.compareTo(b.endDate));
        urgentCases.sort((b, a) => a.endDate.compareTo(b.endDate));
      }

      setState(() {
      });
    }
  }
// Go data for the full screen of the selected campaign
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
      return (OrganizationCampaignFullScreen(campaign));
    }));
  }
// Go data for the full screen of the selected beneficiary
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
      return (OrganizationBeneficiaryFullScreen(beneficiary));
    }));
  }
// Go data for the full screen of the selected urgent case
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
      return (OrganizationUrgentCaseFullScreen(urgentCase));
    }));
  }
// Reset page function
  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => ResetWidget(),
      ),
    );
  }
// Category results
  _filterResults(){
    campaigns = allCampaigns;
    beneficiaries = allBeneficiaries;
    urgentCases = allUrgentCases;
    _categoryResult();
  }


// Set up the search page UI
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title:  Text('search'.tr),
            bottom: TabBar(tabs: [Tab(text: 'campaigns'.tr), Tab(text: 'beneficiaries'.tr), Tab(text: 'urgent_cases'.tr)],),
            actions: <Widget>[
              // reset button and on tap reset the page
              TextButton(
                onPressed: _reset,
                child: Text('reset'.tr, style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
      // Search tabs
          body: TabBarView(
            children: [
              _buildCampaignsBody(),
              _buildBeneficiariesBody(),
              _buildUrgentCasesBody()
            ],
          ),
          // Display the organization drawer
          drawer: OrganizationDrawer(),
          // Display the organization bottom navigation
          bottomNavigationBar: OrganizationBottomNavigation()),
    );
  }
// Campaign body
  _buildCampaignsBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [

          TextField(
            onChanged: (val){
              _searchResults(val.toString());
            },
            // display search bar
            controller: searchFieldController,
            decoration:  InputDecoration(
              labelText: 'search'.tr,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField <String>(
                    decoration: InputDecoration(
                        label: Center(
                            child: Text('category'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon:  Visibility(visible: false, child: Icon(Icons.keyboard_arrow_down)),
                    value: categoryFilterController.text.isNotEmpty ? categoryFilterController.text : null,
                    items: campaignCategory == null? []: campaignCategory.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(
                          items,
                        ),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      categoryFilterController.text = val.toString();
                      _filterResults();
                    }),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                // display sort by dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                        label: Center(
                            child: Text('Sort By'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: Icon(Icons.keyboard_arrow_down)),
                    value: sortingController.text.isNotEmpty ? sortingController.text : null,
                    items: sortingChoices.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      sortingController.text = val.toString();
                      _sortResults();
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Results display
          Expanded(
            child: campaigns.isNotEmpty
                ? ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) => Card(
                  key: ValueKey(campaigns[index].title),
                  child: Column(children: [
                    ListTile(
                      title: Text(
                        campaigns[index].title,
                      ),
                      subtitle: Text('\$'+f.format(campaigns[index].goalAmount)),
                      trailing: Text(
                          DateFormat('yyyy-MM-dd').format((campaigns[index].endDate.toDate()))),
                      onTap: () {
                        _goToChosenCampaign(
                            campaigns[index].id);
                      },
                    ),
                    const Divider()
                  ])),
            )
                :  Text(
              // If there are not results
              'no_results_found'.tr,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  _buildBeneficiariesBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [

          TextField(
            onChanged: (val){
              _searchResults(val.toString());
            },
            // display Search bar
            controller: searchFieldController,
            decoration:  InputDecoration(
              labelText: 'search'.tr,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Expanded(
                //Category dropdown display
                child: DropdownButtonFormField <String>(
                  decoration: InputDecoration(
                      label: Center(
                          child: Text('category'.tr)
                      ),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12.0)),
                      )),
                  icon:  Visibility(visible: false, child: Icon(Icons.keyboard_arrow_down)),
                  value: categoryFilterController.text.isNotEmpty ? categoryFilterController.text : null,
                  items: campaignCategory == null? []: campaignCategory.map((items) {
                    return DropdownMenuItem<String>(
                      child: Text(
                        items,
                      ),
                      value: items,
                    );
                  }).toList(),
                  onChanged: (val) => setState(() {
                    categoryFilterController.text = val.toString();
                    _filterResults();
                  }),
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                //Sort by dropdown display
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                        label: Center(
                            child: Text('Sort By'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: Icon(Icons.keyboard_arrow_down)),
                    value: sortingController.text.isNotEmpty ? sortingController.text : null,
                    items: sortingChoices.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      sortingController.text = val.toString();
                      _sortResults();
                    }),
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),

          Expanded(
            // Display Beneficiary results
            child: beneficiaries.isNotEmpty
                ? ListView.builder(
              itemCount: beneficiaries.length,
              itemBuilder: (context, index) => Card(
                  key: ValueKey(beneficiaries[index].name ),
                  child: Column(children: [
                    ListTile(
                      title: Text(
                        beneficiaries[index].name ,
                      ),
                      subtitle: Text('\$'+f.format(beneficiaries[index].goalAmount)),
                      trailing: Text(
                          DateFormat('yyyy-MM-dd').format((beneficiaries[index].endDate.toDate()))),
                      onTap: () {
                        _goToChosenBeneficiary(
                            beneficiaries[index].id);
                      },
                    ),
                    const Divider()
                  ])),
            )
                :  Text(
              // No results found
              'no_results_found'.tr,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  _buildUrgentCasesBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [

          TextField(
            onChanged: (val){
              _searchResults(val.toString());
            },
            // display Search bar
            controller: searchFieldController,
            decoration:  InputDecoration(
              labelText: 'search'.tr,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Expanded(
                // Display dropdown category
                child: DropdownButtonFormField <String>(
                  decoration: InputDecoration(
                      label: Center(
                          child: Text('category'.tr)
                      ),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12.0)),
                      )),
                  icon:  Visibility(visible: false, child: Icon(Icons.keyboard_arrow_down)),
                  value: categoryFilterController.text.isNotEmpty ? categoryFilterController.text : null,
                  items: campaignCategory == null? []: campaignCategory.map((items) {
                    return DropdownMenuItem<String>(
                      child: Text(
                        items,
                      ),
                      value: items,
                    );
                  }).toList(),
                  onChanged: (val) => setState(() {
                    categoryFilterController.text = val.toString();
                    _filterResults();
                  }),
                ),
              ),
              SizedBox(width: 20,),
              // Sort by dropdown display
              Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                        label: Center(
                            child: Text('Sort By'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: Icon(Icons.keyboard_arrow_down)),
                    value: sortingController.text.isNotEmpty ? sortingController.text : null,
                    items: sortingChoices.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      sortingController.text = val.toString();
                      _sortResults();
                    }),
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),

        //Urgent case results display
          Expanded(
            child: urgentCases.isNotEmpty
                ? ListView.builder(
              itemCount: urgentCases.length,
              itemBuilder: (context, index) => Card(
                  key: ValueKey(urgentCases[index].title),
                  child: Column(children: [
                    ListTile(
                      title: Text(
                        urgentCases[index].title,
                      ),
                      subtitle: Text('\$'+f.format(urgentCases[index].goalAmount)),
                      trailing: Text(
                          DateFormat('yyyy-MM-dd').format((urgentCases[index].endDate.toDate()))),
                      onTap: () {
                        _goToChosenUrgentCase(
                            urgentCases[index].id);
                      },
                    ),
                    const Divider()
                  ])),
            )
                :  Text(
              //No results found
              'no_results_found'.tr,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}