import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../Models/PushNotification.dart';

/*
* This file is used to add/delete notifications from the Notifications collection in Firestore.
* The Notifications collection in Firestore has a document for each user. The ID of the document is the UID of the user.
* The contents of each document is an array of Notification objects. The Notification objects are created in the Admin panel
* when the notification is sent to the mobile device.
*
* Each notification that is sent to the mobile users is passed to the addNotification method to add the notification object to that user's
* collection in Firestore so that the notifications stay between different app sessions. The deleteNotification method is called when a user
* swipes on the notification in the notifications page to get rid of it. The undoDeleteNotification method is called when the user selects UNDO
* after deleting a notification. The add/delete methods simply add or delete from the user's Notifications document, the undoDeleteNotification method
* puts the deleted notification back in to the Notifications document in the spot that it belongs in.*/
Future<bool> addNotification(String? uid, RemoteMessage message) {
  DocumentReference notificationsReference =
  FirebaseFirestore.instance.collection('Notifications').doc(uid);

  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(notificationsReference);
    if (postSnapshot.exists) {
        await tx.update(notificationsReference, <String, dynamic>{
          'notificationsList': FieldValue.arrayUnion([{
            'notificationTitle': message.notification!.title,
            'notificationBody':message.notification!.body,
            'dataTitle':message.data['title'],
            'dataBody':message.data['body']
          }])
        });
    } else {
      await tx.set(notificationsReference, {
        'notificationsList': [{
          'notificationTitle': message.notification!.title,
          'notificationBody':message.notification!.body,
          'dataTitle':message.data['title'],
          'dataBody':message.data['body']
        }]
      });
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<bool> undoDeleteNotification(String? uid, PushNotification notification) {
  DocumentReference notificationsReference =
  FirebaseFirestore.instance.collection('Notifications').doc(uid);

  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(notificationsReference);
    if (postSnapshot.exists) {
      await tx.update(notificationsReference, <String, dynamic>{
        'notificationsList': FieldValue.arrayUnion([{
          'notificationTitle': notification.title,
          'notificationBody': notification.body,
          'dataTitle': notification.dataTitle,
          'dataBody': notification.dataBody
        }
        ])
      });
    } else {
      await tx.set(notificationsReference, {
        'notificationsList': [{
          'notificationTitle': notification.title,
          'notificationBody': notification.body,
          'dataTitle': notification.dataTitle,
          'dataBody': notification.dataBody
        }
        ]
      });
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<bool> deleteNotification(String? uid, PushNotification notification) {
  DocumentReference notificationsReference =
  FirebaseFirestore.instance.collection('Notifications').doc(uid);

  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {

    await tx.update(notificationsReference, <String, dynamic>{
      'notificationsList': FieldValue.arrayRemove([{
        'notificationTitle':notification.title,
        'notificationBody':notification.body,
        'dataTitle':notification.dataTitle,
        'dataBody': notification.dataBody
      }])
    });

  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}