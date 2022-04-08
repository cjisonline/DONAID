import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/message.dart';
import 'package:donaid/Organization/gateway_visits.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:donaid/contactUs.dart';
import 'package:donaid/Organization/settings.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:donaid/Organization/organization_expiredcharities_screen.dart';
import 'package:donaid/Organization/organization_inactivecharities_screen.dart';
import 'package:donaid/Organization/pending_approvals_and_denials.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart';

import '../../home_screen.dart';
import '../organization_profile.dart';
// Organization drawar
class OrganizationDrawer extends StatefulWidget {
  const OrganizationDrawer({Key? key}) : super(key: key);

  @override
  _OrganizationDrawerState createState() => _OrganizationDrawerState();
}

class _OrganizationDrawerState extends State<OrganizationDrawer> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String country = "";
  String organizationName = "";
  String profilePictureDownloadURL = "";

  @override
  void initState() {
    super.initState();
    _getOrg();
  }
  // Display organization name from Firebase
  _getOrg() async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('uid', isEqualTo: _auth.currentUser!.uid)
        .get();
    var doc = ret.docs.first;
    country = doc.data()['country'];
    organizationName = doc.data()['organizationName'];
    profilePictureDownloadURL = doc.data()['profilePictureDownloadURL'];
    setState(() {});
  }
// //Distinguish between foreign and us organization
  @override
  Widget build(BuildContext context) {
    return country == "United States"
        ? _buildUSDrawer()
        : _buildForeignDrawer();
  }
// US drawer
  _buildUSDrawer() {
    return Container(
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Stack(
                children: [
                  // US org display name in drawer
                  Positioned(
                    bottom: 8.0,
                    left: 4.0,
                    child: Text(
                      organizationName,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            // US org display setting option in drawer
            // On press Navigate to the settings page
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("settings".tr),
              onTap: () {
                Navigator.pushNamed(context, OrganizationSettingsPage.id);
              },
            ),
            // US org display profile option in drawer
            //On press Navigate to the settings page
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text("profile".tr),
              onTap: () {
                Navigator.pushNamed(context, OrganizationProfile.id);
              },
            ),
            // US org display pending approvals option in drawer
            //On press Navigate to the pending approvals page
            ListTile(
              leading: Icon(Icons.pending),
              title: Text("pending_approvals".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PendingApprovalsAndDenials();
                })).then((value) {
                  setState(() {});
                });
              },
            ),
            // US org display expired charity option in drawer
            //On press Navigate to the expired charities page
            ListTile(
              leading: Icon(Icons.watch_later_outlined),
              title: Text("expired_charities".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ExpiredCharitiesScreen();
                })).then((value) {
                  setState(() {});
                });
              },
            ),
            // US org display inactive charity option in drawer
            //On press Navigate to inactive charity page
            ListTile(
              leading: Icon(Icons.not_interested),
              title: Text("inactive_charities".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return InactiveCharitiesScreen();
                })).then((value) {
                  setState(() {});
                });
              },
            ),
            // US org display contact admin option in drawer
            //On press Navigate to contact admin form page
            if (FirebaseAuth.instance.currentUser != null)
              ListTile(
                leading: const Icon(Icons.assignment_ind_outlined),
                title: Text("contact_admin".tr),
                onTap: () {
                  Get.to(ContactUs("OrganizationUsers"));
                },
              ),
            // US org display language option in drawer
            //On press change to the language selected
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text("language".tr),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          title: Center(child: Text("select_language".tr)),
                          children: <Widget>[
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('en', 'US'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("English"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('fr', 'FR'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("French"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('ar', 'SA'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("Arabic"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('es', 'ES'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("Spanish")))
                          ]);
                    });
              },
            ),
            // US org display logout option in drawer
            //On press Navigate to the login page
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("logout".tr),
              onTap: () {
                if (chatListener != null) chatListener.cancel();
                chatListener = null;
                FirebaseAuth.instance.signOut();
                MyGlobals.allMessages = <MessageModel>[].obs;
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(HomeScreen.id));
              },
            ),
          ],
        ),
      ),
    );
  }
// Foreign org drawer
  _buildForeignDrawer() {
    return Container(
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Stack(
                children: [
                  // Foreign org display name in drawer
                  Positioned(
                    bottom: 8.0,
                    left: 4.0,
                    child: Text(
                      organizationName,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            // Foreign org display setting option in drawer
            // On press Navigate to the settings page
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("settings".tr),
              onTap: () {
                Navigator.pushNamed(context, OrganizationSettingsPage.id);
              },
            ),
            // Foreign org display profile option in drawer
            //On press Navigate to the settings page
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text("profile".tr),
              onTap: () {
                Navigator.pushNamed(context, OrganizationProfile.id);
              },
            ),
            // Foreign org display gateway visits option in drawer
            //On press Navigate to the gateway visits page
            ListTile(
              leading: const Icon(Icons.link),
              title: Text("Gateway Visits".tr),
              onTap: () {
                Navigator.pushNamed(context, GatewayVisits.id);
              },
            ),
            // Foreign org display pending approvals option in drawer
            //On press Navigate to the pending approvals page
            ListTile(
              leading: Icon(Icons.pending),
              title: Text("pending_approvals".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PendingApprovalsAndDenials();
                })).then((value) {
                  setState(() {});
                });
              },
            ),
            // Foreign org display expired charity option in drawer
            //On press Navigate to the expired charities page
            ListTile(
              leading: Icon(Icons.watch_later_outlined),
              title: Text("expired_charities".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ExpiredCharitiesScreen();
                })).then((value) {
                  setState(() {});
                });
              },
            ),
            // Foreign org display inactive charity option in drawer
            //On press Navigate to inactive charity page
            ListTile(
              leading: Icon(Icons.not_interested),
              title: Text("inactive_charities".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return InactiveCharitiesScreen();
                })).then((value) {
                  setState(() {});
                });
              },
            ),
            // Foreign org display language option in drawer
            //On press change to the language selected
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text("language".tr),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          title: Center(child: Text("select_language".tr)),
                          children: <Widget>[
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('en', 'US'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("English"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('fr', 'FR'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("Francais"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('ar', 'SA'));
                                  Navigator.pop(context);
                                },
                                child:
                                    const Center(child: Text("اللغة العربية"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  await Get.updateLocale(
                                      const Locale('es', 'ES'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("Espanol")))
                          ]);
                    });
              },
            ),
            // Foreign org display contact admin option in drawer
            //On press Navigate to contact admin form page
            if (FirebaseAuth.instance.currentUser != null)
              ListTile(
                leading: const Icon(Icons.assignment_ind_outlined),
                title: Text("contact_admin".tr),
                onTap: () {
                  Get.to(ContactUs("OrganizationUsers"));
                },
              ),
            // Foreign org display logout option in drawer
            //On press Navigate to the login page
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("logout".tr),
              onTap: () {
                FirebaseAuth.instance.signOut();
                MyGlobals.allMessages = <MessageModel>[].obs;
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(HomeScreen.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
