import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../Models/PushNotification.dart';

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

Future<bool> deleteNotification(String? uid, PushNotification notification) {
  DocumentReference notificationsReference =
  FirebaseFirestore.instance.collection('Notifications').doc(uid);

  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(notificationsReference);

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