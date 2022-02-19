import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Organization/organization_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrganizationEditProfile extends StatefulWidget {
  static const id = 'organization_edit_profile';

  const OrganizationEditProfile({Key? key}) : super(key: key);

  @override
  _OrganizationEditProfileState createState() => _OrganizationEditProfileState();
}

class _OrganizationEditProfileState extends State<OrganizationEditProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  Organization? organization;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  TextEditingController? _organizationNameController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _organizationDescriptionController;
  TextEditingController? _countryController;
  TextEditingController? _gatewayLinkController;

  static final phoneNumberRegExp =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getOrganizationInformation();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getOrganizationInformation() async {
    var ret = await _firestore.collection('OrganizationUsers').where('uid', isEqualTo: loggedInUser?.uid).get();
    final doc = ret.docs[0];
    organization = Organization(
        organizationEmail: doc['email'],
        organizationName: doc['organizationName'],
        password: doc['password'],
        phoneNumber: doc['phoneNumber'],
        uid: doc['uid'],
        organizationDescription: doc['organizationDescription'],
        country: doc['country'],
        gatewayLink: doc['gatewayLink']
    );
    print('country:${organization?.country}x');
    print('get org');
    setState(() {});
  }

  // organizationEmail: doc['email'],
  // organizationName: doc['organizationName'],
  // password: doc['password'],
  // phoneNumber: doc['phoneNumber'],
  // uid: doc['uid'],
  // organizationDescription: doc['organizationDescription'],
  // country: doc['country'],
  // gatewayLink: doc['gatewayLink']

  _updateOrganizationInformation() async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('uid', isEqualTo: loggedInUser?.uid)
        .get();
    final doc = ret.docs[0];
    _firestore.collection('OrganizationUsers').doc(doc.id).update({
      "organizationName": organization?.organizationName,
      "password": organization?.password,
      "phoneNumber": organization?.phoneNumber,
      "organizationDescription": organization?.organizationDescription,
      "country": organization?.country,
      "gatewayLink": organization?.gatewayLink
    }).whenComplete(_goToProfilePage);
  }
  _goToProfilePage(){
    Navigator.pushNamed(context, OrganizationProfile.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Edit Profile'),
          leadingWidth: 80,
          leading: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, OrganizationProfile.id);
              },
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          actions: [
            TextButton(
              onPressed: () {
                _submitForm();
                _updateOrganizationInformation();
              },
              child: const Text('Save',
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          ]),
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }
  //
  //
  // Widget _buildFirstNameField() {
  //   _organizationNameController = TextEditingController(text: donor.firstName);
  //   return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //   child: TextFormField(
  //     controller: _organizationNameController,
  //     decoration: const InputDecoration(
  //       labelText: 'First Name',
  //         border: OutlineInputBorder(
  //           borderRadius:
  //           BorderRadius.all(Radius.circular(32.0)),
  //         )
  //     ),
  //     validator: (value) {
  //       if (value == null || value.isEmpty) {
  //         return 'Please enter first name.';
  //       }
  //       return null;
  //     },
  //     onSaved: (value) {
  //       donor.firstName = value!;
  //     },
  //
  //   ));
  // }
  //
  // Widget _buildLastNameField() {
  //   _organizationDescriptionController = TextEditingController(text: donor.lastName);
  //   return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //   child: TextFormField(
  //     controller: _organizationDescriptionController,
  //     decoration: const InputDecoration(
  //       labelText: 'Last Name',
  //         border: OutlineInputBorder(
  //           borderRadius:
  //           BorderRadius.all(Radius.circular(32.0)),
  //         )
  //     ),
  //     validator: (value) {
  //       if (value == null || value.isEmpty) {
  //         return 'Please enter last name.';
  //       }
  //       return null;
  //     },
  //     onSaved: (value) {
  //       donor.lastName = value!;
  //     },
  //   ));
  // }
  //
  // Widget _buildPasswordField() {
  //   _passwordController = TextEditingController(text: donor.password);
  //   return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //   child:TextFormField(
  //     controller: _passwordController,
  //     decoration: const InputDecoration(labelText: 'Password',
  //         border: OutlineInputBorder(
  //           borderRadius:
  //           BorderRadius.all(Radius.circular(32.0)),
  //         )),
  //     validator: (value) {
  //       if (value!.isEmpty || value.length < 6) {
  //         return "Password must be at least 6 characters.";
  //       } else {
  //         return null;
  //       }
  //     },
  //     obscureText: true,
  //     onSaved: (value) {
  //       donor.password = value!;
  //     },
  //   ));
  // }
  //
  // Widget _buildConfirmPasswordField() {
  //   _confirmPasswordController = TextEditingController(text: donor.password);
  //   return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //   child: TextFormField(
  //     controller: _confirmPasswordController,
  //     decoration: const InputDecoration(labelText: 'Confirm Password',
  //         border: OutlineInputBorder(
  //           borderRadius:
  //           BorderRadius.all(Radius.circular(32.0)),
  //         )),
  //     validator: (value) {
  //       if (value!.isEmpty || value.length < 6) {
  //         return "Password must be at least 6 characters.";
  //       } else if (value != _passwordController?.text) {
  //         return "Passwords do not match";
  //       } else {
  //         return null;
  //       }
  //     },
  //     obscureText: true,
  //   ));
  // }
  //
  // Widget _buildPhoneNumberField() {
  //   _phoneNumberController = TextEditingController(text: donor.phoneNumber);
  //   return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //   child: TextFormField(
  //     controller: _phoneNumberController,
  //     decoration: const InputDecoration(
  //       labelText: 'Phone number',
  //         border: OutlineInputBorder(
  //           borderRadius:
  //           BorderRadius.all(Radius.circular(32.0)),
  //         )
  //     ),
  //     validator: (value) {
  //       if (value!.isEmpty) {
  //         return "Please enter your phone number.";
  //       } else if (!phoneNumberRegExp.hasMatch(value)) {
  //         return "Please enter a valid phone number.";
  //       } else {
  //         return null;
  //       }
  //     },
  //     onSaved: (value) {
  //       donor.phoneNumber = value!;
  //     },
  //   ));
  // }

  _submitForm(){
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
  }

  _body() {
    return SingleChildScrollView(
      child: Container(
      // decoration: BoxDecoration(
      // color: Colors.blueGrey.shade50,),
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // _buildFirstNameField(),
              // _buildLastNameField(),
              // _buildPasswordField(),
              // _buildConfirmPasswordField(),
              // _buildPhoneNumberField(),
            ],
          ),
        ),
      ),
    );
  }

  _bottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.pushNamed(context, DonorDashboard.id);
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 35),
            ),
            const Text('Home',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 35,
              ),
            ),
            const Text('Search',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 35),
            ),
            const Text('Notifications',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.message, color: Colors.white, size: 35),
            ),
            const Text('Messages',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ],
      ),
    );
  }
}
