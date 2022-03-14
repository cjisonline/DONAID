import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Adoption.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<Adoption> adoptions = [];
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getBeneficiaries();
    _getAdoptions();
  }

  _refreshPage() async{
    beneficiaries.clear();
    adoptions.clear();
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

  _getAdoptions() async {
    try{
      var ret = await _firestore
          .collection('Adoptions')
          .where('organizationID', isEqualTo: _auth.currentUser?.uid)
          .where('active', isEqualTo: true)
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
      print(adoptions);
    }
    catch(e){
      print(e);
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
      : const Center(child: Text('No active beneficiaries to show.', style: TextStyle(fontSize: 18),)),
    );
  }

  _adoptionsBody() {
    return RefreshIndicator(
      onRefresh: ()async{
        _refreshPage();
      },
      child: adoptions.isNotEmpty
          ? ListView.builder(
          itemCount: adoptions.length,
          shrinkWrap: true,
          itemBuilder: (context, int index) {
            return Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //   return (OrganizationBeneficiaryFullScreen(adoptions[index]));
                      //
                      // })).then((value) => _refreshPage());

                    },
                    title: Text(adoptions[index].name),
                    subtitle: Text(adoptions[index].biography),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
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
          : const Center(child: Text('No active adoptions to show.', style: TextStyle(fontSize: 18),)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(tabs: [Tab(text: 'Beneficiaries',), Tab(text: 'Adoptions',)],),
          title: const Text('My Beneficiaries'),
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
            _beneficiariesBody(),
            _adoptionsBody()
          ],
        ),
        bottomNavigationBar:   const OrganizationBottomNavigation(),
      ),
    );
  }
}
