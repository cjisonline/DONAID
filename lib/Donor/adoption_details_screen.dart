import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Adoption.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../Models/Subscription.dart';
import '../Services/subscriptions.dart';

class AdoptionDetailsScreen extends StatefulWidget {
  final Adoption adoption;
  const AdoptionDetailsScreen(this.adoption, {Key? key}) : super(key: key);

  @override
  _AdoptionDetailsScreenState createState() => _AdoptionDetailsScreenState();
}

class _AdoptionDetailsScreenState extends State<AdoptionDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Subscription> subscriptions = [];
  User? loggedInUser;
  var f = NumberFormat("###,##0.00", "en_US");
  bool isAdopted = false;
  bool hasStripeAccount=false;
  bool showLoadingSpinner=false;
  int monthlyAmount = 0;
  final _formKey = GlobalKey<FormState>();

  String cardNumber="";
  String cardExpMonth="";
  String cardExpYear="";
  String cvc="";

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getSubscription();
    _getStripeAccount();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getStripeAccount() async{
    /*This method gets the StripeAccounts document that corresponds to the logged in donor user.
    * The StripeAccounts collection contains documents that store the donor user's ID and the customer ID (given by
    * Stripe upon creation of customer account). This is so that we can start/end subscriptions for the appropriate
    * Stripe customer account based on which donor user is doing those actions.*/
    var ret = await _firestore.collection('StripeAccounts').where(
        'donorID', isEqualTo: loggedInUser!.uid).get();

    if(ret.docs.length>0){
      hasStripeAccount = true;
    }
    setState(() {});
  }

  _getSubscription() async {
    /*This method gets the StripeSubscriptions record for the logged in donor user.
    * This is so that we can check if the adoption that we are viewing has already been adopted by the user*/
    var subscriptionsDoc = await _firestore.collection('StripeSubscriptions')
        .doc(_auth.currentUser?.uid)
        .get();

    for (var item in subscriptionsDoc['subscriptionList']) {
      Subscription subscription = Subscription(
        item['adoptionID'],
        item['subscriptionID'],
        item['monthlyAmount'],
      );

      if (subscription.adoptionID == widget.adoption.id) {
        isAdopted = true;
        monthlyAmount = subscription.monthlyAmount;
      }

        subscriptions.add(subscription);
      }
      setState(() {
      });
    }

    _refreshPage() async {
    /*Refreshes the information on the page*/
      isAdopted = false;
      await _getSubscription();
      await _getStripeAccount();

      var ret = await _firestore.collection('Adoptions').where(
          'id', isEqualTo: widget.adoption.id).get();
      var doc = ret.docs.first;
      widget.adoption.amountRaised = doc.data()['amountRaised'];

      setState(() {
      });
    }

    Future<Map<String, dynamic>> _createCustomer() async {
    /*This method creates a Stripe customer for the donor user.  We simply call a method in the node app that we created
    * to communicate with the Stripe API. That method will then use the Stripe API to create a new customer and it will return
    * the new customer ID. We then store that new customer ID with the donor ID in the StripeAccounts collection.*/
      final body = {
        'description': 'New customer'
      };
      var response = await http.post(
          Uri.https('donaidmobileapp.herokuapp.com', '/create-new-customer'),
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'}
      );
      print('CREATE CUSTOMER RESPONSE: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        var docRef = await _firestore.collection('StripeAccounts').add({});

        await _firestore.collection('StripeAccounts').doc(docRef.id).set({
          'id': docRef.id,
          'donorID': loggedInUser!.uid,
          'customerID': json.decode(response.body)['id'],
        });

        return json.decode(response.body);
      } else {
        print(json.decode(response.body));
        throw 'Failed to register as a customer.';
      }
    }

    Future<Map<String, dynamic>> _createPaymentMethod(
        /*When a donor user adopts for the first time, they enter their payment information. The payment information
        * is then used to create a payment method in Stripe.*/
        {required String number, required String expMonth, required String expYear, required String cvc}) async {
      final body = {
        'number': '$number',
        'exp_month': '$expMonth',
        'exp_year': '$expYear',
        'cvc': '$cvc',
      };

      var response = await http.post(
        Uri.https('donaidmobileapp.herokuapp.com', '/create-payment-method'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(json.decode(response.body));
        throw 'Failed to create PaymentMethod.';
      }
    }

    Future<Map<String, dynamic>> _attachPaymentMethod(String paymentMethodId,
        String customerId) async {
    /*This method attaches the created payment method to the created customer account so that
    * recurring payments can be done.*/
      final body = {
        'customer': customerId,
        'paymentMethod': paymentMethodId
      };

      var response = await http.post(
        Uri.https('donaidmobileapp.herokuapp.com', '/attach-payment-method'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(json.decode(response.body));
        throw 'Failed to attach PaymentMethod.';
      }
    }

    Future<Map<String, dynamic>> _updateCustomer(String paymentMethodId,
        String customerId) async {
    /*This method updates the customer information to have the attached payment information.*/
      final body = {
        'customer': customerId,
        'default_payment_method': paymentMethodId,
      };

      var response = await http.post(
        Uri.https('donaidmobileapp.herokuapp.com', '/update-customer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print('UPDATE CUSTOMER RESPONSE: ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(json.decode(response.body));
        throw 'Failed to update Customer.';
      }
    }

    Future<Map<String, dynamic>> _createSubscriptions(String customerId) async {
    /*This method creates the subscription. Stripe requires subscriptions to be a predefined price provided by the business. So in order for us to let
    * donor users provide their own contribution amount, we created a subscription item that costs $1 in Stripe. So, when a donor users enters a dollar amount
    * for their contribution, we subscribe them to that quantity of $1 subscriptions.
    * For example, a $50 subscriptions is handled by Stripe as purchasing fifty $1 subscriptions.*/
      Map<String, dynamic> body = {
        'customer': customerId,
        'quantity': monthlyAmount,
      };

      var response = await http.post(
          Uri.https('donaidmobileapp.herokuapp.com', '/create-subscription'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body)
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(json.decode(response.body));
        throw 'Failed to register as a subscriber.';
      }
    }

  Future<Map<String, dynamic>> _cancelSubscription(String subscriptionId) async {
    /*This method passes the subscription ID to Stripe and cancels that subscription at the end of the billing cycle*/
    Map<String, dynamic> body = {
      'subscription': subscriptionId,
    };

    var response = await http.post(
        Uri.https('donaidmobileapp.herokuapp.com', '/cancel-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body)
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to cancel subscription.';
    }
  }



    _subscribe() async {

      var ret = await _firestore.collection('StripeAccounts').where(
          'donorID', isEqualTo: loggedInUser!.uid).get();


      if (ret.docs.length > 0) {
        //If the donor user already has given the app payment information and had a stripe account created
        final donorCustomerRecord = ret.docs.first;
        final customerID = donorCustomerRecord['customerID'];
        final createdSubscription = await _createSubscriptions(customerID);
        Subscription subscription = Subscription(
            widget.adoption.id, createdSubscription['id'], monthlyAmount);
        await addSubscription(loggedInUser!.uid, subscription);
      }
      else {
        //If the donor user has not given payment information and created a stripe account yet,
        //this block will be called to create their customer account and payment method before subscribing them
        final _customer = await _createCustomer();
        final _paymentMethod = await _createPaymentMethod(
            number: cardNumber,
            expMonth: cardExpMonth,
            expYear: cardExpYear,
            cvc: cvc);
        await _attachPaymentMethod(_paymentMethod['id'], _customer['id']);
        await _updateCustomer(_paymentMethod['id'], _customer['id']);
        final createdSubscription = await _createSubscriptions(_customer['id']);
        Subscription subscription = Subscription(
            widget.adoption.id, createdSubscription['id'], monthlyAmount);
        await addSubscription(loggedInUser!.uid, subscription);
      }
      await _firestore
          .collection('Adoptions')
          .doc(widget.adoption.id)
          .update(
          {'amountRaised': widget.adoption.amountRaised + monthlyAmount});

      await _refreshPage();
    }

    _unsubscribe() async {
    //This method gets the subscription ID from Firestore and passes it to the cancelSubscription method
      var cancelSubscription = subscriptions.where((item) =>
      item.adoptionID == widget.adoption.id)
          .toList()
          .first;


      await _cancelSubscription(cancelSubscription.subscriptionsID);

      deleteSubscription(loggedInUser!.uid, cancelSubscription);
      await _firestore.collection('Adoptions').doc(widget.adoption.id).update({
        'amountRaised': widget.adoption.amountRaised - monthlyAmount
      });

      _refreshPage();
    }


    Future<void> _cancelAdoptionConfirm() async {
      return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Text('Are You Sure?'.tr),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              content:  Text(
                  'are_you_sure_you_want_to_cancel_this_adoption'.tr),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          setState(() {
                            showLoadingSpinner=true;
                          });
                          await _unsubscribe();
                          setState(() {
                            showLoadingSpinner=false;
                          });
                        },
                        child: Text('yes'.tr),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('no'.tr),
                      ),
                    ),
                  ],
                ),


              ],
            );
          });
    }

    //This method is simply used to double check that the entered monthly amount is an integer
  // since our subscriptions can only be done in whole dollar amounts
    bool isInteger(num value) =>
        value is int || value == value.roundToDouble();

    _beneficiaryFullBody() {
      return ModalProgressHUD(
        inAsyncCall: showLoadingSpinner,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(
                        height: 100,
                        child: Image.asset('assets/DONAID_LOGO.png')),
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
                          borderRadius: const BorderRadius.all(
                              Radius.circular(10)),
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
                                      'monthly_amount'.tr +
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
                                        child: Text(
                                          'cancel_adoption'.tr,
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
                                    child: hasStripeAccount ?
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                'adoptions_can_only_be_made_in_whole_dollar_amounts'.tr),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            onChanged: (value) {
                                              monthlyAmount =
                                                  int.parse(value);
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty || !isInteger(
                                                  double.parse(value))) {
                                                return 'please_enter_a_valid_payment_amount'.tr;
                                              } else if (double.parse(
                                                  value) <
                                                  0.50) {
                                                return 'please_provide_a_donation_minimum'.tr;
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
                                                        'monthly_donation_amount'.tr,
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
                                      ]
                                    )
                                        :
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                          children: [
                                              Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'adoptions_can_only_be_made_in_whole_dollar_amounts'.tr),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  maxLength: 16,
                                                  onChanged: (value) {
                                                    cardNumber = value.toString();
                                                  },
                                                  validator: (value) {
                                                    if (value!.isEmpty || value.length < 16) {
                                                      return 'please_enter_a_valid_card_number'.tr;
                                                    }
                                                    else {
                                                      return null;
                                                    }
                                                  },
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                      label: Center(
                                                        child: RichText(
                                                            text: TextSpan(
                                                              text:
                                                              'card_number'.tr,
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
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 110,
                                                      child: TextFormField(
                                                        maxLength: 2,
                                                        onChanged: (value) {
                                                          cardExpMonth = value.toString();
                                                        },
                                                        validator: (value) {
                                                          if (value!.isEmpty || value.length !=2) {
                                                            return 'please_enter_a_valid_expiration_month'.tr;
                                                          }
                                                          else {
                                                            return null;
                                                          }
                                                        },
                                                        keyboardType: TextInputType.number,
                                                        textAlign: TextAlign.center,
                                                        decoration: InputDecoration(
                                                            label: Center(
                                                              child: RichText(
                                                                  text: TextSpan(
                                                                    text:
                                                                    'month'.tr,
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
                                                    Container(
                                                      width: 110,
                                                      child: TextFormField(
                                                        maxLength: 2,
                                                        onChanged: (value) {
                                                          cardExpYear = value.toString();
                                                        },
                                                        validator: (value) {
                                                          if (value!.isEmpty || value.length !=2) {
                                                            return 'please_enter_a_valid_expiration_year'.tr;
                                                          }
                                                          else {
                                                            return null;
                                                          }
                                                        },
                                                        keyboardType: TextInputType.number,
                                                        textAlign: TextAlign.center,
                                                        decoration: InputDecoration(
                                                            label: Center(
                                                              child: RichText(
                                                                  text: TextSpan(
                                                                    text:
                                                                    'year'.tr,
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
                                                    Container(
                                                      width: 110,
                                                      child: TextFormField(
                                                        maxLength: 3,
                                                        onChanged: (value) {
                                                          cvc = value.toString();
                                                        },
                                                        validator: (value) {
                                                          if (value!.isEmpty || value.length !=3) {
                                                            return 'please_enter_a_valid_cvc'.tr;
                                                          }
                                                          else {
                                                            return null;
                                                          }
                                                        },
                                                        keyboardType: TextInputType.number,
                                                        textAlign: TextAlign.center,
                                                        decoration: InputDecoration(
                                                            label: Center(
                                                              child: RichText(
                                                                  text: TextSpan(
                                                                    text:
                                                                    'CVC',
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
                                                  ]
                                                ),
                                              ),
                                              SizedBox(
                                                height:25
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  onChanged: (value) {
                                                    monthlyAmount =
                                                        int.parse(value);
                                                  },
                                                  validator: (value) {
                                                    if (value!.isEmpty || !isInteger(
                                                        double.parse(value))) {
                                                      return 'please_enter_a_valid_payment_amount'.tr;
                                                    } else if (double.parse(
                                                        value) <
                                                        0.50) {
                                                      return 'please_provide_a_monthly_donation_amount_minimum_of_one_dollar'.tr;
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
                                                              'monthly_donation_amount'.tr,
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
                                        ),
                                ),
                                Material(
                                    elevation: 5.0,
                                    color: Colors.green,
                                    borderRadius:
                                    BorderRadius.circular(32.0),
                                    child: MaterialButton(
                                        child: Text(
                                          'adopt'.tr,
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if(_formKey.currentState!.validate()){
                                            setState(() {
                                              showLoadingSpinner=true;
                                            });
                                            await _subscribe();
                                            setState(() {
                                              showLoadingSpinner=false;
                                            });
                                          }
                                        }))
                              ],
                            )
                                : Container()),
                      ],
                    ),
                  ]))),
        ),
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
  }