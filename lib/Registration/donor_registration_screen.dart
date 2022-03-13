import 'package:donaid/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

          await FirebaseMessaging.instance.subscribeToTopic('UrgentCaseApprovals').whenComplete(() => print('Subscribed to topic.'));

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
            title: const Center(
              child: Text('Alert'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'The email you chose is already in use. Please choose another email address.'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
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
          title: const Text('Donor Registration'),
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
                  const Center(
                    child: Text(
                      'DONAID',
                      style: TextStyle(fontSize: 32.0),
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                    child: Text(
                      '* - required fields',
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
                          return "Please enter your first name.";
                        } else {
                          return null;
                        }
                      },
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: const TextSpan(
                                    text: 'First Name',
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
                          return "Please enter your last name.";
                        } else {
                          return null;
                        }
                      },
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: const TextSpan(
                                    text: 'Last Name',
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
                          return "Please enter your email.";
                        } else if (!emailRegExp.hasMatch(value)) {
                          return "Please enter a valid email address.";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: const TextSpan(
                                    text: 'Email',
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
                          return "Please enter your phone number.";
                        } else if (!phoneNumberRegExp.hasMatch(value)) {
                          return "Please enter a valid phone number.";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: const TextSpan(
                                    text: 'Phone Number',
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
                          return "Password must be at least 6 characters.";
                        } else {
                          return null;
                        }
                      },
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: const TextSpan(
                                    text: 'Password',
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
                          return "Password must be at least 6 characters.";
                        } else if (value != password) {
                          return "Passwords do not match";
                        } else {
                          return null;
                        }
                      },
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          label: Center(
                            child: RichText(
                                text: const TextSpan(
                                    text: 'Confirm Password',
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
                            text: const TextSpan(
                                text: 'Note: ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15.0),
                                children: [
                                  TextSpan(
                                      text: 'All account information is kept private unless you choose to share it at a later time.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0
                                      )),
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
                        child: const Text(
                          'Register',
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
