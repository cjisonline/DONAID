import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/Adoptee.dart';
import 'package:intl/intl.dart';

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
  Donor donor = Donor.c1();
  var f = NumberFormat("###,##0.00", "en_US");

  bool isAdopted = false;
  double monthlyAmount = 0;
  String donorID = "";
  String donorAdopteeID = "";
  List<Adoptee> adoptions = [];


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getDonorID().whenComplete( () =>
    _getAdoptions()
    );
  }

  _refreshPage() {
    adoptions.clear();
    _getCurrentUser();
    _getAdoptions();
    setState(() {

    });
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }
  _getDonorID() async {
    var ret = await _firestore
        .collection('DonorUsers')
        .where('uid', isEqualTo: loggedInUser?.uid)
        .get();
    final doc = ret.docs[0];
    donorID = doc['id'];
  }


  _getAdoptions() async {
    try{
      var ret = await _firestore
          .collection('Adoptions')
          .where('active',isEqualTo: true)
          .get();
      for (var element in ret.docs) {
        if(element.data()['donorMap'].containsKey(donorID)){
          print('in if');
          Adoptee adoptee = Adoptee(
            name: element.data()['name'],
            biography: element.data()['biography'],
            goalAmount: element.data()['goalAmount'].toDouble(),
            amountRaised: element.data()['amountRaised'].toDouble(),
            id: element.data()['id'],
            monthlyAmount: element.data()['donorMap'][donorID].toDouble()
          );
          adoptions.add(adoptee);
        }
      }
      print(adoptions);
      setState(() {});
    }
    catch(e){
      print(e);
    }

  }
  _body() {
    return RefreshIndicator(
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
                      // go to donate screen for adoptions
                      // Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //   return (OrganizationAdoptionFullScreen(adoptions[index]));
                      // })).then((value) => _refreshPage());
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
          : const Center(child: Text(
        'No active adoptions to show.', style: TextStyle(fontSize: 18),)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Adoptions'),
      ),
      drawer: const DonorDrawer(),
      body: _body(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}