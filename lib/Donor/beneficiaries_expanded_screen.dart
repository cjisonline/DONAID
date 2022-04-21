import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorAlertDialog/DonorAlertDialogs.dart';
import 'package:donaid/Donor/beneficiary_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../Models/Adoption.dart';
import '../Models/Subscription.dart';
import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'adoption_details_screen.dart';
import 'beneficiary_donate_screen.dart';
import 'package:get/get.dart';

class BeneficiaryExpandedScreen extends StatefulWidget {
  static const id = 'beneficaries_expanded_screen';
  const BeneficiaryExpandedScreen({Key? key}) : super(key: key);

  @override
  _BeneficiaryExpandedScreenState createState() =>
      _BeneficiaryExpandedScreenState();
}

class _BeneficiaryExpandedScreenState extends State<BeneficiaryExpandedScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Beneficiary> beneficiaries = [];
  List<Organization> organizations = [];
  var f = NumberFormat("###,##0.00", "en_US");
  List<Adoption> adoptions = [];
  List<Subscription> subscriptions = [];
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    _getBeneficiaries();
    _getAdoptions();
    _getCurrentlyAdopted();
  }

  _refreshPage() {
    beneficiaries.clear();
    subscriptions.clear();
    adoptions.clear();
    _getBeneficiaries();
    _getAdoptions();
    _getCurrentlyAdopted();
    setState(() {});
  }

  _getCurrentlyAdopted() async {
    /*This method gets the StripeSubscriptions record for the logged in donor user.
    * This is so that we can check if the adoption that we are viewing has already been adopted by the user*/
    var subscriptionsDoc = await _firestore
        .collection('StripeSubscriptions')
        .doc(_auth.currentUser?.uid)
        .get();
    for (var item in subscriptionsDoc['subscriptionList']) {
      Subscription subscription = Subscription(
        item['adoptionID'],
        item['subscriptionID'],
        item['monthlyAmount'],
      );
      subscriptions.add(subscription);
    }

    setState(() {});
  }

  _getBeneficiaries() async {
    //This method gets all beneficiaries from the database
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('active', isEqualTo: true)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
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
          active: element.data()['active']);
      beneficiaries.add(beneficiary);
    }
    setState(() {});
    _getBeneficiaryOrganizations();
  }

  _getAdoptions() async {
    //This method gets all adoptions from the database
    try {
      var ret = await _firestore
          .collection('Adoptions')
          .where('active', isEqualTo: true)
          .get();

      for (var element in ret.docs) {
        if (element.data()['amountRaised'].toDouble() <
            element.data()['goalAmount'].toDouble()) {
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
      }
    } catch (e) {
      print(e);
    }

    setState(() {});
  }

  _getBeneficiaryOrganizations() async {
    /*Gets the organizations that correspond to each beneficiary so that we can check if the
    * organization is based in the US or not when a user selects a beneficiary*/
    for (var beneficiary in beneficiaries) {
      var ret = await _firestore
          .collection('OrganizationUsers')
          .where('uid', isEqualTo: beneficiary.organizationID)
          .get();

      for (var element in ret.docs) {
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
        //If there are beneficiaries in the database, create a listview for those beneficiaries
        ? ListView.builder(
            itemCount: beneficiaries.length,
            shrinkWrap: true,
            itemBuilder: (context, int index) {
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        if (organizations[index].country == 'United States') {
                          //If the beneficiary is from a US organization, go to the full details page
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return (BeneficiaryDonateScreen(
                                beneficiaries[index]));
                          })).then((value) => _refreshPage());
                        } else {
                          //If the beneficiary is from a foreign organization, create the paymentLinkPopUp

                          //This charity object is used to create the gateway visit if the user clicks on the link
                          Map<String, dynamic> charity = {
                            'charityID': beneficiaries[index].id,
                            'charityType': 'Beneficiary',
                            'charityTitle': beneficiaries[index].name
                          };
                          DonorAlertDialogs.paymentLinkPopUp(
                              context,
                              organizations[index],
                              _auth.currentUser!.uid,
                              charity);
                        }
                      },
                      title: Text(beneficiaries[index].name),
                      subtitle: Text(beneficiaries[index].biography),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '\$' +
                                        f.format(
                                            beneficiaries[index].amountRaised),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15)),
                                Text(
                                  '\$' +
                                      f.format(beneficiaries[index].goalAmount),
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ]),
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                              value: (beneficiaries[index].amountRaised /
                                  beneficiaries[index].goalAmount),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10)
                  ],
                ),
              );
            })
        : //If there isn't any beneficiaries in the database, show an empty state indicator
        Center(
            child: Text(
            'no_active_beneficiaries_to_show'.tr,
            style: TextStyle(fontSize: 18),
          ));
  }

  _adoptionsBody() {
    /*This method builds the UI for the adoptions tab in the tab view*/
    return RefreshIndicator(
      onRefresh: () async {
        _refreshPage();
      },
      child: adoptions.isNotEmpty
          //If there are adoptions in the database, create a list view for them
          ? ListView.builder(
              itemCount: adoptions.length,
              shrinkWrap: true,
              itemBuilder: (context, int index) {
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return (AdoptionDetailsScreen(adoptions[index]));
                            })).then((value) => _refreshPage());
                          },
                          title: Text(adoptions[index].name),
                          subtitle: Text(adoptions[index].biography),

                          //Checks if the subscriptions array has an item where the adoption ID matches the index
                          //of the adoption in the adoptions list. Provide the appropriate icon accordingly.
                          trailing: subscriptions
                                  .where((item) =>
                                      item.adoptionID == adoptions[index].id)
                                  .toList()
                                  .isNotEmpty
                              ? Icon(
                                  Icons.handshake,
                                  color: Colors.blue,
                                )
                              : Icon(
                                  Icons.handshake_outlined,
                                  color: Colors.blue,
                                )),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '\$' +
                                          f.format(
                                              adoptions[index].amountRaised),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15)),
                                  Text(
                                    '\$' +
                                        f.format(adoptions[index].goalAmount),
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                ]),
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                                value: (adoptions[index].amountRaised /
                                    adoptions[index].goalAmount),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                );
              })
          : //If there are no adoptions in the database, give empty state indicator
          Center(
              child: Text(
              'no_active_adoptions_to_show'.tr,
              style: const TextStyle(fontSize: 18),
            )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_auth.currentUser?.email != null)
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(
                      text: 'beneficiaries'.tr,
                    ),
                    Tab(
                      text: 'adoptions'.tr,
                    )
                  ],
                ),
                title: Text('beneficiaries'.tr),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              drawer: const DonorDrawer(),
              body: TabBarView(
                children: [_beneficiariesBody(), _adoptionsBody()],
              ),
              bottomNavigationBar: DonorBottomNavigationBar(),
            ),
          )
        : Scaffold(
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
