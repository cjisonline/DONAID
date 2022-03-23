import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Adoption.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdoptionDetailsScreen extends StatefulWidget {
  final Adoption adoption;
  const AdoptionDetailsScreen(this.adoption, {Key? key}) : super(key: key);

  @override
  _AdoptionDetailsScreenState createState() => _AdoptionDetailsScreenState();
}

class _AdoptionDetailsScreenState extends State<AdoptionDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  var f = NumberFormat("###,##0.00", "en_US");
  bool isAdopted = false;
  double monthlyAmount = 0;
  String donorID = "";
  String donorAdopteeID = "";

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _refreshAdoption();
    _getDonorID().whenComplete( () =>
        _getDonorAdoptionInformation()

    );
  }

  _refreshAdoption() async {
    var ret = await _firestore
        .collection('Adoptions')
        .where('id', isEqualTo: widget.adoption.id)
        .get();
    var doc = ret.docs[0];
    widget.adoption.name = doc['name'];
    widget.adoption.biography = doc['biography'];
    widget.adoption.category = doc['category'];
    widget.adoption.goalAmount = doc['goalAmount'].toDouble();
    widget.adoption.active = doc['active'];
    widget.adoption.id = doc['id'];
    setState(() {});
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

  _getDonorAdoptionInformation() async {
    print('donor: $donorID, adoption: ${widget.adoption.id}');
    var ret = await _firestore
        .collection('DonorAdoptee')
        .where('donorID', isEqualTo: donorID)
        .where('adopteeID', isEqualTo: widget.adoption.id)
        .get();

    if (ret.docs.isEmpty) {
      print('in donor isadopted false');
      isAdopted = false;
    } else {
      print('in donor isadopted true');
      var doc = ret.docs[0];
      isAdopted = true;
      monthlyAmount = doc['monthlyAmount'].toDouble();
      donorAdopteeID = doc['id'];

    }
    setState(() {});
  }

  Future<void> _adoptBeneficiary(
      String donorID, String adopteeID, double monthlyAmount) async {
    // add entry to donorAdpotee table
    try {
      final docRef = await _firestore.collection("DonorAdoptee").add({});
      await _firestore.collection("DonorAdoptee").doc(docRef.id).set({
        'donorID': donorID,
        'adopteeID': adopteeID,
        'monthlyAmount': monthlyAmount,
        'id': docRef.id,
      });
      donorAdopteeID = docRef.id;
    } catch (e) {
      print(e);
    }
  }

  _cancelBeneficiaryAdoption() async {
    // delete entry to donorAdpotee table
    try {
      await _firestore.collection('DonorAdoptee').doc(donorAdopteeID).delete();
    } catch (e) {
      print(e);
    }
  }

  _beneficiaryFullBody() {
    print('bene {$isAdopted}');
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  height: 100, child: Image.asset('assets/DONAID_LOGO.png')),
              SizedBox(height: 10),
              Text(
                widget.adoption.name,
                style: TextStyle(fontSize: 25),
              ),
              Text(
                widget.adoption.biography,
                style: TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$' + f.format(widget.adoption.amountRaised),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Text(
                        '\$' + f.format(widget.adoption.goalAmount),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                      value: (widget.adoption.amountRaised /
                          widget.adoption.goalAmount),
                      minHeight: 25,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: (isAdopted)
                          ? Material(
                              elevation: 5.0,
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(32.0),
                              child: MaterialButton(
                                  child: const Text(
                                    'Cancel Adoption',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    _cancelBeneficiaryAdoption()
                                        .whenComplete(() {
                                      _getDonorAdoptionInformation();
                                      print('in on press: $isAdopted');
                                    });
                                  }))
                          : (!isAdopted)
                              ? Material(
                                  elevation: 5.0,
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(32.0),
                                  child: MaterialButton(
                                      child: const Text(
                                        'Adopt',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () async {
                                        _adoptBeneficiary(donorID,
                                                widget.adoption.id, 333.0)
                                            .whenComplete(() {
                                          _getDonorAdoptionInformation();
                                          print('in on press: $isAdopted');
                                        });
                                      }))
                              : Container()),
                ],
              ),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adoption.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const OrganizationDrawer(),
      body: _beneficiaryFullBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
