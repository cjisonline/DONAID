
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'OrganizationWidget/popup_dialog_success.dart';

class AddAdoptionForm extends StatefulWidget {
  static const id = 'add_adoption_form';
  AddAdoptionForm({Key? key}) : super(key: key);

  @override
  _AddAdoptionFormState createState() => _AddAdoptionFormState();
}

class _AddAdoptionFormState extends State<AddAdoptionForm> {
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController adoptionCostController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool showLoadingSpinner = false;
  final _formKey = GlobalKey<FormState>();
  static final adoptionCostRegExp = RegExp(
      r"^(?!0\.00)\d{1,13}(,\d{3})*(\.\d\d)?$"
  );
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final firestore = FirebaseFirestore.instance;
  late DocumentSnapshot documentSnapshot;
  var category = [];
  int beneficiaryTimeLimit=0;


  _getCharityCategories() async {
    var ret = await firestore
        .collection('CharityCategories')
        .get();
    ret.docs.forEach((element) {
      category.add(element.data()['name']);
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getCharityCategories();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }


  Future<void> addAdoption(String category, String description, double adoptionCost,
      String name) async {
    try {
      final docRef = await firestore.collection("Adoptions").add({});

      await firestore.collection("Adoptions").doc(docRef.id).set({
        'active': true,
        'category': category,
        'dateCreated': FieldValue.serverTimestamp(),
        'description': description,
        'adoptionCost': adoptionCost,
        'id': docRef.id,
        'organizationID': loggedInUser?.uid,
        'name': name
      });
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DONAID"),
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
                    'Add Adoption',
                    style: TextStyle(fontSize: 32.0),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 25.0),
                  child: Text(
                    '* - required fields',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLength: 50,
                    controller: nameController,
                    inputFormatters: [
                      new LengthLimitingTextInputFormatter(50)
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a name.";
                      } else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'Name',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 20.0),
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
                          borderRadius:
                          BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    minLines: 2,
                    maxLines: 5,
                    maxLength: 240,
                    controller: descriptionController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a description.";
                      } else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: 'Description',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 20.0),
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
                          borderRadius:
                          BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: adoptionCostController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter an adoption cost.";
                      } else if (!adoptionCostRegExp.hasMatch(value)) {
                        return "Please enter a valid adoption cost.";
                      }
                      else {
                        return null;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        label: Center(
                          child: RichText(
                              text: TextSpan(
                                  text: '\u0024 Adoption Cost',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 20.0),
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
                          borderRadius:
                          BorderRadius.all(Radius.circular(32.0)),
                        )),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField <String>(
                        decoration: InputDecoration(
                            label: Center(
                              child: RichText(
                                  text: TextSpan(
                                      text: 'Category',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 20.0),
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
                              borderRadius:
                              BorderRadius.all(Radius.circular(32.0)),
                            )),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: category == null ? [] : category.map((
                        items) {
                return DropdownMenuItem<String>(
                child: Text(items),
                value: items,
                );
                }).toList(),
                onChanged: (val) =>
                    setState(() {
                      categoryController.text = val.toString();
                    }),
                validator: (value) =>
                value == null
                    ? 'Please fill in the category.' : null,
              )
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
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      showLoadingSpinner = true;
                    });
                    addAdoption(categoryController.text,
                        descriptionController.text,
                        int.parse(adoptionCostController.text).toDouble(),
                        nameController.text);
                    Navigator.pop(context, true);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          const PopUpSuccessDialog(),
                    );
                  }
                },
              ),
            ),
          ),

          ]),
    )
    )
    )
    );
  }
}