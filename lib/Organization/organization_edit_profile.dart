import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
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
  Organization organization = Organization.c1();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController? _organizationNameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _organizationDescriptionController;
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
        phoneNumber: doc['phoneNumber'],
        uid: doc['uid'],
        organizationDescription: doc['organizationDescription'],
        country: doc['country'],
        gatewayLink: doc['gatewayLink'],
        id: doc["id"]
    );
    setState(() {});
  }

  _updateOrganizationInformation() async {
    _firestore.collection('OrganizationUsers').doc(organization.id).update({
      "organizationName": organization.organizationName,
      "phoneNumber": organization.phoneNumber,
      "organizationDescription": organization.organizationDescription,
      "gatewayLink": organization.gatewayLink
    });
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
                Navigator.pop(context);
              },
              child: const Text('Save',
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          ]),
      body: _body(),
      bottomNavigationBar: OrganizationBottomNavigation(),
    );
  }



  Widget _buildOrganizationNameField() {
    _organizationNameController = TextEditingController(text: organization.organizationName);
    return Padding(
        padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: _organizationNameController,
      decoration: InputDecoration(
          label: Center(
            child: RichText(
              text: const TextSpan(
                text: 'Name',
                style: TextStyle(
                    color: Colors.black, fontSize: 20.0),
              ),
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          )),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter organization\'s name.';
        }
        return null;
      },
      onSaved: (value) {
        organization.organizationName = value!;
      },
    ));
  }

  Widget _buildPhoneNumberField() {
    _phoneNumberController = TextEditingController(text: organization.phoneNumber);
    return Padding(
        padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: _phoneNumberController,
      decoration: InputDecoration(
          label: Center(
            child: RichText(
              text: const TextSpan(
                text: 'Phone Number',
                style: TextStyle(
                    color: Colors.black, fontSize: 20.0),
              ),
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          )),
      validator: (value) {
        if (value!.isEmpty) {
          return "Please enter your phone number.";
        } else if (!phoneNumberRegExp.hasMatch(value)) {
          return "Please enter a valid phone number.";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        organization.phoneNumber = value!;
      },
    ));
  }


  Widget _buildOrganizationDescriptionField() {
    _organizationDescriptionController = TextEditingController(text: organization.organizationDescription);
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _organizationDescriptionController,
        minLines: 2,
        maxLines: 5,
        maxLength: 240,
        onSaved: (value) {
          organization.organizationDescription = value;
        },
        decoration: InputDecoration(
            label: Center(
              child: RichText(
                text: const TextSpan(
                  text: 'Organization Description',
                  style: TextStyle(
                      color: Colors.black, fontSize: 20.0),
                ),
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            )),
      ),
    );
  }

  Widget _buildGatewayLinkField() {
    _gatewayLinkController = TextEditingController(text: organization.gatewayLink);
    if(organization.country != "United States") {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _gatewayLinkController,
            decoration: InputDecoration(
                label: Center(
                  child: RichText(
                    text: const TextSpan(
                      text: 'Gateway Link',
                      style: TextStyle(
                          color: Colors.black, fontSize: 20.0),
                    ),
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                )),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter gateway link.';
              }
              return null;
            },
            onSaved: (value) {
              organization.gatewayLink = value!;
            },
          ));
    }
    else{
      return Container();
    }
  }

  _submitForm(){
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
  }
  Widget _buildUnitedStatesEditProfile(){
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildOrganizationNameField(),
              _buildPhoneNumberField(),
              _buildOrganizationDescriptionField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutsideUnitedStatesEditProfile(){
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildOrganizationNameField(),
              _buildPhoneNumberField(),
              _buildOrganizationDescriptionField(),
              _buildGatewayLinkField()
            ],
          ),
        ),
      ),
    );
  }

  _body() {
    if(organization.country == 'United States'){
      return _buildUnitedStatesEditProfile();
    }
    else{
      return _buildOutsideUnitedStatesEditProfile();
    }
  }

}
