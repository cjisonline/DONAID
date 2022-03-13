import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_urgentcase_full.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

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
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getUrgentCases();
  }

  _refreshPage() async{
    urgentCases.clear();
    _getUrgentCases();
    setState(() {

    });
  }

  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
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


  _urgentCasesBody() {
    return RefreshIndicator(
      onRefresh: ()async{
        _refreshPage();
      },
      child: urgentCases.isNotEmpty
        ? ListView.builder(
          itemCount: urgentCases.length,
          shrinkWrap: true,
          itemBuilder: (context, int index) {
            return Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return (OrganizationUrgentCaseFullScreen(urgentCases[index]));
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
      :  Center(child: Text('no_active_campaigns_to_show'.tr, style: TextStyle(fontSize: 18),)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('my_urgent_cases'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const OrganizationDrawer(),
      body: _urgentCasesBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
