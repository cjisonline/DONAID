import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/campaign_card.dart';
import 'package:donaid/Organization/OrganizationWidget/urgent_case_card.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'OrganizationWidget/beneficiary_card.dart';
import 'OrganizationWidget/organization_bottom_navigation.dart';
import 'OrganizationWidget/organization_drawer.dart';
import 'add_selection_screen.dart';
import 'organization_activebeneficiaries_expanded_screen.dart';
import 'organization_activecampaigns_expanded_screen.dart';
import 'organization_activeurgentcases_expanded_screen.dart';

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
    Get.find<ChatService>().getFriendsData(loggedInUser!.uid);
    Get.find<ChatService>().listenFriend(loggedInUser!.uid, 1);
    subscribe();

  }
  subscribe()async{
    await FirebaseMessaging.instance.subscribeToTopic(_auth.currentUser!.uid.toString()).whenComplete(() => print('Subscribed to topic: ${_auth.currentUser!.uid.toString()}'));
  }

  _refreshPage() async{
    beneficiaries.clear();
    campaigns.clear();
    urgentCases.clear();
    _getCampaign();
    _getBeneficiaries();
    _getUrgentCases();
  }

  _getCampaign() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .where('active', isEqualTo: true)
        .orderBy('endDate', descending: false)
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

  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .where('active', isEqualTo: true)
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
          approved: element.data()['approved']
      );
      urgentCases.add(urgentCase);
    }

    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .where('active', isEqualTo: true)
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
          active: element.data()['active'],
      ); // need to add category
      beneficiaries.add(beneficiary);
    }

    print('Beneficiaries list: $beneficiaries');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('dashboard'.tr),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () {
                Navigator.push (context, MaterialPageRoute(builder: (context) => const OrgAddSelection()),).then((value){
                  _refreshPage();
                });
              }),
        ],
      ),
      drawer: const OrganizationDrawer(),
      body: _body(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }

  _body() {
    return RefreshIndicator(
      onRefresh: ()async{
        _refreshPage();
      },
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
                       Text(
                        '_campaign'.tr,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.push (context, MaterialPageRoute(builder: (context) => const OrganizationCampaignsExpandedScreen()),).then((value){
                            _refreshPage();
                          });
                        },
                        child:  Text(
                          'see_more'.tr,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ]),
              ),
            ),
            campaigns.isNotEmpty
            ? SizedBox(
                height: 325.0,
                child: ListView.builder(
                  itemCount: campaigns.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    return CampaignCard(campaigns[index]);
                  },
                ))
            :  Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('no_active_campaigns_to_show'.tr, style: TextStyle(fontSize: 18),),
            ),

            // organization list
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        '_urgent_cases'.tr,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.push (context, MaterialPageRoute(builder: (context) => const OrganizationUrgentCasesExpandedScreen()),).then((value){
                            _refreshPage();
                          });
                        },
                        child:  Text(
                          'see_more'.tr,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ]),
              ),
            ),
            urgentCases.isNotEmpty
            ? SizedBox(
                height: 325.0,
                child: ListView.builder(
                  itemCount: urgentCases.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    return UrgentCaseCard(urgentCases[index]);
                  },
                )
            )
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('no_active_urgent_sases_show'.tr, style: TextStyle(fontSize: 18),),
            ),

            // urgent case list
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        '_beneficiary'.tr,
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.push (context, MaterialPageRoute(builder: (context) => const OrganizationBeneficiariesExpandedScreen()),).then((value){
                            _refreshPage();
                          });
                        },
                        child:  Text(
                          'see_more'.tr,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ]),
              ),
            ),
            beneficiaries.isNotEmpty
            ? SizedBox(
                height: 325.0,
                child: ListView.builder(
                  itemCount: beneficiaries.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    return BeneficiaryCard(beneficiaries[index]);
                  },
                ))
            :  Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('no_active_beneficiaries_to_show'.tr, style:  TextStyle(fontSize: 18),),
            ),
          ],
        ),
      ),
    );
  }
}
