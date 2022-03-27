import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'OrganizationWidget/organization_bottom_navigation.dart';
import 'OrganizationWidget/organization_drawer.dart';
import 'organization_urgentcase_full.dart';
import 'package:get/get.dart';


class PendingApprovalsAndDenials extends StatefulWidget {
  const PendingApprovalsAndDenials({Key? key}) : super(key: key);

  @override
  _PendingApprovalsAndDenialsState createState() => _PendingApprovalsAndDenialsState();
}

class _PendingApprovalsAndDenialsState extends State<PendingApprovalsAndDenials> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<UrgentCase> pendingUrgentCases = [];
  List<UrgentCase> deniedUrgentCases = [];
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getPendingUrgentCases();
    _getDeniedUrgentCases();
  }

  _refreshPage() async{
    pendingUrgentCases.clear();
    deniedUrgentCases.clear();
    _getPendingUrgentCases();
    _getDeniedUrgentCases();
    setState(() {

    });
  }

  _getPendingUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .where('active', isEqualTo: true)
        .where('approved',isEqualTo: false)
        .where('rejected',isEqualTo: false)
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
      pendingUrgentCases.add(urgentCase);
    }
    setState(() {});
  }

  _getDeniedUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .where('active', isEqualTo: true)
        .where('approved',isEqualTo: false)
        .where('rejected',isEqualTo: true)
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
          approved: element.data()['approved'],
        denialReason: element.data()['denialReason']
      );
      deniedUrgentCases.add(urgentCase);
    }
    setState(() {});
  }


  _pendingBody() {
    return pendingUrgentCases.isNotEmpty
    ? ListView.builder(
        itemCount: pendingUrgentCases.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return (OrganizationUrgentCaseFullScreen(pendingUrgentCases[index]));
                    })).then((value) => _refreshPage());
                  },
                  title: Text(pendingUrgentCases[index].title),
                  subtitle: Text(pendingUrgentCases[index].description),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$'+f.format(pendingUrgentCases[index].amountRaised),
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black, fontSize: 15)),
                        Text(
                          '\$'+f.format(pendingUrgentCases[index].goalAmount),
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
                          value: (pendingUrgentCases[index].amountRaised/pendingUrgentCases[index].goalAmount),
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
        :  Center(child: Text('no_pending_urgent_cases_to_show.'.tr, style: TextStyle(fontSize: 18),));
  }

  _denialsBody() {
    return deniedUrgentCases.isNotEmpty
        ? ListView.builder(
        itemCount: deniedUrgentCases.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return (OrganizationUrgentCaseFullScreen(deniedUrgentCases[index]));
                    })).then((value) => _refreshPage());
                  },
                  title: Text(deniedUrgentCases[index].title),
                  subtitle: Text(deniedUrgentCases[index].description),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$'+f.format(deniedUrgentCases[index].amountRaised),
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black, fontSize: 15)),
                        Text(
                          '\$'+f.format(deniedUrgentCases[index].goalAmount),
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
                          value: (deniedUrgentCases[index].amountRaised/deniedUrgentCases[index].goalAmount),
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
        :  Center(child: Text('no_denied_urgent_cases_to_show.'.tr, style: TextStyle(fontSize: 18),));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(tabs: [Tab(text: '_pending_approvals'.tr), Tab(text: 'Denials')]),
          title:  Text('pending_approvals'.tr),
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
            _pendingBody(),
            _denialsBody()
          ],
        ),
        bottomNavigationBar: const OrganizationBottomNavigation(),
      ),
    );
  }
}
