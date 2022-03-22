import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUs extends StatefulWidget {
  String type;
  ContactUs(this.type);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ContactUs> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool cSub = false, cEmail = false, cMess = false;
  final _firestore = FirebaseFirestore.instance;
  Donor donor = Donor.c1();
  TextEditingController sub = TextEditingController(),
      email = TextEditingController(),
      message = TextEditingController();
  String type = "Question";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: const Text("Contact Us")),
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              Text("Subject",
                  textAlign: TextAlign.left,
                  style:
                      GoogleFonts.openSans(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400)),
                  child: TextField(
                      controller: sub,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 5, right: 15)))),
              if (cSub) const SizedBox(height: 5),
              if (cSub)
                Text("Enter Subject to process",
                    textAlign: TextAlign.left,
                    style:
                        GoogleFonts.openSans(fontSize: 10, color: Colors.red)),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              Text("Select Categories",
                  textAlign: TextAlign.left,
                  style:
                      GoogleFonts.openSans(fontSize: 12, color: Colors.grey)),
              DropdownButton(
                value: type,
                items: const [
                  DropdownMenuItem(
                    child: Text("Question"),
                    value: "Question",
                  ),
                  DropdownMenuItem(
                    child: Text("Suggestion"),
                    value: "Suggestion",
                  ),
                  DropdownMenuItem(
                    child: Text("Help"),
                    value: "Help",
                  ),
                  DropdownMenuItem(
                    child: Text("Other"),
                    value: "Other",
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    type = value.toString();
                  });
                },
              ),
              if (cEmail) const SizedBox(height: 5),
              if (cEmail)
                Text("Enter Email to process",
                    textAlign: TextAlign.left,
                    style:
                        GoogleFonts.openSans(fontSize: 10, color: Colors.red)),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              Text("message".tr,
                  textAlign: TextAlign.left,
                  style:
                      GoogleFonts.openSans(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                  height: 90,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400)),
                  child: TextField(
                      controller: message,maxLines :3,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15)))),
              if (cMess) const SizedBox(height: 5),
              if (cMess)
                Text(
                  "Enter Message to process",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.openSans(fontSize: 10, color: Colors.red),
                ),
              InkWell(
                  onTap: () async {
                    if (email.text == "")
                      cEmail = true;
                    else
                      cEmail = false;
                    if (sub.text == "")
                      cSub = true;
                    else
                      cSub = false;
                    if (message.text == "")
                      cMess = true;
                    else
                      cMess = false;
                    setState(() {});
                    if (email.text == "" ||
                        sub.text == "" ||
                        message.text == "") return;
                    FirebaseFirestore.instance.collection('AdminMessages').add({
                      "email": email.text,
                      "subject": sub.text,
                      "category": type,
                      "userType": widget.type,
                      "message": message.text,
                      "ContactTime": DateTime.now(),
                      "userId": FirebaseAuth.instance.currentUser?.uid ?? ""
                    });
                    await EasyLoading.showInfo(
                        "We receive you request, we contact you back on your email",
                        duration: const Duration(seconds: 5));
                    Get.back();
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                          height: 40,
                          width: 90,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.blue]),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400)),
                          child: Center(
                              child: Text("Send",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                      fontSize: 13))))))
            ])));
  }
}
