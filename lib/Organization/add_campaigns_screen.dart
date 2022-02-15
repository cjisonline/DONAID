import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AddCampaignForm extends StatefulWidget {

  static const id = 'campaign_form_screen';
  AddCampaignForm({Key? key}) : super(key: key);

  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final firestore = FirebaseFirestore.instance;

  initiliase() {
    _getCurrentUser();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  Future<void> create(String category,
      String description, int goalAmount,
      String title) async {
    try {
      await firestore.collection("CampaignsTest").add({
        'amountRaised': 0,
        'category': category,
        'dataCreated': FieldValue.serverTimestamp(),
        'description': description,
        'endDate': FieldValue.serverTimestamp(),
        'goalAmount': goalAmount,
        'organizationID': loggedInUser,
        'title' : title
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await firestore.collection("CampaignsTest").doc(id).delete();
    } catch (e) {
      print(e);
    }
  }


  Future<void> update(int amountRaised, String category,
      String description, Timestamp endDate, int goalAmount,
      String id, String title) async {
    try {
      await firestore
          .collection("CampaignsTest")
          .doc(id)
          .update(
          {'category': category,
            'dataCreated': FieldValue.serverTimestamp(),
            'description': description,
            'endDate': endDate,
            'goalAmount': goalAmount,
            'title' : title});
    } catch (e) {
      print(e);
    }
  }
  @override
  _AddCampaignFormState createState() => _AddCampaignFormState();
}


class _AddCampaignFormState extends State<AddCampaignForm> {
  TextEditingController categoryController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController endDateController = new TextEditingController();
  TextEditingController goalAmountController = new TextEditingController();
  TextEditingController titleController = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Campaign"),
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // widget.db.delete(widget.country["id"]);
                // Navigator.pop(context, true);
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: inputDecoration("Title"),
                controller: titleController,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: inputDecoration("Category"),
                controller: categoryController,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: inputDecoration("Description"),
                controller: descriptionController,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: inputDecoration("End Date"),
                controller: endDateController,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                style: TextStyle(color: Colors.black),
                decoration: inputDecoration("Goal Amount"),
                controller: goalAmountController,
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.transparent,
        child: BottomAppBar(
          color: Colors.transparent,
          child: RaisedButton(
              color: Colors.black,
              onPressed: () {
                widget.create(categoryController.text,descriptionController.text
                    , goalAmountController.hashCode, titleController.text);
                Navigator.pop(context, true);
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              )),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String labelText) {
    return InputDecoration(
      focusColor: Colors.black,
      labelStyle: TextStyle(color: Colors.black),
      labelText: labelText,
      fillColor: Colors.black,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
      ),
    );
  }
}