import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Subscription.dart';

/*This file handles the tracking of subscriptions (i.e. Adoptions) for a user
* The Adoptions that a donor user has is tracked in the StripeSubscriptions collection in Firestore.
* The StripeSubscriptions collection has a document for each user. The ID of the document is the UID of the donor user.
* The contents of each document is simply an array of Subscription objects. Each subscription object contains the subscription ID (which
* is given by stripe upon the creation of an adoption), the adoption ID (the ID of the Adoption entity that the donor is contributing to),
* and the monthly contribution amount.
*
* The methods in this file are called whenever a donor user makes a new adoption or cancels an adoption. The methods will add/remove the subscription
* object from that donor users array of subscriptions in the StripeSubscriptions collection.*/
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