import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/category_card.dart';
import 'package:donaid/Donor/DonorWidgets/organization_layout.dart';
import 'package:donaid/Donor/DonorWidgets/urgent_case_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonorDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';

  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;


  List<UrgentCase> urgentCases = [];
  List<OrganizationUser> organizations = [];
  List<CharityCategory> charityCategories = [];


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getUrgentCases();
    _getOrganizationUsers();
    _getCharityCategories();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getOrganizationUsers() async {
    var ret = await _firestore.collection('OrganizationUsers').get();
    ret.docs.forEach((doc) {
      OrganizationUser organizationUser = OrganizationUser(
        organizationName: doc.data()['organizationName'],
      );
      organizations.add(organizationUser);
    });
    setState(() {});
  }


  _getCharityCategories() async {
    var ret = await _firestore.collection('CharityCategories').get();
    ret.docs.forEach((doc) {
      CharityCategory charityCategory = CharityCategory(
        name: doc.data()['name'],
      );
      charityCategories.add(charityCategory);
    });
    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases').get();
    ret.docs.forEach((doc) {
      UrgentCase urgentCase = UrgentCase(
        name: doc.data()['title'],
        goal: doc.data()['goalAmount'],
        category: doc.data()['category'],
        description: doc.data()['description'],
        goalAmount: doc.data()['goalAmount'],
      );
      urgentCases.add(urgentCase);
    });
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: _drawer(),
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  _body() {
    return Container(
    decoration: BoxDecoration(
    color: Colors.blueGrey.shade50,
    borderRadius: BorderRadius.all(Radius.circular(10)),
    border: Border.all(color: Colors.grey.shade100)),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
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
                  return CharityCategoryCard(
                      charityCategories[index].name);
                },
              )),

          // organization list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Organizations',
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
              height: 150.0,
              child: ListView.builder(
                itemCount: organizations.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return OrganizationSection(
                      organizations[index].organizationName, "category");
                },
              )),

          // urgent case list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Urgent Cases',
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
              height: 325.0,
              child: ListView.builder(
                itemCount: urgentCases.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return UrgentCaseSection(urgentCases[index].name, urgentCases[index].description, urgentCases[index].goalAmount);
                },
              )),
        ],
      ),
    ));
  }

  _bottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.home, color: Colors.white, size: 35),
            ),
            Text('Home',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 35,
              ),
            ),
            Text('Search',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 35),
            ),
            Text('Notifications',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.message, color: Colors.white, size: 35),
            ),
            Text('Messages',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ],
      ),
    );
  }

  _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('DONAID',
                style: TextStyle(color: Colors.white, fontSize: 30)),
          ),
          ListTile(
            title: const Text('Favorites', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Edit Profile', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title:
                const Text('Donations History', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Log Out', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}


class UrgentCase {
  String name;
  int goal;
  String category;
  String description;
  int goalAmount;

  UrgentCase(
      {required this.name,
      required this.goal,
      required this.category,
      required this.description,
      required this.goalAmount});
}


class OrganizationUser {
  // TODO: add categories
  String organizationName;

  OrganizationUser({
    required this.organizationName,
  });
}

class CharityCategory {
  String name;

  CharityCategory({
    required this.name,
  });
}
