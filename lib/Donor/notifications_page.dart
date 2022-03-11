import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';

class NotificationPage extends StatefulWidget {
  static const id = 'notification_page';
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _messaging = FirebaseMessaging.instance;

  @override
  void initState(){
    super.initState();
  }


  _body(){
    return Center(
      child: Column(
        children: [

        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      drawer: const DonorDrawer(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
