import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/campaign_card.dart';
import 'package:donaid/Organization/OrganizationWidget/urgent_case_card.dart';
import 'package:donaid/Organization/notifications_page.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/notifications.dart';
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
  final Future<SharedPreferences> _prefs =  SharedPreferences.getInstance();
  final _auth = FirebaseAuth.instance;
  final _messaging = FirebaseMessaging.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<Campaign> campaigns = [];
  List<UrgentCase> urgentCases = [];

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }
//initstate to initialize functions
  @override
  void initState() {
    super.initState();
    handleNotifications();
    _getCurrentUser();
    _getCampaign();
    _getUrgentCases();
    _getBeneficiaries();
    Get.find<ChatService>().getFriendsData(loggedInUser!.uid);
    Get.find<ChatService>().listenFriend(loggedInUser!.uid, 1);

  }

  handleNotifications()async{
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return OrganizationNotificationPage();
      }));

    });
    registerNotification();
    checkForInitialMessage();
  }

  checkForInitialMessage() async{
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      addNotification(_auth.currentUser?.uid, initialMessage);
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return OrganizationNotificationPage();
      }));
    }
  }

  registerNotification() async {
    NotificationSettings notificationSettings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true
    );

    if(notificationSettings.authorizationStatus == AuthorizationStatus.authorized)
    {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        addNotification(_auth.currentUser?.uid, message);

        if(message.notification!=null){
          showSimpleNotification(
            Text(message.notification!.title!),
            subtitle: Text(message.notification!.body!),
            duration: Duration(seconds: 5),
            slideDismissDirection: DismissDirection.up,

          );
        }
      });
    }
    else{
      print("Permission declined by user.");
    }
  }
  _refreshPage() async{
    beneficiaries.clear();
    campaigns.clear();
    urgentCases.clear();
    _getCampaign();
    _getBeneficiaries();
    _getUrgentCases();
  }
//Get campaigns from firebase
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

    campaigns.sort((b,a) => (a.dateCreated).compareTo((b.dateCreated)));
    setState(() {});
  }
// get urgent case from firebase
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
          rejected: element.data()['rejected'],
          approved: element.data()['approved']
      );
      urgentCases.add(urgentCase);
    }
    urgentCases.sort((b,a) => (a.dateCreated).compareTo((b.dateCreated)));
    setState(() {});
  }
// get beneficiary from firebase
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

    beneficiaries.sort((b,a) => (a.dateCreated).compareTo((b.dateCreated)));

    setState(() {});
  }
//Dashboard UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('dashboard'.tr),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          // Icon to add charities
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
      // Org UI Drawer
      drawer: const OrganizationDrawer(),
      // Body for Org dashboard
      body: _body(),
      //Bottom Nav bar
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
                      // Campaign display
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

            // Urgent case display
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

            // beneficiary list
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
