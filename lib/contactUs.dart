import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/donor_bottom_navigation_bar.dart';
import 'package:donaid/Donor/DonorWidgets/donor_drawer.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Organization/organization_dashboard.dart';

class ContactUs extends StatefulWidget {
  String type;
  ContactUs(this.type);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  bool cSub = false, cEmail = false, cMess = false;
  Donor donor = Donor.c1();
  TextEditingController subject = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController message = TextEditingController();
  TextEditingController messageType = TextEditingController();

  List<String> categoryOptions = [
    "Question",
    "Suggestion",
    "Help",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    var ret = await _firestore
        .collection(widget.type)
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? "")
        .get();
    final doc = ret.docs[0];
    email.text = doc['email'];
    setState(() {});
  }

  _sendMessage() async{
    var docRef = await _firestore.collection('AdminMessages').add({});

    await _firestore.collection('AdminMessages').doc(docRef.id).set(
      {
        "email": email.text,
        "subject": subject.text,
        "category": messageType.text,
        "userType": widget.type,
        "message": message.text,
        "ContactTime": DateTime.now(),
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "read":false,
        "id":docRef.id
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Contact Us".tr)),
        backgroundColor: Colors.white,
        body: widget.type == "DonorUsers" ? _buildDonorBody() : _buildOrganizationBody(),
      drawer: widget.type == "DonorUsers" ? DonorDrawer() : OrganizationDrawer(),
      bottomNavigationBar: widget.type =='DonorUsers' ? DonorBottomNavigationBar() : OrganizationBottomNavigation(),
    );
  }

  _buildDonorBody(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                      label: Center(
                        child: Text('category'.tr, style: TextStyle(color: Colors.black, fontSize: 20),)),
                      border: const OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(12.0)),
                      )),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items:categoryOptions.map((items) {
                    return DropdownMenuItem<String>(
                      child: Text(items),
                      value: items,
                    );
                  }).toList(),
                  onChanged: (val) => setState(() {
                    messageType.text = val.toString();
                  }),
                  validator: (value){
                    if(messageType.text.isEmpty){
                      return 'Please select a category.';
                    }
                    else{
                      return null;
                    }
                  },
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  onChanged: (value){
                    subject.text = value;
                  },
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please enter valid subject.';
                    }
                    else {
                      return null;
                    }
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      label: Center(
                        child: RichText(
                            text:  TextSpan(
                                text: 'Subject',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20.0),
                                children: [
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  minLines: 2,
                  maxLength: 240,
                  maxLines: 5,
                  onChanged: (value){
                    message.text = value;
                  },
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please enter valid message.';
                    }
                    else {
                      return null;
                    }
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      label: Center(
                        child: RichText(
                            text:  TextSpan(
                                text: 'Message',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20.0),
                                children: [
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
                  padding: const EdgeInsets.only(top: 40),
                  child: Material(
                      elevation: 5.0,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                          child: Text('Send',
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white)),
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              await _sendMessage();
                            ScaffoldMessenger.of(context)
                                .showSnackBar( SnackBar(content: Text('Message sent!'.tr)));
                            Navigator.popUntil(context, ModalRoute.withName(DonorDashboard.id));
                            }
                          }
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildOrganizationBody(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                        label: Center(
                            child: Text('category'.tr, style: TextStyle(color: Colors.black, fontSize: 20),)),
                        border: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12.0)),
                        )),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items:categoryOptions.map((items) {
                      return DropdownMenuItem<String>(
                        child: Text(items),
                        value: items,
                      );
                    }).toList(),
                    onChanged: (val) => setState(() {
                      messageType.text = val.toString();
                    }),
                    validator: (value){
                      if(messageType.text.isEmpty){
                        return 'Please select a category.';
                      }
                      else{
                        return null;
                      }
                    },
                  )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  onChanged: (value){
                    subject.text = value;
                  },
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please enter valid subject.';
                    }
                    else {
                      return null;
                    }
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      label: Center(
                        child: RichText(
                            text:  TextSpan(
                                text: 'Subject',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20.0),
                                children: [
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  minLines: 2,
                  maxLength: 240,
                  maxLines: 5,
                  onChanged: (value){
                    message.text = value;
                  },
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please enter valid message.';
                    }
                    else {
                      return null;
                    }
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      label: Center(
                        child: RichText(
                            text:  TextSpan(
                                text: 'Message',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20.0),
                                children: [
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
                  padding: const EdgeInsets.only(top: 40),
                  child: Material(
                      elevation: 5.0,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                          child: Text('Send',
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white)),
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              await _sendMessage();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar( SnackBar(content: Text('Message sent!'.tr)));
                              Navigator.popUntil(context, ModalRoute.withName(OrganizationDashboard.id));
                            }
                          }
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

}
