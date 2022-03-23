import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/GatewayVisit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Models/Donor.dart';
import 'OrganizationWidget/organization_bottom_navigation.dart';
import 'OrganizationWidget/organization_drawer.dart';

class GatewayVisits extends StatefulWidget {
  static const id = 'gateway_visits';
  const GatewayVisits({Key? key}) : super(key: key);

  @override
  _GatewayVisitsState createState() => _GatewayVisitsState();
}

class _GatewayVisitsState extends State<GatewayVisits> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<GatewayVisit> visits = [];
  List<Donor> donors = [];

  @override
  void initState() {
    super.initState();
    _getGatewayVisits();
  }

  _getGatewayVisits() async {
    var ret = await _firestore
        .collection('GatewayVisits')
        .where('organizationID', isEqualTo: _auth.currentUser!.uid)
        .get();

    for (var doc in ret.docs) {
      GatewayVisit visit = GatewayVisit(
        charityType: doc.data()['charityType'],
        charityTitle: doc.data()['charityTitle'],
        donorID: doc.data()['donorID'],
        organizationID: doc.data()['organizationID'],
        id: doc.data()['id'],
        visitedAt: doc.data()['visitedAt'],
        charityID: doc.data()['charityID']
      );

      visits.add(visit);
    }

    _getDonors();
  }

  _getDonors() async {
    for (var visit in visits) {
      var ret = await _firestore
          .collection('DonorUsers')
          .where('uid', isEqualTo: visit.donorID)
          .get();

      var doc = ret.docs.first;
      Donor donor = Donor(
        email: doc.data()['email'],
        firstName: doc.data()['firstName'],
        lastName: doc.data()['lastName'],
        phoneNumber: doc.data()['phoneNumber'],
        id: doc.data()['id'],
      );
      donors.add(donor);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gateway Visits'.tr),
        backgroundColor: Colors.blue,
      ),
      drawer: const OrganizationDrawer(),
      body: _body(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }

  _body() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Did this visit result in a donation?',
              style: TextStyle(fontSize: 18),
            ),
          ),
          ListView.builder(
              itemCount: visits.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, int index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                          '${donors[index].firstName} ${donors[index].lastName.substring(0, 1)}. - ${visits[index].charityTitle}\n(${visits[index].charityType})'),
                      subtitle: Text(DateFormat('yyyy-MM-dd')
                          .format(visits[index].visitedAt.toDate())),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                              onPressed: () {
                                //TODO: get donation amount
                              },
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 40,
                              )),
                          IconButton(
                              onPressed: () {
                                //TODO: mark as read
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 40,
                              ))
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    )
                  ],
                );
              }),
        ],
      ),
    );
  }
}
