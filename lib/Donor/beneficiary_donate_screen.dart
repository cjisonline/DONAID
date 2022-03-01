import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'package:http/http.dart' as http;

class BeneficiaryDonateScreen extends StatefulWidget {
  Beneficiary beneficiary;
  BeneficiaryDonateScreen(this.beneficiary, {Key? key}) : super(key: key);

  @override
  _BeneficiaryDonateScreenState createState() => _BeneficiaryDonateScreenState();
}

class _BeneficiaryDonateScreenState extends State<BeneficiaryDonateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? paymentIntentData;
  String donationAmount = "";
  bool showLoadingSpinner = false;

  @override
  void initState(){
    super.initState();
  }

  _refreshPage() async {
    var ret = await _firestore.collection('Beneficiaries').where('id',isEqualTo: widget.beneficiary.id).get();

    var doc = ret.docs[0];
    widget.beneficiary.amountRaised = doc['amountRaised'];
  }


  _beneficiaryDonateBody() {
    return ModalProgressHUD(
      inAsyncCall: showLoadingSpinner,
      child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.beneficiary.name),
              Text(widget.beneficiary.biography),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(widget.beneficiary.amountRaised.toStringAsFixed(2))}',
                        style: const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                      Text(
                        '\$${widget.beneficiary.goalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  value:
                  (widget.beneficiary.amountRaised / widget.beneficiary.goalAmount),
                  minHeight: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: (widget.beneficiary.active == true && (widget.beneficiary.endDate).compareTo(Timestamp.now()) > 0)
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
                                return 'Please enter a valid payment amount.';
                              }
                              else if(double.parse(value)<0.50){
                                return 'Please provide a donation minimum of \$0.50';
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
                                        text: 'Donation Amount',
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
                              child: const Text(
                                'Donate',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    showLoadingSpinner = true;
                                  });
                                  await makePayment();

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
                    : const Text('Beneficiary is no longer available to donate to.'),
              )
            ]),
          )),
    );
  }

  void createDonationDocument() async{

    final docRef = await _firestore.collection('Donations').add({});

    await _firestore.collection('Donations').doc(docRef.id).set({
      'id':docRef.id,
      'donorID': _auth.currentUser?.uid,
      'organizationID': widget.beneficiary.organizationID,
      'charityID': widget.beneficiary.id,
      'charityName':widget.beneficiary.name,
      'donationAmount': donationAmount,
      'donatedAt':Timestamp.now(),
      'charityType':'Beneficiaries',
      'category':widget.beneficiary.category
    });

  }

  void updateBeneficiary() async{
    if(widget.beneficiary.amountRaised+double.parse(donationAmount) >= widget.beneficiary.goalAmount){
      await _firestore.collection('Beneficiaries').doc(widget.beneficiary.id).update({
        'amountRaised': widget.beneficiary.amountRaised+double.parse(donationAmount),
        'active':false
      });
    }
    else{
      await _firestore.collection('Beneficiaries').doc(widget.beneficiary.id).update({
        'amountRaised': widget.beneficiary.amountRaised+double.parse(donationAmount)
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
          .showSnackBar(const SnackBar(content: Text('Paid successfully!')));

      createDonationDocument();
      updateBeneficiary();
      await _refreshPage();

    }on StripeException catch (e) {
      print('Stripe Exception: ${e.toString()}');

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment cancelled.')));

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
        title: Text('Donate - ${widget.beneficiary.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _beneficiaryDonateBody(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
