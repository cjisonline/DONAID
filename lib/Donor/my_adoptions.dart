import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/Adoptee.dart';
import '../Models/Adoption.dart';
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
  List<Adoptee> adoptions = [];
  var f = NumberFormat("###,##0.00", "en_US");

  bool isAdopted = false;
  double monthlyAmount = 0;
  String donorID = "";
  String donorAdopteeID = "";
  List<String> adopteeIDs = [];
  List<Adoptee> adoptions2 = [];


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getDonorID().whenComplete( () =>
        // _getAdoptions()
    // _retrieveEntryFromArrayOfMaps()
    // _retrieveAdoptionsOfCurrentDonor()
    _retrievePrefix()
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

  _retrieveAdoptionsOfCurrentDonor() async{
    var ret = await _firestore
        .collection('Adoptions')
        .where ((user) {
          // print(user['donorList'].toString());
          // return user['name'] == 'Jerry';
          return true;
          })
        .get();         // .where('donorList',arrayContains: donorID)
  }

  _retrieveEntryFromArrayOfMaps() async{
    print('in retrieve');
    print(donorID);
    try{
      // map key : donorID
      // map value : monthlyAmount

      var ret = await _firestore
          .collection('Adoptions')
          .where('donorList',arrayContains: { 'donorID': donorID , 'monthlyAmount':123})
          .get();
      for (var element in ret.docs) {
        print(element.data()['name']);
        print('in loop');
      }
    }
    catch(e){
      print(e);
    }
  }

  _getAdoptions() async {
    var ret = await _firestore
        .collection('DonorAdoptee')
        .where('donorID', isEqualTo: donorID)
        .get();

    for (var element in ret.docs) {
      Adoptee adoptee = Adoptee(
        name: element.data()['name'],
        biography: element.data()['biography'],
        goalAmount: element.data()['goalAmount'].toDouble(),
        amountRaised: element.data()['amountRaised'].toDouble(),
        id: element.data()['adopteeID'],
        monthlyAmount: 100,
      );
      adoptions.add(adoptee);
      print(adopteeIDs);
      setState(() {});
    }


      // select where donor id == current id from DonorAdoptee table
      // this will get adonorID, adopteeID, and montly amount
      // create adopteeID list

      // then go to Adoptions table
      // grab entry if adoption id is in adopteeID list - only up to 10 entries possible for firebase where in clause

  }
  _retrievePrefix() async {
    try{
      var ret = await _firestore
          .collection('Adoptions')
          .where('active',isEqualTo: true)
          .get();
      for (var element in ret.docs) {
        // print(element.data()['donorMap']);
        // if(element.data()['donorMap'].toString().contains(donorID)){
        //   print('found donor');
        // }
        // var map = Map<String, dynamic>.from(element.data()['donorMap']);
        //
        // if(map.containsKey(donorID)){
        //   print('found donor map way');
        //   print(map[donorID]);
        // }
        if(element.data()['donorMap'].containsKey(donorID)){
          print('found donor map way3');
          Adoptee adoptee = Adoptee(
            name: element.data()['name'],
            biography: element.data()['biography'],
            goalAmount: element.data()['goalAmount'].toDouble(),
            amountRaised: element.data()['amountRaised'].toDouble(),
            id: element.data()['id'],
            monthlyAmount: element.data()['donorMap'][donorID].toDouble()
          );
          adoptions2.add(adoptee);
        }
        print('in loop');
      }
      print(adoptions2[0].monthlyAmount);

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
