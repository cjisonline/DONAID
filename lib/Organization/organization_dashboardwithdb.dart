import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Author: Raisa Zaman
///Main is here for testing purposes

class OrganizationDashboard extends StatefulWidget {
  static const id = 'organization_dashboard';
  const OrganizationDashboard({Key? key}) : super(key: key);

  @override
  _OrganizationDashboardState createState() => _OrganizationDashboardState();
}

final FirebaseAuth auth = FirebaseAuth.instance;


class _OrganizationDashboardState extends State<OrganizationDashboard> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  var _fireStore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<Campaign> campaigns = [];
  List<Urgent> urgents = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getBeneficiaries();
    _getCampaign();
    _getUrgent();
  }


  void _getCurrentUser(){
    loggedInUser = _auth.currentUser;
  }


 

  _beneficiaryBody() {
    return ListView.builder(
      itemCount: beneficiaries.length,
      shrinkWrap: true,
      itemBuilder: (context, int index) {
        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 3,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text('Name: ${beneficiaries[index].name}'),
                SizedBox(height: 8),
                Text('Goal: ${beneficiaries[index].goal}'),
                SizedBox(height: 8),
                Text('Category: ${beneficiaries[index].category}'),
              ],
            ),
          ),
        );
      },
    );
  }

  _urgentBody() {
    return ListView.builder(
      itemCount: urgents.length,
      shrinkWrap: true,
      itemBuilder: (context, int index) {
        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 3,
          child: ListTile(
            title: Text(urgents[index].name),
            subtitle: Text(urgents[index].category),
            trailing: Text(urgents[index].goal.toString()),
          ),
        );
      },
    );
  }

  _campaignBody() {
    return ListView.builder(
      itemCount: campaigns.length,
      shrinkWrap: true,
      itemBuilder: (context, int index) {
        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 3,
          child: ListTile(
            title: Text(campaigns[index].name),
            subtitle: Text(campaigns[index].category),
            trailing: Text(campaigns[index].goal.toString()),
          ),
        );
      },
    );
  }

//Need a field
  _getUrgent() async {
    var ret = await _fireStore.collection('').get();
    ret.docs.forEach((element) {
      Urgent urgent = Urgent(
          name: element.data()['name'],
          goal: element.data()['goal'],
          category: element.data()['category']);
      urgents.add(urgent);
    });

    setState(() {});
  }

  _getCampaign() async {
    var ret = await _fireStore.collection('Campaigns').get();
    ret.docs.forEach((element) {
      Campaign campaign = Campaign(
          name: element.data()['title'],
          goal: element.data()['goal'],
          category: element.data()['category']);
      campaigns.add(campaign);
    });

    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _fireStore.collection('Beneficiaries').get();
    ret.docs.forEach((element) {
      Beneficiary beneficiary = Beneficiary(
          name: element.data()['name'],
          goal: element.data()['goalAmount'],
          category: element.data()['category']); // need to add category
      beneficiaries.add(beneficiary);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DONAID'),
      ),
      body: TabBarView(
        children: [
          _beneficiaryBody(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phonelink_ring_rounded),
            label: 'notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'messages',
          ),
        ],
      ),
    );
  }


}




class Campaign {
  String name;
  int goal;
  String category;

  Campaign(
      {
        required this.name,
        required this.goal,
        required this.category,
      });
}

class Urgent {
  String name;
  int goal;
  String category;

  Urgent(
      {
        required this.name,
        required this.goal,
        required this.category,});
}

class Beneficiary {
  String name;
  int goal;
  String category;

  Beneficiary({
    required this.name,
    required this.goal,
    required this.category,
  });
}


