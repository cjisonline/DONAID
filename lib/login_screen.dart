import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Donor/donor_dashboard.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userType = await getUserType();
      if (userType == 1) {
        //If user logging in is a donor user
        final donorUser = await _firestore.collection('DonorUsers').where('email', isEqualTo: email).get();
        final enabled = donorUser.docs[0]['enabled'];

        if(enabled) {
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
            title: const Center(
              child: Text('Hold on a second!'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'Cannot log in with that email and password. Please enter valid credentials.'),
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


  Future<void> _accountNotApprovedDialog() async {
    setState(() {
      showLoadingSpinner = false;
    });
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text('Hang on!'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'Your organization account has not yet been approved by the admin. You must wait for '
                    'approval before you can login to this account.'),
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

  Future<void> _accountDisabledDialog() async {
    setState(() {
      showLoadingSpinner = false;
    });
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text('Hang on!'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'Your donor account has been disabled by the administrator. If you think this may have been a mistake,'
                    'please send an email to donaidmobileapp1@gmail.com'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Login'),
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
                      return "Please enter your email.";
                    } else if (!emailRegExp.hasMatch(value)) {
                      return "Please enter a valid email address.";
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
                      return "Password must be at least 6 characters.";
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
                    child: Text('Login', style: TextStyle(color: Colors.white)),
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
                                  title: Center(child: Text('Reset Link Sent!')),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0)),
                                  content:
                                  Text('Check Your Email to Reset Password'),
                                  actions: [
                                    Center(
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK')))
                                  ]);
                            });
                      }
                    },
                    child: Text('Forgot Password?',
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
