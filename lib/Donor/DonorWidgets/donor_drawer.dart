import 'package:donaid/Models/message.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../home_screen.dart';
import '../donor_profile.dart';

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
                children: const [
                  Positioned(
                    bottom: 8.0,
                    left: 4.0,
                    child: Text(
                      "Donor",
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
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushNamed(context, DonorProfile.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text("About"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.not_interested),
              title: const Text("Report"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
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
