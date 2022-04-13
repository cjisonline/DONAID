import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Subscription.dart';


Future<bool> addSubscription(String? uid, Subscription subscription) {
  DocumentReference subscriptionReference =
  FirebaseFirestore.instance.collection('StripeSubscriptions').doc(uid);

  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(subscriptionReference);
    if (postSnapshot.exists) {
      await tx.update(subscriptionReference, <String, dynamic>{
        'subscriptionList': FieldValue.arrayUnion([{
          'adoptionID': subscription.adoptionID,
          'subscriptionID':subscription.subscriptionsID,
          'monthlyAmount': subscription.monthlyAmount
        }])
      });
    } else {
      await tx.set(subscriptionReference, {
        'subscriptionList': [{
          'adoptionID': subscription.adoptionID,
          'subscriptionID':subscription.subscriptionsID,
          'monthlyAmount': subscription.monthlyAmount
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

Future<bool> deleteSubscription(String? uid, Subscription cancelSubscription)async{
  DocumentReference subscriptionReference =
  FirebaseFirestore.instance.collection('StripeSubscriptions').doc(uid);

  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(subscriptionReference);

    await tx.update(subscriptionReference, <String, dynamic>{
      'subscriptionList': FieldValue.arrayRemove([{
        'adoptionID':cancelSubscription.adoptionID,
        'subscriptionID':cancelSubscription.subscriptionsID,
        'monthlyAmount':cancelSubscription.monthlyAmount,
      }])
    });

  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}