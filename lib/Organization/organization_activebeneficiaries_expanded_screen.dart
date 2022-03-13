import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'organization_beneficiary_full.dart';

class OrganizationBeneficiariesExpandedScreen extends StatefulWidget {
  static const id = 'organization_beneficaries_expanded_screen';
  const OrganizationBeneficiariesExpandedScreen({Key? key}) : super(key: key);

  @override
  _OrganizationBeneficiariesExpandedScreenState createState() =>
      _OrganizationBeneficiariesExpandedScreenState();
}

class _OrganizationBeneficiariesExpandedScreenState extends State<OrganizationBeneficiariesExpandedScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getBeneficiaries();
  }

  _refreshPage() async{
    beneficiaries.clear();
    _getBeneficiaries();
    setState(() {

    });
  }
  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
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
      );
      beneficiaries.add(beneficiary);
    }
    setState(() {});
  }

  _beneficiariesBody() {
    return RefreshIndicator(
      onRefresh: ()async{
        _refreshPage();
      },
      child: beneficiaries.isNotEmpty
        ? ListView.builder(
          itemCount: beneficiaries.length,
          shrinkWrap: true,
          itemBuilder: (context, int index) {
            return Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return (OrganizationBeneficiaryFullScreen(beneficiaries[index]));
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
      :  Center(child: Text('no_active_beneficiaries_to_show'.tr, style: TextStyle(fontSize: 18),)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('my_beneficiaries'.tr),
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
