import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

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
          await _firestore.collection('OrganizationUsers').add({
            'uid': newUser.user.uid,
            'organizationName': organizationName,
            'organizationDescription': organizationDescription,
            'email': email,
            'phoneNumber': phoneNumber,
            'password': password,
            'approved': false,
            'country': country,
            'gatewayLink': gatewayLink,
            'verificationDocumentURL': _uploadedFileURL
          });

          await _firestore
              .collection('Users')
              .add({'uid': newUser.user.uid, 'email': email, 'userType': 2});

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

  Future<void> _imageRequiredDialog() async {
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
                'Organizations are required to upload images of documents to verify their organization.'),
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

  Future<void> _countryRequiredDialog() async {
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
                'Organizations are required to specify the country that their organization is based in.'),
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
        title: const Text('Organization Registration'),
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
                    maxLength: 50,
                    onChanged: (value) {
                      organizationName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your organization name.";
                      } else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'Organization Name',
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
                              text: 'Organization Description',
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
                              text: TextSpan(
                                  text: 'Email',
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
                        return "Please enter a phone number.";
                      }
                      if (value!.isNotEmpty && !phoneNumberRegExp.hasMatch(value)) {
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
                              text: TextSpan(
                                  text: 'Phone Number',
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
                              text: TextSpan(
                                  text: 'Password',
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
                              text: TextSpan(
                                  text: 'Confirm Password',
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
                        return "Countries not based in the United States must provide their own\n gateway.";
                      } else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration:  InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'Link to Payment Gateway',
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
                      children: const [
                        Icon(Icons.flag),
                        Text('Select Country'),
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
                      children: const [
                        Icon(Icons.upload),
                        Text('Upload document to verify organization.'),
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
                      child: const Text(
                        'Register',
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
