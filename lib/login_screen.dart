import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Donor/donor_dashboard.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool passwordreset = false;
  final _formKey = GlobalKey<FormState>();

  static final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  String email = "";
  String password = "";
  bool showLoadingSpinner = false;

  Future<int> getUserType() async {
    //Searches firestore for the user corresponding to the email. Changes the userType variable accordingly.
    int userType = -1;
    try {
      final user = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      userType = user.docs[0]['userType'];
      print('USERTYPE: $userType');
    } catch (e) {
      print(e);
    }

    return userType;
  }

  void loginUser() async {
    try {
      final userType = await getUserType();
      if (userType == 1) {
        //If user logging in is a donor user
        final donorUser = await _firestore.collection('DonorUsers').where('email', isEqualTo: email).get();
        final enabled = donorUser.docs[0]['enabled'];

        if(enabled) {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          Navigator.pushNamed(context, DonorDashboard.id);
        }
        else{
          _accountDisabledDialog();

        }
      } else if (userType == 2) {
        //If user logging in is an organization user
        final organizationUser = await _firestore
            .collection('OrganizationUsers')
            .where('email', isEqualTo: email)
            .get();
        final approved = organizationUser.docs[0]['approved'];
        print('APPROVAL STATUS: $approved');
        if (approved) {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          Navigator.pushNamed(context, OrganizationDashboard.id);
        } else {
          _accountNotApprovedDialog();
        }
      } else {
        return _invalidCredentials();
      }
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      if (e.code == 'wrong-password') {
        _invalidCredentials();
      }
      if (e.code == 'user-not-found') {
        _invalidCredentials();
      }
    }
  }

  Future<void> _invalidCredentials() async {
    setState(() {
      showLoadingSpinner = false;
    });
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('hold_on_a_second!'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content:  Text(
                'cannot_log_in_with_that_email'.tr),
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


  Future<void> _accountNotApprovedDialog() async {
    setState(() {
      showLoadingSpinner = false;
    });
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('hang_on!'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content:  Text(
                'your_organizationaccount_has_not_yet_been_approved'.tr
                  ),
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

  Future<void> _accountDisabledDialog() async {
    setState(() {
      showLoadingSpinner = false;
    });
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('hang_on!'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content:  Text(
                'your_donor_account_has_been_disabled_by_the_administrator'.tr
                    ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text('login'.tr),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoadingSpinner,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(),
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
                  decoration: const InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (passwordreset) return null;
                    if (value!.isEmpty || value.length < 6) {
                      return "password_must_be_at_least_6_characters.".tr;
                    } else {
                      return null;
                    }
                  },
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Material(
                  elevation: 5.0,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32.0),
                  child: MaterialButton(
                    child: Text('login'.tr, style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      passwordreset = false;
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          showLoadingSpinner = true;
                        });
                        loginUser();
                      }
                    },
                  ),
                ),
              ),
              Center(
                  child: InkWell(
                    onTap: () async {
                      passwordreset = true;
                      // setState(() {});
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          showLoadingSpinner = true;
                        });
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        setState(() {
                          showLoadingSpinner = false;
                        });
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Center(child: Text('reset_link_sent!'.tr)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0)),
                                  content:
                                  Text('check_your_email_to_reset_password'.tr),
                                  actions: [
                                    Center(
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child:  Text('oK'.tr)))
                                  ]);
                            });
                      }
                    },
                    child: Text('forgot_password!'.tr,
                        style: TextStyle(color: Colors.black)),
                  )),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
