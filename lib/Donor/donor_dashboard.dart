import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Chat/conversation.dart';
import 'package:donaid/Donor/DonorWidgets/category_card.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Donor/DonorWidgets/organization_card.dart';
import 'package:donaid/Donor/DonorWidgets/urgent_case_card.dart';
import 'package:donaid/Models/CharityCategory.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DonorDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';

  DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  int currentIndex = 0;

  List<UrgentCase> urgentCases = [];
  List<Organization> organizations = [];
  List<CharityCategory> charityCategories = [];
  updateIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getUrgentCases();
    _getOrganizationUsers();
    _getCharityCategories();
    Get.find<ChatService>().getFriendsData(loggedInUser!.uid);
    Get.find<ChatService>().listenFriend(loggedInUser!.uid, 0);
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getOrganizationUsers() async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('approved', isEqualTo: true)
        .get();
    ret.docs.forEach((element) {
      Organization organization = Organization(
          organizationName: element.data()['organizationName'],
          uid: element.data()['uid']);
      organizations.add(organization);
    });
    setState(() {});
  }

  _getCharityCategories() async {
    var ret = await _firestore.collection('CharityCategories').get();
    ret.docs.forEach((element) {
      CharityCategory charityCategory = CharityCategory(
          name: element.data()['name'], id: element.data()['id']);
      charityCategories.add(charityCategory);
    });
    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases').get();
    ret.docs.forEach((element) {
      UrgentCase urgentCase = UrgentCase(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']);
      urgentCases.add(urgentCase);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: currentIndex == 3 ? false : true,
                    title: Text(currentIndex == 3 ? 'Messages' : 'Dashboard'),
                    actions: <Widget>[
                      if (currentIndex == 3)
                        IconButton(
                            icon: Icon(Icons.add, size: 30),
                            onPressed: () {
                              Get.to(ConversationScreen(loggedInUser!.uid,
                                  "OrganizationUsers", organizations));
                            })
                    ]),
                drawer: currentIndex == 3 ? null : DonorDrawer(),
                body: currentIndex == 0
                    ? home()
                    : currentIndex == 1
                        ? search()
                        : currentIndex == 2
                            ? notification()
                            : messages(),
                bottomNavigationBar:
                    _bottomNavigationBar(context, updateIndex))));
  }

  search() {
    return Container(child: Center(child: Text("Search")));
  }

  notification() {
    return Container(child: Center(child: Text("notification")));
  }

  messages() {
    return Conversation(loggedInUser!.uid, "OrganizationUsers");
  }

  home() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.grey.shade100)),
        child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'See more >',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
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
                    return CharityCategoryCard(charityCategories[index].name);
                  })),

          // organization list
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Organizations',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.start),
                        Text('See more >',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.start)
                      ]))),
          SizedBox(
              height: 150.0,
              child: ListView.builder(
                  itemCount: organizations.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    return InkWell(
                        onTap: () {},
                        child: OrganizationCard(
                            organizations[index].organizationName));
                  })),

          // urgent case list
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Urgent Cases',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.start),
                        Text('See more >',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.start)
                      ]))),

          SizedBox(
              height: 325.0,
              child: ListView.builder(
                  itemCount: urgentCases.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, int index) {
                    return UrgentCaseCard(
                        urgentCases[index].title,
                        urgentCases[index].description,
                        urgentCases[index].goalAmount,
                        urgentCases[index].amountRaised);
                  }))
        ])));
  }
}

_bottomNavigationBar(context, onpress) {
  return Container(
      height: 70,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              enableFeedback: false,
              onPressed: () => onpress(0),
              icon: Icon(Icons.home, color: Colors.white, size: 35)),
          Text('Home',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10)),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              enableFeedback: false,
              onPressed: () => onpress(1),
              icon: Icon(Icons.search, color: Colors.white, size: 35)),
          Text('Search',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10))
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              enableFeedback: false,
              onPressed: () => onpress(2),
              icon: Icon(Icons.notifications, color: Colors.white, size: 35)),
          Text('Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10))
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              enableFeedback: false,
              onPressed: () => onpress(3),
              icon: Icon(Icons.message, color: Colors.white, size: 35)),
          Text('Messages',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 10))
        ])
      ]));
}
