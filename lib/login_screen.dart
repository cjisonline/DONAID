import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'donor_dashboard.dart';
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

  final _formKey = GlobalKey<FormState>();
  
  static final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  String email="";
  String password="";
  bool showLoadingSpinner = false;
  int userType=-1; // 1 indicates donor user, 2 indicates organization user

  Future<int> getUserType() async{
    final user = await _firestore.collection('Users').where('email', isEqualTo: email).get();
    final userType = user.docs[0]['userType'];
    print('USERTYPE: $userType');
    return userType;
  }
  void loginUser() async{
    //TODO: Handle if the user does not exist or credentials do not match
    final userType = await getUserType();

    try{
      if(userType == 1) { //If user logging in is a donor user
        final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
        Navigator.pushNamed(context, DonorDashboard.id);
      }
      else if(userType == 2){ //If user logging in is an organization user
        final organizationUser = await _firestore.collection('OrganizationUsers').where('email', isEqualTo: email).get();
        final approved = organizationUser.docs[0]['approved'];
        print('APPROVAL STATUS: $approved');
        if(approved == true){
          //TODO: Navigate to organization dashboard
        }
        else{
          _accountNotApprovedDialog();
        }
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _accountNotApprovedDialog() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('Login'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoadingSpinner,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (value){
                    email = value;
                  },
                  validator: (value){
                    if(value!.isEmpty){
                      return "Please enter your email.";
                    }
                    else if(!emailRegExp.hasMatch(value)){
                      return "Please enter a valid email address.";
                    }
                    else{
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (value){
                    password = value;
                  },
                  validator: (value){
                    if(value!.isEmpty || value.length < 6){
                      return "Password must be at least 6 characters.";
                    }
                    else {
                      return null;
                    }
                  },
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Material(
                  elevation: 5.0,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32.0),
                  child: MaterialButton(
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async{
                      if(_formKey.currentState!.validate()) {
                        setState(() {
                          showLoadingSpinner=true;
                        });

                       loginUser();

                        setState(() {
                          showLoadingSpinner=false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
