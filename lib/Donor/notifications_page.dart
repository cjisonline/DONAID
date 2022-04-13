import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorAlertDialog/DonorAlertDialogs.dart';
import 'package:donaid/Donor/urgent_case_donate_screen.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/PushNotification.dart';
import '../Models/UrgentCase.dart';
import '../Services/notifications.dart';
import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';

class DonorNotificationPage extends StatefulWidget {
  static const id = 'donor_notification_page';
  const DonorNotificationPage({Key? key}) : super(key: key);

  @override
  _DonorNotificationPageState createState() => _DonorNotificationPageState();
}

class _DonorNotificationPageState extends State<DonorNotificationPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  var deletedNotification;
  var deletedIndex;
  Organization? organization;
  Map<String, dynamic>? charity;

  List<PushNotification> notifications=[];

  @override
  void initState(){
    super.initState();
    _getNotifications();
  }

  _urgentCaseOrganizationIsInUnitedStates(String urgentCaseId) async{
    //Get the organization that created the urgent case for the notification
    //Check if that organization is based in the US. Return true if it is based in the US, return false otherwise.

    var urgentCaseRef = await _firestore.collection('UrgentCases').where('id',isEqualTo: urgentCaseId).get();
    var urgentCaseDoc = urgentCaseRef.docs.first;

    var organizationRef = await _firestore.collection('OrganizationUsers').where('uid', isEqualTo: urgentCaseDoc.data()['organizationID']).get();
    var organizationDoc = organizationRef.docs.first;
    organization = Organization(
      uid: organizationDoc.data()['uid'],
      organizationName: organizationDoc.data()['organizationName'],
      organizationEmail: organizationDoc.data()['organizationEmail'],
      organizationDescription: organizationDoc.data()['organizationDescription'],
      id: organizationDoc.data()['id'],
      profilePictureDownloadURL: organizationDoc.data()['profilePictureDownloadURL'],
      phoneNumber: organizationDoc.data()['phoneNumber'],
      gatewayLink: organizationDoc.data()['gatewayLink'],
      country: organizationDoc.data()['country'],
    );

    charity = {
      'charityID': urgentCaseDoc.data()['id'],
      'charityType':'Urgent Case',
      'charityTitle': urgentCaseDoc.data()['title']
    };

    return organization?.country == 'United States';
  }

  _goToChosenUrgentCase(String id)async{
    //Get full urgent case information and go to the full details page for that urgent case

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
        rejected: doc.data()['rejected'],
        approved: doc.data()['approved']
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return (UrgentCaseDonateScreen(urgentCase));
    }));
  }

  _getNotifications() async {
    //Get all notifications for the current user

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
                  deletedIndex = index;
                  deletedNotification = notifications[index];

                  deleteNotification(_auth.currentUser?.uid, notifications[index]);
                  notifications.removeAt(index);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notification deleted.'),
                        duration: Duration(seconds:3),
                        action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () async{
                              undoDeleteNotification(_auth.currentUser?.uid, deletedNotification);
                              setState(() {
                                notifications.insert(deletedIndex, deletedNotification);
                              });

                            }),
                      ));
                },
                child: GestureDetector(
                  onTap: ()async{
                    if(notifications[index].dataTitle.toString() == 'UrgentCaseApprovals'){
                      
                      var urgentCaseIsInUnitedStates = await _urgentCaseOrganizationIsInUnitedStates(notifications[index].dataBody.toString());
                      if(urgentCaseIsInUnitedStates){
                        _goToChosenUrgentCase(notifications[index].dataBody.toString());

                      }
                      else{
                        DonorAlertDialogs.paymentLinkPopUp(context, organization!, _auth.currentUser!.uid, charity!);
                      }
                    }
                  },
                  child: ListTile(
                    title: Text(notifications[index].title.toString()),
                    subtitle: Text(notifications[index].body.toString(),
                  ),),
                ),
              ),
              SizedBox(height:10)
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
