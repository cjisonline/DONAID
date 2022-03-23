import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorAlertDialog/DonorAlertDialogs.dart';
import 'package:donaid/Donor/beneficiary_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'beneficiary_donate_screen.dart';
import 'package:get/get.dart';

class BeneficiaryExpandedScreen extends StatefulWidget {
  static const id = 'beneficaries_expanded_screen';
  const BeneficiaryExpandedScreen({Key? key})
      : super(key: key);

  @override
  _BeneficiaryExpandedScreenState createState() =>
      _BeneficiaryExpandedScreenState();
}

class _BeneficiaryExpandedScreenState extends State<BeneficiaryExpandedScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<Organization> organizations=[];
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getBeneficiaries();
  }
  
  _refreshPage(){
    beneficiaries.clear();
    _getBeneficiaries();
    setState(() {
      
    });
  }

  _getBeneficiaries() async {
    var ret = await _firestore.collection('Beneficiaries')
        .where('active', isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
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
          active: element.data()['active']
      );
      beneficiaries.add(beneficiary);
    }
    setState(() {});
    _getBeneficiaryOrganizations();
  }

  _getBeneficiaryOrganizations() async{
    for(var beneficiary in beneficiaries){
      var ret = await _firestore.collection('OrganizationUsers')
          .where('uid', isEqualTo: beneficiary.organizationID)
          .get();

      for(var element in ret.docs){
        Organization organization = Organization(
          organizationName: element.data()['organizationName'],
          uid: element.data()['uid'],
          organizationDescription: element.data()['organizationDescription'],
          country: element.data()['country'],
          gatewayLink: element.data()['gatewayLink'],
        );
        organizations.add(organization);
      }
    }
  }

  _beneficiariesBody() {
    return beneficiaries.isNotEmpty
    ? ListView.builder(
        itemCount: beneficiaries.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    if(organizations[index].country =='United States'){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return (BeneficiaryDonateScreen(beneficiaries[index]));
                      })).then((value) => _refreshPage());
                    }
                    else{
                      Map<String, dynamic> charity = {
                        'charityID':beneficiaries[index].id,
                        'charityType':'Beneficiary',
                        'charityTitle':beneficiaries[index].name
                      };
                      DonorAlertDialogs.paymentLinkPopUp(context, organizations[index], _auth.currentUser!.uid, charity);
                    }
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
    :  Center(child: Text('no_active_beneficiaries_to_show'.tr, style: TextStyle(fontSize: 18),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('beneficiaries'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _beneficiariesBody(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
