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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _refreshAdoption();
    _getDonorID().whenComplete(() => _getDonorAdoptionInformation());
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
    var ret = await _firestore
        .collection('DonorAdoptee')
        .where('donorID', isEqualTo: donorID)
        .where('adopteeID', isEqualTo: widget.adoption.id)
        .get();

    if (ret.docs.isEmpty) {
      isAdopted = false;
    } else {
      var doc = ret.docs[0];
      isAdopted = true;
      monthlyAmount = doc['monthlyAmount'].toDouble();
      donorAdopteeID = doc['id'];
    }
    setState(() {});
  }

  Future<void> _adoptBeneficiary() async {
    // add entry to donorAdpotee table
    try {
      final docRef = await _firestore.collection("DonorAdoptee").add({});
      // // goalAmount, amount raised for progress bar
      //     // name and bio of adoptee
      await _firestore.collection("DonorAdoptee").doc(docRef.id).set({
        'donorID': donorID,
        'adopteeID': widget.adoption.id,
        'monthlyAmount': monthlyAmount,
        'id': docRef.id,
        'goalAmount': widget.adoption.goalAmount,
        'amountRaised': widget.adoption.amountRaised,
        'name': widget.adoption.name,
        'biography': widget.adoption.biography
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

  _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
  }

  _beneficiaryFullBody() {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: (isAdopted)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Text(
                                    'Monthly Amount: \$' +
                                        f.format(monthlyAmount),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Material(
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
                                          });
                                        }))
                              ],
                            )
                          : (!isAdopted)
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                onSaved: (value) {
                                                  monthlyAmount =
                                                      double.parse(value!);
                                                },
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter a valid payment amount.';
                                                  } else if (double.parse(
                                                          value) <
                                                      0.50) {
                                                    return 'Please provide a monthly donation amount minimum of \$0.50';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                keyboardType:
                                                    const TextInputType
                                                            .numberWithOptions(
                                                        decimal: true),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                    label: Center(
                                                      child: RichText(
                                                          text: TextSpan(
                                                        text:
                                                            'Monthly Donation Amount',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 20.0),
                                                      )),
                                                    ),
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  32.0)),
                                                    )),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Material(
                                        elevation: 5.0,
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(32.0),
                                        child: MaterialButton(
                                            child: const Text(
                                              'Adopt',
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () async {
                                              _submitForm();
                                              _adoptBeneficiary()
                                                  .whenComplete(() {
                                                _getDonorAdoptionInformation();
                                              });
                                            }))
                                  ],
                                )
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
