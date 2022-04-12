import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'donor_profile.dart';
// Donor edit profile form
class DonorEditProfile extends StatefulWidget {
  static const id = 'donor_edit_profile';

  const DonorEditProfile({Key? key}) : super(key: key);

  @override
  _DonorEditProfileState createState() => _DonorEditProfileState();
}

class _DonorEditProfileState extends State<DonorEditProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  Donor donor = Donor.c1();
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _phoneNumberController;

  static final phoneNumberRegExp =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getDonorInformation();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  // Get current donor user's information from Firebase
  _getDonorInformation() async {
    var ret = await _firestore
        .collection('DonorUsers')
        .where('uid', isEqualTo: loggedInUser?.uid)
        .get();
    final doc = ret.docs[0];
    donor = Donor(
        email: doc['email'],
        firstName: doc['firstName'],
        lastName: doc['lastName'],
        phoneNumber: doc['phoneNumber'],
        id: doc['id']
    );
    setState(() {});
  }

  // Update current donor user's information in Firebase
  _updateDonorInformation() async {
    _firestore.collection('DonorUsers').doc(donor.id).update({
      "firstName": _firstNameController?.text,
      "lastName": _lastNameController?.text,
      "phoneNumber": _phoneNumberController?.text
    });
  }

  // Display edit profile page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title:  Text('edit_profile'.tr),
          leadingWidth: 80,
          // Display cancel button in top app bar
          // On pressed, navigate to the profile page
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child:  Text('cancel'.tr,
                style: TextStyle(fontSize: 15.0, color: Colors.white)),
          ),
          actions: [
            // Display save button in top app bar
            // On pressed, submit edit profile form
            TextButton(
              onPressed: () {
                _submitForm();
              },
              child:  Text('save'.tr,
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          ]),
      body: _body(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Create first name text field and prepopulate donor's first name
  Widget _buildFirstNameField() {
    _firstNameController = TextEditingController(text: donor.firstName);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _firstNameController,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                  text:  TextSpan(
                    text: 'first_name'.tr,
                    style: TextStyle(
                        color: Colors.black, fontSize: 20.0),
                  ),
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              )),
          // Show error message if text field is left blank
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_first_name.'.tr;
            }
            return null;
          },
        ));
  }

  // Create last name text field and prepopulate donor's last name
  Widget _buildLastNameField() {
    _lastNameController = TextEditingController(text: donor.lastName);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _lastNameController,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                  text:  TextSpan(
                    text: 'last_name'.tr,
                    style: TextStyle(
                        color: Colors.black, fontSize: 20.0),
                  ),
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              )),
          // Show error message if text field is left blank
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_last_name.'.tr;
            }
            return null;
          },
        ));
  }

  // Create phone number text field and prepopulate donor's phone number
  Widget _buildPhoneNumberField() {
    _phoneNumberController = TextEditingController(text: donor.phoneNumber);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _phoneNumberController,
          decoration: InputDecoration(
              label: Center(
                child: RichText(
                  text:  TextSpan(
                    text: 'phone_number'.tr,
                    style: TextStyle(
                        color: Colors.black, fontSize: 20.0),
                  ),
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              )),
          validator: (value) {
            // Show error message if text field is left blank
            if (value!.isEmpty) {
              return "please_enter_your_phone_number.".tr;
            }
            // Show error message if phone number input does not follow correct phone number format
            else if (!phoneNumberRegExp.hasMatch(value)) {
              return "please_enter_a_valid_phone_number.".tr;
            } else {
              return null;
            }
          },
        ));
  }

  // Submit and validate from
  _submitForm() async {
    // Information inputted in the form is invalid
    // Show errors
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Information inputted in the form is valid
    // Update donor's information and navigate to profile page
    else{
      await _updateDonorInformation();
      Navigator.pop(context,true);
    }
    _formKey.currentState!.save();
  }

  // Display edit profile form
  _body() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildFirstNameField(),
              _buildLastNameField(),
              _buildPhoneNumberField(),
            ],
          ),
        ),
      ),
    );
  }


}
