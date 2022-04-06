import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:donaid/Models/Subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../Models/Adoption.dart';
import 'adoption_details_screen.dart';

class MyAdoptions extends StatefulWidget {
  static const id = 'my_adoptions';

  const MyAdoptions({Key? key}) : super(key: key);

  @override
  _MyAdoptionsState createState() => _MyAdoptionsState();
}

class _MyAdoptionsState extends State<MyAdoptions> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  var f = NumberFormat("###,##0.00", "en_US");

  bool showLoadingSpinner = false;
  List<Adoption> adoptions = [];
  List<Subscription> subscriptions=[];


  @override
  void initState() {
    super.initState();
    _getSubscriptionsAndAdoptions();
  }

  _refreshPage() {
    adoptions.clear();
    subscriptions.clear();
    _getSubscriptionsAndAdoptions();
    setState(() {

    });
  }


  _getSubscriptionsAndAdoptions() async {
    setState(() {
      showLoadingSpinner = true;
    });
    var stripeSubscriptionsDoc = await _firestore.collection('StripeSubscriptions').doc(_auth.currentUser?.uid).get();

    for(var item in stripeSubscriptionsDoc['subscriptionList']){
      Subscription subscription = Subscription(
          item['adoptionID'],
          item['subscriptionID'],
        item['monthlyAmount'],
      );

      subscriptions.add(subscription);
    }

    //reverse to order by most recently subscribed to
    subscriptions = subscriptions.reversed.toList();

    for(var subscription in subscriptions){
      var adoptionDoc = await _firestore.collection('Adoptions').doc(subscription.adoptionID).get();

      Adoption adoption = Adoption(
        active: adoptionDoc['active'],
        amountRaised: adoptionDoc['amountRaised'],
        biography: adoptionDoc['biography'],
        goalAmount: adoptionDoc['goalAmount'],
        category: adoptionDoc['category'],
        dateCreated: adoptionDoc['dateCreated'],
        name: adoptionDoc['name'],
        organizationID: adoptionDoc['organizationID'],
        id: adoptionDoc['id']
      );

      adoptions.add(adoption);
    }


    setState(() {
      showLoadingSpinner = false;
    });


  }
  _body() {
    return ModalProgressHUD(
      inAsyncCall: showLoadingSpinner,
      child: RefreshIndicator(
        onRefresh: () async {
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return (AdoptionDetailsScreen(adoptions[index]));
                        })).then((value) => _refreshPage());
                      },
                      title: Text(adoptions[index].name),
                      subtitle: Text(adoptions[index].biography),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('\$' +
                                    f.format(adoptions[index].amountRaised),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15)),
                                Text(
                                  '\$' + f.format(adoptions[index].goalAmount),
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ]),
                          ClipRRect(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)),
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
                    const Divider()
                  ],
                ),
              );
            })
            :  Center(child: Text(
          'no_active_adoptions_to_show'.tr, style: TextStyle(fontSize: 18),)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_adoptions'.tr),
      ),
      drawer: const DonorDrawer(),
      body: _body(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
