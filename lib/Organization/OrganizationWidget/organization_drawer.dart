import 'package:donaid/Models/message.dart';
import 'package:donaid/Organization/gateway_visits.dart';
import 'package:donaid/Organization/settings.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:donaid/Organization/organization_expiredcharities_screen.dart';
import 'package:donaid/Organization/organization_inactivecharities_screen.dart';
import 'package:donaid/Organization/pending_approvals_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart';


import '../../home_screen.dart';
import '../organization_profile.dart';

class OrganizationDrawer extends StatefulWidget {
  const OrganizationDrawer({Key? key}) : super(key: key);

  @override
  _OrganizationDrawerState createState() => _OrganizationDrawerState();
}

class _OrganizationDrawerState extends State<OrganizationDrawer> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8.0,
                    left: 4.0,
                    child: Text(
                      "_organization".tr,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("settings".tr),
              onTap: () {
                Navigator.pushNamed(context, OrganizationSettingsPage.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title:  Text("profile".tr),
              onTap: () {
                Navigator.pushNamed(context, OrganizationProfile.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title:  Text("Gateway Visits".tr),
              onTap: () {
                Navigator.pushNamed(context, GatewayVisits.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.pending),
              title: Text("pending_approvals".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return PendingApprovals();
                })).then((value){
                  setState(() {
                  });
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.watch_later_outlined),
              title: Text("expired_charities".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ExpiredCharitiesScreen();
                })).then((value){
                  setState(() {
                  });
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.not_interested),
              title: Text("inactive_charities".tr),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return InactiveCharitiesScreen();
                })).then((value){
                  setState(() {});
                });
              },
            ),
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
