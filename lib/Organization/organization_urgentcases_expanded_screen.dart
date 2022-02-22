import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class OrganizationUrgentCasesExpandedScreen extends StatefulWidget {
  static const id = 'organization_urgentcases_expanded_screen';
  const OrganizationUrgentCasesExpandedScreen({Key? key})
      : super(key: key);

  @override
  _OrganizationUrgentCasesExpandedScreenState createState() =>
      _OrganizationUrgentCasesExpandedScreenState();
}

class _OrganizationUrgentCasesExpandedScreenState extends State<OrganizationUrgentCasesExpandedScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<UrgentCase> urgentCases = [];

  @override
  void initState() {
    super.initState();
    _getUrgentCases();
  }

  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .orderBy('endDate',descending: false)
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
          organizationID: element.data()['organizationID']);
      urgentCases.add(urgentCase);
    }
    setState(() {});
  }


  _beneficiariesBody() {
    return ListView.builder(
        itemCount: urgentCases.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    //TODO: implement on tap
                  },
                  title: Text(urgentCases[index].title),
                  subtitle: Text(urgentCases[index].description),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$${(urgentCases[index].amountRaised.toStringAsFixed(2))}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.black, fontSize: 15)),
                  Text(
                    '\$${urgentCases[index].goalAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ]),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                  value: (urgentCases[index].amountRaised/urgentCases[index].goalAmount),
                  minHeight: 10,
                ),
                const Divider()
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Urgent Cases'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const OrganizationDrawer(),
      body: _beneficiariesBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
