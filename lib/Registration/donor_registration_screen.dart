import 'package:donaid/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class DonorRegistrationScreen extends StatefulWidget {
  static const id = 'donor_registration_screen';
  const DonorRegistrationScreen({Key? key}) : super(key: key);

  @override
  _DonorRegistrationScreenState createState() =>
      _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final Future<SharedPreferences> _prefs =  SharedPreferences.getInstance();

  final _formKey = GlobalKey<FormState>();

  static final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phoneNumberRegExp =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');

  bool showLoadingSpinner = false;

  String firstName = "";
  String lastName = "";
  String email = "";
  String password = "";
  String passwordConfirm = "";
  String phoneNumber = "";

  Future<bool> isEmailAvailable() async {
    //This method checks to make sure the email is not already being used in Firebase
    final list = await _auth.fetchSignInMethodsForEmail(email);

    if (list.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void createNewDonorUser() async {
    //This method creates the new user in Firebase
    if (await isEmailAvailable()) {
      //If the email is available
      try {
        dynamic newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        if (newUser != null) {
          final docRef = await _firestore.collection('DonorUsers').add({});

          await _firestore.collection('DonorUsers').doc(docRef.id).set({
            'id': docRef.id,
            'uid': newUser.user.uid,
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'phoneNumber': phoneNumber,
            'enabled':true
          });

          final usersDocRef = await _firestore.collection('Users').add({});

          await _firestore.collection('Users').doc(usersDocRef.id).set({
            'id': usersDocRef.id,
            'uid':newUser.user.uid,
            'email':email,
            'userType':1
          });

          await FirebaseMessaging.instance.subscribeToTopic('UrgentCaseApprovals');
          final SharedPreferences prefs = await _prefs;
          await prefs.setBool('urgentCaseApprovalsNotifications', true);

          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.id)); //remove all screens on the stack and return to home screen
          Navigator.pushNamed(context, LoginScreen.id); //redirect to login screen
        }
      } catch (signUpError) {
        print(signUpError);
      }
    } else {
      //If the email is already in use
      print('Email not available.');
      _emailInUseDialog();
    }
  }

  Future<void> _emailInUseDialog() async {
    setState(() {
      showLoadingSpinner = false;
    });
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('alert'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content:  Text(
                'The email you chose is already in use.'.tr),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text('ok'.tr),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:  Text('donor_registration'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: showLoadingSpinner,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                   Center(
                    child: Text(
                      'donaid'.tr,
                      style: TextStyle(fontSize: 32.0),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                   Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                    child: Text(
                      '* - required_fields'.tr,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) {
                        firstName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please_enter_your_first_name.".tr;
                        } else {
                          return null;
                        }
                      },
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text:  TextSpan(
                                    text: 'first_name'.tr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20.0),
                                    children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ])),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) {
                        lastName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please_enter_your_last_name.".tr;
                        } else {
                          return null;
                        }
                      },
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text:  TextSpan(
                                    text: 'last_name'.tr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20.0),
                                    children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ])),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please_enter_your_email.".tr;
                        } else if (!emailRegExp.hasMatch(value)) {
                          return "please_enter_a_valid_email_address.".tr;
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text:  TextSpan(
                                    text: 'email'.tr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20.0),
                                    children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ])),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) {
                        phoneNumber = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please_enter_your_phone_number.".tr;
                        } else if (!phoneNumberRegExp.hasMatch(value)) {
                          return "please_enter_a_valid_phone_number.".tr;
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text:  TextSpan(
                                    text: 'phone_number'.tr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20.0),
                                    children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ])),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return "password_must_be_at_least_6_characters.".tr;
                        } else {
                          return null;
                        }
                      },
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text:  TextSpan(
                                    text: 'password'.tr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20.0),
                                    children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ])),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (value) {
                        passwordConfirm = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return "password_must_be_at_least_6_characters.".tr;
                        } else if (value != password) {
                          return "passwords_do_not_match".tr;
                        } else {
                          return null;
                        }
                      },
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text:  TextSpan(
                                    text: 'confirm_password'.tr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20.0),
                                    children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ])),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Center(
                        child: RichText(
                            text:  TextSpan(
                                text: 'note'.tr+' ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15.0),
                                children: [
                              TextSpan(
                                  text:
                                      'all_account_information_is_kept_private'.tr,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15.0)),
                            ])),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25.0, horizontal: 5.0),
                    child: Material(
                      elevation: 5.0,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(32.0),
                      child: MaterialButton(
                        child:  Text(
                          'register'.tr,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              showLoadingSpinner = true;
                            });

                            createNewDonorUser();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
