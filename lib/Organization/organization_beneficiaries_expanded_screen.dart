import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_beneficiary_full.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class OrganizationBeneficiariesExpandedScreen extends StatefulWidget {
  static const id = 'organization_beneficaries_expanded_screen';
  const OrganizationBeneficiariesExpandedScreen({Key? key})
      : super(key: key);

  @override
  _OrganizationBeneficiariesExpandedScreenState createState() =>
      _OrganizationBeneficiariesExpandedScreenState();
}

class _OrganizationBeneficiariesExpandedScreenState extends State<OrganizationBeneficiariesExpandedScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];

  @override
  void initState() {
    super.initState();
    _getBeneficiaries();
  }

  _getBeneficiaries() async {
    var ret = await _firestore.collection('Beneficiaries')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .orderBy('endDate',descending: false)
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
    return ListView.builder(
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
                    }));
                  },
                  title: Text(beneficiaries[index].name),
                  subtitle: Text(beneficiaries[index].biography),
                  trailing: beneficiaries[index].active
                      ? IconButton(
                    icon: const Icon(
                      Icons.stop,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      //TODO: end charity button
                    },
                  )
                      : IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.green,
                    ),
                    onPressed: (){
                      //TODO: resume charity button
                    },
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$${(beneficiaries[index].amountRaised.toStringAsFixed(2))}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.black, fontSize: 15)),
                  Text(
                    '\$${beneficiaries[index].goalAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ]),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                  value: (beneficiaries[index].amountRaised/beneficiaries[index].goalAmount),
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
        title: const Text('My Beneficiaries'),
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
