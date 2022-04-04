import 'dart:convert';
import 'package:http/http.dart' as http;
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
  String donorAdopteeID = "";
  final _formKey = GlobalKey<FormState>();
  var donorMap;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getAdoption();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getAdoption() async {
    try {
      var ret = await _firestore
          .collection('Adoptions')
          .where('active', isEqualTo: true)
          .where('id', isEqualTo: widget.adoption.id)
          .get();
      if (ret.docs.isEmpty) {
        isAdopted = false;
      } else {
        var doc = ret.docs[0];
        if (doc['donorMap'] != null &&
            doc['donorMap'].containsKey(_auth.currentUser?.uid)) {
          isAdopted = true;
          monthlyAmount = doc['donorMap'][_auth.currentUser?.uid].toDouble();
          donorMap = doc['donorMap'];
          widget.adoption.name = doc['name'];
          widget.adoption.biography = doc['biography'];
          widget.adoption.category = doc['category'];
          widget.adoption.goalAmount = doc['goalAmount'].toDouble();
          widget.adoption.active = doc['active'];
          widget.adoption.id = doc['id'];
        } else {
          isAdopted = false;
        }
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _adoptBeneficiary() async {
    try {
      // update adoption and add entry to donorMap
      _subscribe(); //create stripe subscription
      _firestore
          .collection('Adoptions')
          .doc(widget.adoption.id)
          .update({"donorMap.${_auth.currentUser?.uid}": monthlyAmount});
    } catch (e) {
      print(e);
    }
  }

  _cancelBeneficiaryAdoption() async {
    // delete entry from donorMap
    try {
      _firestore.collection('Adoptions').doc(widget.adoption.id).update({
        "donorMap": donorMap.remove({_auth.currentUser?.uid: monthlyAmount})
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> _createCustomer() async {
    final body = {
      'description':'new customer'
    };
    var response = await http.post(
        Uri.https('donaidmobileapp.herokuapp.com','/create-new-customer'),
        body: jsonEncode(body),
        headers: {'Content-Type':'application/json'}
    );

    if (response.statusCode == 200) {
      var docRef = await _firestore.collection('StripeCustomersMap').add({});

      await _firestore.collection('StripeCustomersMap').doc(docRef.id).set({
        'id': docRef.id,
        'donorID': loggedInUser!.uid,
        'customerID': json.decode(response.body)['id']
      });

      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a customer.';
    }
  }

  Future<Map<String, dynamic>> _createPaymentMethod({required String number,required String expMonth,required String expYear,required String cvc}) async {

    final body = {
      'type': 'card',
      'card[number]': '$number',
      'card[exp_month]': '$expMonth',
      'card[exp_year]': '$expYear',
      'card[cvc]': '$cvc',
    };

    var response = await http.post(
      Uri.https('donaidmobileapp.herokuapp.com','/create-payment-method'),
      headers:  {'Content-Type':'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to create PaymentMethod.';
    }
  }

  Future<Map<String, dynamic>> _attachPaymentMethod(String paymentMethodId, String customerId) async {
    final body = {
      'customer': customerId,
    };

    var response = await http.post(
      Uri.https('donaidmobileapp.herokuapp.com','/attach-payment-method'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to attach PaymentMethod.';
    }
  }

  Future<Map<String, dynamic>> _updateCustomer(String paymentMethodId, String customerId) async {
    final body = {
      'invoice_settings[default_payment_method]': paymentMethodId,
    };

    var response = await http.post(
      Uri.https('donaidmobileapp.herokuapp.com','/attach-payment-method'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to update Customer.';
    }
  }

  Future<Map<String, dynamic>> _createSubscriptions(String customerId) async {
    final String url = 'https://api.stripe.com/v1/subscriptions';

    Map<String, dynamic> body = {
      'customer': customerId,
      'items[0][price]': calculateAmount(monthlyAmount.toString()),
    };

    var response =
    await http.post(Uri.https('donaidmobileapp.herokuapp.com','/create-subscription'), headers: {'Content-Type':'application/json'}, body: jsonEncode(body));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a subscriber.';
    }
  }

  _subscribe() async{
    var ret = await _firestore.collection('StripeCustomersMap').where('donorID', isEqualTo: loggedInUser!.uid).get();
    if(ret.docs.length > 0) {
      //TODO: subscribe this customer
      final donorCustomerRecord = ret.docs.first;
      final customerID = donorCustomerRecord['customerID'];
      await _createSubscriptions(customerID);

    }
    else{
      //TODO: create new subscription
      final _customer = await _createCustomer();
      final _paymentMethod = await _createPaymentMethod(number: '4242424242424242', expMonth: '03', expYear: '23', cvc: '123');
      await _attachPaymentMethod(_paymentMethod['id'], _customer['id']);
      await _updateCustomer(_paymentMethod['id'], _customer['id']);
      await _createSubscriptions(_customer['id']);
    }
  }


  Future<void> _cancelAdoptionConfirm() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text('Are You Sure?'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text('Are you sure you want to cancel this adoption '
                'you can readopt this beneficiary from the Beneficiaries page. Would you like to continue'
                ' with canceling this adoption?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _cancelBeneficiaryAdoption().whenComplete(() {
                      _getAdoption();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Yes'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
              ),
            ],
          );
        });
  }

  _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
  }

  _beneficiaryFullBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Monthly Amount: \$' +
                                            f.format(monthlyAmount),
                                        style: TextStyle(fontSize: 18),
                                      ),
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
                                            _cancelAdoptionConfirm();
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
                                                  _getAdoption();
                                                });
                                              }))
                                    ],
                                  )
                                : Container()),
                  ],
                ),
              ]))),
    );
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

  calculateAmount(String amount) {
    final price = (double.parse(amount)*100).toInt();
    return price.toString();
  }
}
