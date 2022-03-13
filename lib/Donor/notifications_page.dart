import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../Models/PushNotification.dart';
import '../Models/UrgentCase.dart';
import '../Services/notifications.dart';
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
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<PushNotification> notifications=[];

  @override
  void initState(){
    super.initState();
    _getNotifications();
  }

  _goToChosenUrgentCase(String id)async{
    var ret = await _firestore.collection('UrgentCases').where('id',isEqualTo: id).get();
    var doc = ret.docs[0];
    UrgentCase urgentCase = UrgentCase(
        title: doc.data()['title'],
        description: doc.data()['description'],
        goalAmount: doc.data()['goalAmount'].toDouble(),
        amountRaised: doc.data()['amountRaised'].toDouble(),
        category: doc.data()['category'],
        endDate: doc.data()['endDate'],
        dateCreated: doc.data()['dateCreated'],
        id: doc.data()['id'],
        organizationID: doc.data()['organizationID'],
        active: doc.data()['active'],
        approved: doc.data()['approved']
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (UrgentCaseDonateScreen(urgentCase));
    }));
  }

  _getNotifications() async {
    var notificationsDoc = await _firestore.collection('Notifications').doc(_auth.currentUser?.uid).get();

    for(var item in notificationsDoc['notificationsList']){
      PushNotification notification = PushNotification(
          item['notificationTitle'],
          item['notificationBody'],
          item['dataTitle'],
          item['dataBody']
      );

      notifications.add(notification);
    }
    setState(() {
      notifications = notifications.reversed.toList();
    });


  }

  _body(){
    return ListView.builder(
        itemCount: notifications.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, int index) {
          return Column(
            children: [
              Dismissible(
                key: UniqueKey(),
                onDismissed: (direction){
                  deleteNotification(_auth.currentUser?.uid, notifications[index]);
                  notifications.removeAt(index);
                  setState(() {});
                },
                child: GestureDetector(
                  onTap: (){
                    if(notifications[index].dataTitle.toString() == 'UrgentCaseApprovals'){
                      _goToChosenUrgentCase(notifications[index].dataBody.toString());
                    }
                  },
                  child: ListTile(
                    title: Text(notifications[index].title.toString()),
                    subtitle: Text(notifications[index].body.toString(),
                  ),),
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _body(),
      drawer: const DonorDrawer(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
