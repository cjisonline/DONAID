import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:get/get.dart';

import '../home_screen.dart';
import '../login_screen.dart';

class OrganizationRegistrationScreen extends StatefulWidget {
  static const id = 'organization_registration_screen';
  const OrganizationRegistrationScreen({Key? key}) : super(key: key);

  @override
  _OrganizationRegistrationScreenState createState() =>
      _OrganizationRegistrationScreenState();
}

class _OrganizationRegistrationScreenState
    extends State<OrganizationRegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _firebaseStorage = FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();

  static final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phoneNumberRegExp =
      RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');

  bool showLoadingSpinner = false;

  String organizationName = "";
  String email = "";
  String password = "";
  String passwordConfirm = "";
  String phoneNumber = "";
  String country = "";
  String gatewayLink = "";
  String organizationDescription = "";
  String street ="";
  String city="";
  String postalCode="";

  XFile? _image;
  String _uploadedFileURL = "";
  final ImagePicker _imagePicker = ImagePicker();

  Future<bool> isEmailAvailable() async {
    //This method checks to make sure the email is not already being used in Firebase
    final list = await _auth.fetchSignInMethodsForEmail(email);

    if (list.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void createNewOrganizationUser() async {
    //This method creates the new user in Firebase and uploads verification docs
    if (await isEmailAvailable()) {
      //If the email is available
      try {
        dynamic newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        if (newUser != null) {
          await uploadFile(newUser);

          final docRef = await _firestore.collection('OrganizationUsers').add({});

          await _firestore.collection('OrganizationUsers').doc(docRef.id).set({
            'id':docRef.id,
            'uid': newUser.user.uid,
            'organizationName': organizationName,
            'organizationDescription': organizationDescription,
            'email': email,
            'phoneNumber': phoneNumber,
            'address':{'street':street,'city':city,'postalCode':postalCode},
            'approved': false,
            'country': country,
            'gatewayLink': gatewayLink,
            'verificationDocumentURL': _uploadedFileURL,
            'profilePictureDownloadURL':''
          });

          final usersDocRef = await _firestore.collection('Users').add({});
          await _firestore
              .collection('Users')
              .doc(usersDocRef.id)
              .set({'id': usersDocRef.id,'uid': newUser.user.uid, 'email': email, 'userType': 2});

          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen
              .id)); //remove all screens on the stack and return to home screen
          Navigator.pushNamed(
              context, LoginScreen.id); //redirect to login screen
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

  Future<void> _imageRequiredDialog() async {
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
                'organizations_are_required_to_upload'.tr),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text('oK'.tr),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _countryRequiredDialog() async {
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
                'organizations_are_Required_to_specify'.tr),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text('oK'.tr),
                ),
              ),
            ],
          );
        });
  }

  Future chooseFile() async {
    await _imagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future uploadFile(dynamic newUser) async {
    File file = File(_image!.path);

    final storageReference = _firebaseStorage
        .ref()
        .child('verificationDocuments/')
        .child('${newUser.user.uid}-${Path.basename(file.path)}');

    await storageReference.putFile(file);
    var fileURL = await storageReference.getDownloadURL();
    _uploadedFileURL = fileURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('organization_registration'.tr),
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
                    maxLength: 50,
                    onChanged: (value) {
                      organizationName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "please_enter_your_organization_name.".tr;
                      } else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'organization_name'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 20.0),
                                  children: const [
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
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    minLines: 2,
                    maxLines: 5,
                    maxLength: 240,
                    onChanged: (value) {
                      organizationDescription = value;
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'organization_description'.tr,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 20.0),
                            ),
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
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
                        return "please_enter_a_valid_email_address".tr;
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'email'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 20.0),
                                  children: const [
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
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
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
                      if(value!.isEmpty){
                        return "please_enter_a_phone_number.".tr;
                      }
                      if (value.isNotEmpty && !phoneNumberRegExp.hasMatch(value)) {
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
                              text: TextSpan(
                                  text: 'phone_number'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 20.0),
                                  children: const [
                                    TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ]
                                  )),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 24.0,8.0 , 8.0),
                  child: TextFormField(
                    onChanged: (value) {
                      street = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "please_provide_street_address.".tr;
                      } else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'street_address'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 20.0),
                                  children: const[
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
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0,8.0 , 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 195,
                        child: TextFormField(
                          onChanged: (value) {
                            city=value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "please_provide_city.".tr;
                            } else {
                              return null;
                            }
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              label: Center(
                                child: RichText(
                                    text: TextSpan(
                                        text: 'city'.tr,
                                        style: TextStyle(
                                            color: Colors.grey[600], fontSize: 20.0),
                                        children: const[
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
                                borderRadius: BorderRadius.all(Radius.circular(32.0)),
                              )),
                        ),
                      ),
                      Container(
                        width: 195,
                        child: TextFormField(
                          onChanged: (value) {
                            postalCode=value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "please_provide_postal_code.".tr;
                            } else {
                              return null;
                            }
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              label: Center(
                                child: RichText(
                                    text: TextSpan(
                                        text: 'postal_code'.tr,
                                        style: TextStyle(
                                            color: Colors.grey[600], fontSize: 20.0),
                                        children: const[
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
                                borderRadius: BorderRadius.all(Radius.circular(32.0)),
                              )),
                        ),
                      ),
                    ],
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
                              text: TextSpan(
                                  text: 'password'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 20.0),
                                  children: const[
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
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
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
                              text: TextSpan(
                                  text: 'confirm_password'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 20.0),
                                  children: const [
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
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onChanged: (value) {
                      gatewayLink = value;
                    },
                    validator: (value) {
                      if (country != 'United States' && value == '') {
                        return "countries_not_based_in_the_united_states".tr;
                      } else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration:  InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'link_to_payment_gateway'.tr,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 20.0),
                                  )),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      showCountryPicker(
                          context: context,
                          onSelect: (Country selectedCountry) {
                            country = selectedCountry.name;
                          });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        Icon(Icons.flag),
                        Text('select_country'.tr),
                        Text(' *', style: TextStyle(color: Colors.red),)
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () async {
                      chooseFile();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        Icon(Icons.upload),
                        Text('upload_document_to_verify'.tr),
                        Text(' *', style: TextStyle(color: Colors.red),)
                      ],
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
                        if (_image == null) {
                          setState(() {
                            showLoadingSpinner = true;
                          });
                          _imageRequiredDialog();
                        } else if (country == '') {
                          setState(() {
                            showLoadingSpinner = true;
                          });
                          _countryRequiredDialog();
                        } else {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              showLoadingSpinner = true;
                            });

                            createNewOrganizationUser();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
