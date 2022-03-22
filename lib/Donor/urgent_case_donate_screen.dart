import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/urgent_cases_expanded_screen.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:get/get.dart';


class UrgentCaseDonateScreen extends StatefulWidget {
  UrgentCase urgentCase;
  UrgentCaseDonateScreen(this.urgentCase, {Key? key}) : super(key: key);

  @override
  _UrgentCaseDonateScreenState createState() => _UrgentCaseDonateScreenState();
}

class _UrgentCaseDonateScreenState extends State<UrgentCaseDonateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? paymentIntentData;
  String donationAmount = "";
  bool showLoadingSpinner = false;
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState(){
    super.initState();

  }

  _refreshPage() async {
    var ret = await _firestore.collection('UrgentCases').where('id',isEqualTo: widget.urgentCase.id).get();

    var doc = ret.docs[0];
    widget.urgentCase.amountRaised = doc['amountRaised'];
  }

  Future<void> _confirmDonationAmount() async {
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
            content: const Text(
                'We see that you\'ve entered a donation amount greater than \$999. We appreciate your generosity, but please confirm that this amount'
                    ' is correct to proceed.'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () async{
                    Navigator.pop(context);
                    await makePayment();


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

  _campaignDonateBody() {
    return ModalProgressHUD(
      inAsyncCall: showLoadingSpinner,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                    height: 100,
                    child: Image.asset('assets/DONAID_LOGO.png')
                ),
                Text(widget.urgentCase.title, style: TextStyle(fontSize: 25)),
                Text(widget.urgentCase.description, style: TextStyle(fontSize: 18),),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$'+f.format(widget.urgentCase.amountRaised),
                          style: const TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        Text(
                          '\$'+f.format(widget.urgentCase.goalAmount),
                          style: const TextStyle(color: Colors.black, fontSize: 18),
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
                        value:
                        (widget.urgentCase.amountRaised / widget.urgentCase.goalAmount),
                        minHeight: 25,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: (widget.urgentCase.active == true && (widget.urgentCase.endDate).compareTo(Timestamp.now())>0)
                    ? Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onChanged: (value) {
                                donationAmount = value.toString();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'please_enter_a_valid_payment_amount'.tr;
                                }
                                else if(double.parse(value)<0.50){
                                  return 'please_provide_a_donation_minimum'.tr;
                                }
                                else {
                                  return null;
                                }
                              },
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  label: Center(
                                    child: RichText(
                                        text: TextSpan(
                                          text: 'donation_amount'.tr,
                                          style: TextStyle(
                                              color: Colors.grey[600], fontSize: 20.0),
                                        )),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              elevation: 5.0,
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(32.0),
                              child: MaterialButton(
                                child:  Text(
                                  'donate'.tr,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      showLoadingSpinner = true;
                                    });
                                    if(double.parse(donationAmount) > 999){
                                      _confirmDonationAmount();
                                    }
                                    else {
                                      await makePayment();
                                    }
                                    setState(() {
                                      showLoadingSpinner=false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ))
                  : Text('ugent_case_is_no_longer'.tr),
                )
              ]),
            )),
      ),
    );
  }

  void createDonationDocument() async{
    final docRef = await _firestore.collection('Donations').add({});

    await _firestore.collection('Donations').doc(docRef.id).set({
      'id':docRef.id,
      'donorID': _auth.currentUser?.uid,
      'organizationID': widget.urgentCase.organizationID,
      'charityID': widget.urgentCase.id,
      'charityName':widget.urgentCase.title,
      'donationAmount': donationAmount,
      'donatedAt':Timestamp.now(),
      'charityType':'UrgentCases',
      'category':widget.urgentCase.category
    });

  }

  void updateUrgentCase() async{
    if(widget.urgentCase.amountRaised+double.parse(donationAmount) >= widget.urgentCase.goalAmount){
      await _firestore.collection('UrgentCases').doc(widget.urgentCase.id).update({
        'amountRaised': widget.urgentCase.amountRaised+double.parse(donationAmount),
        'active':false
      });
      Navigator.popUntil(context, ModalRoute.withName(UrgentCasesExpandedScreen.id));
    }
    else{
      await _firestore.collection('UrgentCases').doc(widget.urgentCase.id).update({
        'amountRaised': widget.urgentCase.amountRaised+double.parse(donationAmount)
      });
    }

  }
  Future<void> makePayment() async {
    try {
      paymentIntentData =
      await createPaymentIntent(donationAmount, 'USD');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            applePay: true,
            googlePay: true,
            style: ThemeMode.dark,
            merchantCountryCode: 'US',
            merchantDisplayName: 'DONAID',
          ));

      print(paymentIntentData);
      await displayPaymentSheet();

    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet(
        parameters: PresentPaymentSheetParameters(
          clientSecret: paymentIntentData!['client_secret'],
          confirmPayment: true,
        ),

      );

      setState(() {
        // paymentIntentData = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(content: Text('paid_successfully'.tr)));

      createDonationDocument();
      updateUrgentCase();
      await _refreshPage();

    }catch (e) {
      print('Stripe Exception: ${e.toString()}');

      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(content: Text('payment_cancelled!'.tr)));

    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      final body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types':['card']
      };

      var response = await http.post(
          Uri.https('donaidmobileapp.herokuapp.com','/create-payment-intent'),
          body: jsonEncode(body),
          headers: {'Content-Type':'application/json'}
      );

      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }

  calculateAmount(String amount) {
    final price = (double.parse(amount)*100).toInt();
    return price.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //doubt
        title: Text('donate'.tr + ' - ${widget.urgentCase.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _campaignDonateBody(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
