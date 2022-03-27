import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'beneficiary_donate_screen.dart';
import 'campaign_donate_screen.dart';

class ResetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const DonorSearchScreen();
}

class DonorSearchScreen extends StatefulWidget {
  static const id = 'donor_search_screen';
  const DonorSearchScreen({Key? key}) : super(key: key);

  @override
  _DonorSearchScreenState createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;

  List<Beneficiary> beneficiaries = [];
  List<Beneficiary> allBeneficiaries = [];


  List<Campaign> campaigns = [];
  List<Campaign> allCampaigns = [];

  List<UrgentCase> urgentCases = [];
  List<UrgentCase> allUrgentCases = [];

  List<Organization> organizations = [];
  List<Organization> allOrganizations = [];
  List<String> organizationsID = [];
  List<String> allOrganizationsID=[];


  var campaignCategory = [];
  List<String> sortingChoices = [
    'Percent Raised - Ascending',
    'Percent Raised - Descending',
    'End Date - Soonest',
    'End Date - Latest'
  ];
  var f = NumberFormat("###,###.00#", "en_US");
  var searchFieldController = TextEditingController();
  var categoryFilterController = TextEditingController();
  var countryController=  TextEditingController();
  var sortingController = TextEditingController();

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  @override
  initState() {
    _getCurrentUser();
    _getCategories();
    _getOrganizationUsers();
    _getCampaign();
    _getUrgentCases();
    _getBeneficiaries();
    super.initState();
  }

  _getCategories() async {
    var ret = await _firestore.collection('CharityCategories').get();
    ret.docs.forEach((element) {
      campaignCategory.add(element.data()['name']);
    });

    setState(() {});
  }

