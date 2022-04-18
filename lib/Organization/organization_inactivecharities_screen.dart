import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Adoption.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_beneficiary_full.dart';
import 'package:donaid/Organization/organization_campaign_full.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'organization_adoption_full.dart';
import 'organization_urgentcase_full.dart';
import 'package:get/get.dart';


class InactiveCharitiesScreen extends StatefulWidget {
  const InactiveCharitiesScreen({Key? key}) : super(key: key);

  @override
  _InactiveCharitiesScreenState createState() => _InactiveCharitiesScreenState();
}

class _InactiveCharitiesScreenState extends State<InactiveCharitiesScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries=[];
  List<Campaign> campaigns=[];
  List<UrgentCase> urgentCases=[];
  List<Adoption> adoptions=[];
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getExpiredCampaigns();
    _getExpiredBeneficiaries();
    _getExpiredUrgentCases();
    _getExpiredAdoptions();
  }

  _refreshPage(){
    beneficiaries.clear();
    campaigns.clear();
    beneficiaries.clear();
    adoptions.clear();
    _getExpiredCampaigns();
    _getExpiredBeneficiaries();
    _getExpiredUrgentCases();
    _getExpiredAdoptions();
  }

  _getExpiredBeneficiaries() async {
    var ret = await _firestore.collection('Beneficiaries')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .where('active', isEqualTo: false)
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
        active: element.data()['active'],
      );
      beneficiaries.add(beneficiary);
    }

    setState(() {});
  }

  _getExpiredCampaigns()async{
    var ret = await _firestore.collection('Campaigns')
        .where('organizationID',isEqualTo: _auth.currentUser?.uid)
        .where('active', isEqualTo: false)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
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
        active: element.data()['active'],
      );
      campaigns.add(campaign);
    }
    setState(() {});
  }

  _getExpiredUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .where('active', isEqualTo: false)
        .where('approved',isEqualTo: true)
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
          rejected: element.data()['rejected'],
          approved: element.data()['approved']
      );
      urgentCases.add(urgentCase);
    }

    setState(() {});
  }

  // from Firebase, get adoptions where organization id is equal to the current organization
  // and where the active attribute is false
  _getExpiredAdoptions() async {
    try{
      var ret = await _firestore
          .collection('Adoptions')
          .where('organizationID', isEqualTo: _auth.currentUser?.uid)
          .where('active', isEqualTo: false)
          .get();

      for (var element in ret.docs) {
        Adoption adoption = Adoption(
          name: element.data()['name'],
          biography: element.data()['biography'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID'],
          active: element.data()['active'],
        );
        adoptions.add(adoption);
      }
    }
    catch(e){
      print(e);
    }

    setState(() {});
  }

  _beneficiariesBody(){
    return beneficiaries.isNotEmpty
    ? ListView.builder(
        itemCount: beneficiaries.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return OrganizationBeneficiaryFullScreen(beneficiaries[index]);
                    })).then((value) => _refreshPage());
                  },
                  title: Text(beneficiaries[index].name),
                  subtitle: Text(beneficiaries[index].biography),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$'+f.format(beneficiaries[index].amountRaised),
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black, fontSize: 15)),
                        Text(
                          '\$'+f.format(beneficiaries[index].goalAmount),
                          textAlign: TextAlign.start,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ]),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green),
                          value: (beneficiaries[index].amountRaised/beneficiaries[index].goalAmount),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider()
              ],
            ),
          );
        })
    :  Center(child: Text('no_inactive_beneficiaries_to_show.'.tr, style: TextStyle(fontSize: 18),));
  }

  _campaignsBody(){
    return campaigns.isNotEmpty
    ? ListView.builder(
        itemCount: campaigns.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return OrganizationCampaignFullScreen(campaigns[index]);
                    })).then((value) => _refreshPage());
                  },
                  title: Text(campaigns[index].title),
                  subtitle: Text(campaigns[index].description),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$'+f.format(campaigns[index].amountRaised),
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black, fontSize: 15)),
                        Text(
                          '\$'+f.format(campaigns[index].goalAmount),
                          textAlign: TextAlign.start,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ]),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green),
                          value: (campaigns[index].amountRaised/campaigns[index].goalAmount),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider()
              ],
            ),
          );
        })
        :  Center(child:  Text('no_inactive_campaigns_to_show.'.tr, style: TextStyle(fontSize: 18),));
  }

  _urgentCasesBody(){
    return urgentCases.isNotEmpty
    ? ListView.builder(
        itemCount: urgentCases.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return OrganizationUrgentCaseFullScreen(urgentCases[index]);
                    })).then((value) => _refreshPage());
                  },
                  title: Text(urgentCases[index].title),
                  subtitle: Text(urgentCases[index].description),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$'+f.format(urgentCases[index].amountRaised),
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black, fontSize: 15)),
                        Text(
                          '\$'+f.format(urgentCases[index].goalAmount),
                          textAlign: TextAlign.start,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ]),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green),
                          value: (urgentCases[index].amountRaised/urgentCases[index].goalAmount),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider()
              ],
            ),
          );
        })
    :  Center(child: Text('no_inactive_urgent_cases_to_show.'.tr, style: TextStyle(fontSize: 18),));
  }

  // Display the inactive adoptions in a list view
  _getAdoptionsBody(){
    return adoptions.isNotEmpty
        ? ListView.builder(
        itemCount: adoptions.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return (OrganizationAdoptionFullScreen(adoptions[index]));
                    })).then((value) => _refreshPage());
                  },
                  title: Text(adoptions[index].name),
                  subtitle: Text(adoptions[index].biography),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$'+f.format(adoptions[index].amountRaised),
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black, fontSize: 15)),
                        Text(
                          '\$'+f.format(adoptions[index].goalAmount),
                          textAlign: TextAlign.start,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ]),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green),
                          value: (adoptions[index].amountRaised/adoptions[index].goalAmount),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider()
              ],
            ),
          );
        })
        : Center(child: Text('no_inactive_adoptions_to_show'.tr, style: TextStyle(fontSize: 18),));
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom:  TabBar(tabs: [Tab(text: 'campaigns'.tr,), Tab(text: 'beneficiaries'.tr,), Tab(text: 'urgent_cases'.tr,), Tab(text: 'adoptions'.tr,)],),
          title:  Text('inactive_charities'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        drawer: const OrganizationDrawer(),
        body: TabBarView(
          children: [
            _campaignsBody(),
            _beneficiariesBody(),
            _urgentCasesBody(),
            _getAdoptionsBody(),
          ],
        ),
        bottomNavigationBar: const OrganizationBottomNavigation(),
      ),
    );
  }
}
