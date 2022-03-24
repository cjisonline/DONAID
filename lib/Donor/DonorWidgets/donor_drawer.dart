import 'package:donaid/Models/message.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get.dart';

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
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text("profile".tr),
              onTap: () {
                Navigator.pushNamed(context, DonorProfile.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text("My Favorites".tr),
              onTap: () {
                Navigator.pushNamed(context, DonorFavoritePage.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text("about".tr),
              onTap: () {},
            ),
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
              leading: const Icon(Icons.help),
              title: Text("help".tr),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
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
