import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  List<Adoption> adoptions = [];
  var f = NumberFormat("###,##0.00", "en_US");



  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getAdoptions();
  }

  _refreshPage(){
    adoptions.clear();
    _getCurrentUser();
    _getAdoptions();
    setState(() {

    });
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }


  _getAdoptions() async {
        // call database method here
        Adoption adoption = Adoption(
          name: "Bill",
          biography: "Need funds to help pay for college fees.",
          goalAmount: 50000,
          amountRaised: 10000,
          category: "Education",
          dateCreated: Timestamp.now(),
          id: "asdf",
          organizationID: "asdf",
          active: true,
        );
        adoptions.add(adoption);

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

  _body() {
    return  RefreshIndicator(
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

  }

