import 'package:donaid/Models/message.dart';
import 'package:donaid/Services/chatServices.dart';
import 'package:donaid/contactUs.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home_screen.dart';
import '../donation_history.dart';
import '../donor_favorite_screen.dart';
import '../donor_profile.dart';
import '../settings.dart';

class DonorDrawer extends StatefulWidget {
  const DonorDrawer({Key? key}) : super(key: key);

  @override
  _DonorDrawerState createState() => _DonorDrawerState();
}

class _DonorDrawerState extends State<DonorDrawer> {
  final Future<SharedPreferences> _prefs =  SharedPreferences.getInstance();

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
                      "donor".tr,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text("settings".tr),
              onTap: () {
                Navigator.pushNamed(context, DonorSettingsPage.id);
              },
            ),
            if (FirebaseAuth.instance.currentUser?.email != null)
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text("profile".tr),
                onTap: () {
                  Navigator.pushNamed(context, DonorProfile.id);
                },
              ),
            if (FirebaseAuth.instance.currentUser?.email != null)
              ListTile(
                leading: const Icon(Icons.favorite),
                title: Text("My Favorites".tr),
                onTap: () {
                  Navigator.pushNamed(context, DonorFavoritePage.id);
                },
              ),
            if (FirebaseAuth.instance.currentUser?.email != null)
              ListTile(
                leading: const Icon(Icons.history),
                title: Text("donation_history".tr),
                onTap: () {
                  Navigator.pushNamed(context, DonationHistory.id);
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
                                  final SharedPreferences prefs = await _prefs;
                                  prefs.setStringList('Locale', ['en','US']);

                                  await Get.updateLocale(
                                      const Locale('en', 'US'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("English"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  final SharedPreferences prefs = await _prefs;
                                  prefs.setStringList('Locale', ['fr','FR']);

                                  await Get.updateLocale(
                                      const Locale('fr', 'FR'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("Francais"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  final SharedPreferences prefs = await _prefs;
                                  prefs.setStringList('Locale', ['ar','SA']);

                                  await Get.updateLocale(
                                      const Locale('ar', 'SA'));
                                  Navigator.pop(context);
                                },
                                child:
                                    const Center(child: Text("اللغة العربية"))),
                            SimpleDialogOption(
                                onPressed: () async {
                                  final SharedPreferences prefs = await _prefs;
                                  prefs.setStringList('Locale', ['es','ES']);

                                  await Get.updateLocale(
                                      const Locale('es', 'ES'));
                                  Navigator.pop(context);
                                },
                                child: const Center(child: Text("Espanol")))
                          ]);
                    });
              },
            ),
            if (FirebaseAuth.instance.currentUser?.email != null)
              ListTile(
                leading: const Icon(Icons.assignment_ind_outlined),
                title: Text("contact_admin".tr),
                onTap: () {
                  Get.to(ContactUs("DonorUsers"));
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
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
}