  _getOrganizationUsers() async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('approved', isEqualTo: true)
        .get();
    for (var element in ret.docs) {
      Organization organization = Organization(
        organizationName: element.data()['organizationName'],
        uid: element.data()['uid'],
        id: element.data()['id'],
        organizationDescription: element.data()['organizationDescription'],
        country: element.data()['country'],
        gatewayLink: element.data()['gatewayLink'],
      );
      organizations.add(organization);
      allOrganizations.add(organization);
      organizationsID.add(element.data()['uid']);
      allOrganizationsID.add(element.data()['uid']);
    }
    setState(() {});
  }

  _getCampaign() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('active', isEqualTo: true)
        .get();

    for (var element in ret.docs) {
      Campaign campaign = Campaign(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID'],
          active: element.data()['active']);
      allCampaigns.add(campaign);
      campaigns.add(campaign);
    }
    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('approved', isEqualTo: true)
        .where('active', isEqualTo: true)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
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
          approved: element.data()['approved']);
      allUrgentCases.add(urgentCase);
      urgentCases.add(urgentCase);

    }
    setState(() {});
  }

  _getBeneficiaries() async {
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
      allBeneficiaries.add(beneficiary);
      beneficiaries.add(beneficiary);

    }
    setState(() {});
  }


  void _searchResults(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      campaigns = allCampaigns;
      beneficiaries = allBeneficiaries;
      urgentCases = allUrgentCases;
    } else {
      campaigns = campaigns
          .where((item) =>
          item.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      beneficiaries = beneficiaries
          .where((item) =>
          item.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      urgentCases = urgentCases
          .where((item) =>
              item.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
    });
  }

  void _categoryResult() {
    if(categoryFilterController.text.isNotEmpty){
      campaigns = campaigns
          .where((item) => item.category.contains(categoryFilterController.text))
          .toList();

      beneficiaries = beneficiaries
          .where((item) => item.category.contains(categoryFilterController.text))
          .toList();

      urgentCases = urgentCases
          .where((item) => item.category.contains(categoryFilterController.text))
          .toList();


      setState(() {
      });
    }
  }

  void _countryResult(){
    if(countryController.text.isNotEmpty){
      organizations = allOrganizations.where((item) => item.country!.contains(countryController.text)).toList();
      organizationsID.clear();
      for(var org in organizations){
        organizationsID.add(org.uid);
      }

      campaigns = campaigns
          .where((item) => organizationsID.contains(item.organizationID))
          .toList();

      beneficiaries = beneficiaries
          .where((item) => organizationsID.contains(item.organizationID))
          .toList();

      urgentCases = urgentCases
          .where((item) => organizationsID.contains(item.organizationID))
          .toList();

      setState(() {
      });
    }
  }

  void _sortResults(){
    if(sortingController.text.isNotEmpty){

      if(sortingController.text == 'Percent Raised - Ascending'){
        campaigns.sort((a, b) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        beneficiaries.sort((a, b) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        urgentCases.sort((a, b) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
    }
      else if(sortingController.text == 'Percent Raised - Descending'){
        campaigns.sort((b, a) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        beneficiaries.sort((b, a) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
        urgentCases.sort((b, a) => (a.amountRaised/a.goalAmount).compareTo((b.amountRaised/b.goalAmount)));
    }
      else if(sortingController.text ==  'End Date - Soonest'){
        campaigns.sort((a, b) => a.endDate.compareTo(b.endDate));
        beneficiaries.sort((a, b) => a.endDate.compareTo(b.endDate));
        urgentCases.sort((a, b) => a.endDate.compareTo(b.endDate));
    }
      else if(sortingController.text == 'End Date - Latest'){
        campaigns.sort((b, a) => a.endDate.compareTo(b.endDate));
        beneficiaries.sort((b, a) => a.endDate.compareTo(b.endDate));
        urgentCases.sort((b, a) => a.endDate.compareTo(b.endDate));
    }

      setState(() {
      });
    }
  }

  _filterResults(){
    campaigns = allCampaigns;
    beneficiaries = allBeneficiaries;
    urgentCases = allUrgentCases;
    _countryResult();
    _categoryResult();
  }

  _goToChosenCampaign(String id) async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('id', isEqualTo: id)
        .get();
    var doc = ret.docs[0];
    Campaign campaign = Campaign(
        title: doc.data()['title'],
        description: doc.data()['description'],
        goalAmount: doc.data()['goalAmount'].toDouble(),
        amountRaised: doc.data()['amountRaised'].toDouble(),
        category: doc.data()['category'],
        endDate: doc.data()['endDate'],
        dateCreated: doc.data()['dateCreated'],
        id: doc.data()['id'],
        organizationID: doc.data()['organizationID'],
        active: doc.data()['active']);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (CampaignDonateScreen(campaign));
    }));
  }

  _goToChosenBeneficiary(String id) async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('id', isEqualTo: id)
        .get();
    var doc = ret.docs[0];
    Beneficiary beneficiary = Beneficiary(
        name: doc.data()['name'],
        biography: doc.data()['biography'],
        goalAmount: doc.data()['goalAmount'].toDouble(),
        amountRaised: doc.data()['amountRaised'].toDouble(),
        category: doc.data()['category'],
        endDate: doc.data()['endDate'],
        dateCreated: doc.data()['dateCreated'],
        id: doc.data()['id'],
        organizationID: doc.data()['organizationID'],
        active: doc.data()['active']);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (BeneficiaryDonateScreen(beneficiary));
    }));
  }

  _goToChosenUrgentCase(String id) async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('id', isEqualTo: id)
        .get();
    var doc = ret.docs[0];
    UrgentCase urgentCase = UrgentCase(
        title: doc.data()['title'],
        description: doc.data()['description'],
        goalAmount: doc.data()['goalAmount'].toDouble(),
        amountRaised: doc.data()['amountRaised'].toDouble(),
        category: doc.data()['category'],
        endDate: doc.data()['endDate'],
        dateCreated: doc.data()['dateCreated'],
        id: doc.data()['id'],
        organizationID: doc.data()['organizationID'],
        active: doc.data()['active'],
        approved: doc.data()['approved']);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (UrgentCaseDonateScreen(urgentCase));
    }));
  }

  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => ResetWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title:  Text('search'.tr),
            bottom: TabBar(tabs: [Tab(text: 'campaigns'.tr), Tab(text: 'beneficiaries'.tr), Tab(text: 'urgent_cases'.tr)],),
            actions: <Widget>[
              TextButton(
                  onPressed: _reset,
                  child:
                      Text('reset'.tr, style: const TextStyle(color: Colors.white))),
            ],
          ),
          drawer: const DonorDrawer(),
          body: TabBarView(
            children: [
              _buildCampaignsBody(),
              _buildBeneficiariesBody(),
              _buildUrgentCasesBody()
            ],
          ),
          bottomNavigationBar: DonorBottomNavigationBar()),
    );
  }

  _buildCampaignsBody(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            onChanged: (val) {
              _searchResults(val.toString());
            },
            controller: searchFieldController,
            decoration: const InputDecoration(
              labelText: 'Search',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        label: Center(
                          child: Text('category'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: const Icon(Icons.keyboard_arrow_down)),
                    items: campaignCategory.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      categoryFilterController.text = val.toString();
                      _filterResults();
                    }),
                  )),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: countryController,
                  decoration: InputDecoration(
                      label: Center(
                        child: Text('Country'.tr),),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12.0)),
                      )),
                  readOnly: true,
                  onTap: (){
                    showCountryPicker(
                        context: context,
                        onSelect: (Country selectedCountry) {
                          countryController.text = selectedCountry.name;
                          _filterResults();
                        });

                  },
                ),
              ),

            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        label: Center(
                          child: Text('Sort By'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: Icon(Icons.keyboard_arrow_down)),
                    items: sortingChoices.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      sortingController.text = val.toString();
                      _sortResults();
                    }),
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: campaigns.isNotEmpty
                ? ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                  return Card(
                      key: ValueKey(campaigns[index].title),
                      child: Column(children: [
                        ListTile(
                          title: Text(
                            campaigns[index].title.toString(),
                          ),
                          subtitle: Text('\$' +
                              f.format(campaigns[index].goalAmount)),
                          trailing: Text(DateFormat('yyyy-MM-dd')
                              .format((campaigns[index].endDate
                              .toDate()))),
                          onTap: () {
                              _goToChosenCampaign(
                                  campaigns[index].id);
                              setState(() {
                              });
                          }
                        ),
                      ]));
                }
            )
                :  Text(
              'no_results_found'.tr,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  _buildBeneficiariesBody(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            onChanged: (val) {
              _searchResults(val.toString());
            },
            controller: searchFieldController,
            decoration: const InputDecoration(
              labelText: 'Search',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        label: Center(
                          child: Text('category'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: const Icon(Icons.keyboard_arrow_down)),
                    items: campaignCategory.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      categoryFilterController.text = val.toString();
                      _filterResults();
                    }),
                  )),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: countryController,
                  decoration: InputDecoration(
                      label: Center(
                        child: Text('Country'.tr)),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12.0)),
                      )),
                  readOnly: true,
                  onTap: (){
                    showCountryPicker(
                        context: context,
                        onSelect: (Country selectedCountry) {
                          countryController.text = selectedCountry.name;
                          _filterResults();
                        });

                  },
                ),
              ),

            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        label: Center(
                          child: Text('Sort By'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: Icon(Icons.keyboard_arrow_down)),
                    items: sortingChoices.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      sortingController.text = val.toString();
                      _sortResults();
                    }),
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: beneficiaries.isNotEmpty
                ? ListView.builder(
                itemCount: beneficiaries.length,
                itemBuilder: (context, index) {
                  return Card(
                      key: ValueKey(beneficiaries[index].name),
                      child: Column(children: [
                        ListTile(
                            title: Text(
                              beneficiaries[index].name.toString(),
                            ),
                            subtitle: Text('\$' +
                                f.format(beneficiaries[index].goalAmount)),
                            trailing: Text(DateFormat('yyyy-MM-dd')
                                .format((beneficiaries[index].endDate
                                .toDate()))),
                            onTap: () {
                                _goToChosenBeneficiary(
                                    beneficiaries[index].id);
                                setState(() {
                                });
                            }
                        ),
                      ]));
                }
            )
                :  Text(
              'no_results_found'.tr,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  _buildUrgentCasesBody(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            onChanged: (val) {
              _searchResults(val.toString());
            },
            controller: searchFieldController,
            decoration: const InputDecoration(
              labelText: 'Search',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        label: Center(
                          child: Text('category'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: const Icon(Icons.keyboard_arrow_down)),
                    items: campaignCategory.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      categoryFilterController.text = val.toString();
                      _filterResults();
                    }),
                  )),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  controller: countryController,
                  decoration: InputDecoration(
                      label: Center(
                        child: Text('Country'.tr),),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12.0)),
                      )),
                  readOnly: true,
                  onTap: (){
                    showCountryPicker(
                        context: context,
                        onSelect: (Country selectedCountry) {
                          countryController.text = selectedCountry.name;
                          _filterResults();
                        });

                  },
                ),
              ),

            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        label: Center(
                          child: Text('Sort By'.tr)
                        ),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Visibility(visible: false,child: Icon(Icons.keyboard_arrow_down)),
                    items: sortingChoices.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      sortingController.text = val.toString();
                      _sortResults();
                    }),
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: urgentCases.isNotEmpty
                ? ListView.builder(
                itemCount: urgentCases.length,
                itemBuilder: (context, index) {
                  return Card(
                      key: ValueKey(urgentCases[index].title),
                      child: Column(children: [
                        ListTile(
                            title: Text(
                              urgentCases[index].title.toString(),
                            ),
                            subtitle: Text('\$' +
                                f.format(urgentCases[index].goalAmount)),
                            trailing: Text(DateFormat('yyyy-MM-dd')
                                .format((urgentCases[index].endDate
                                .toDate()))),
                            onTap: () {
                                _goToChosenUrgentCase(
                                    urgentCases[index].id);
                                setState(() {
                                });

                            }
                        ),
                      ]));
                }
            )
                :  Text(
              'no_results_found'.tr,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
