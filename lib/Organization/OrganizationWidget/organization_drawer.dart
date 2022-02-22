import 'package:donaid/Models/message.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../home_screen.dart';
import '../organization_profile.dart';

class OrganizationDrawer extends StatefulWidget {
  const OrganizationDrawer({Key? key}) : super(key: key);

  @override
  _OrganizationDrawerState createState() => _OrganizationDrawerState();
}

class _OrganizationDrawerState extends State<OrganizationDrawer> {
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
                      "Organization",
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
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushNamed(context, OrganizationProfile.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text("About"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.not_interested),
              title: Text("Report"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Help"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
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
