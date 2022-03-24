import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> updateFavorites(String? uid, String updateItemID) {
  DocumentReference favoritesReference =
  FirebaseFirestore.instance.collection('Favorite').doc(uid);

  return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
    if (postSnapshot.exists) {
      if (!postSnapshot['favoriteList'].contains(updateItemID)) {
        await tx.update(favoritesReference, <String, dynamic>{
          'favoriteList': FieldValue.arrayUnion([updateItemID]),
        });
      } else {
        await tx.update(favoritesReference, <String, dynamic>{
          'favoriteList': FieldValue.arrayRemove([updateItemID]),
        });
      }
    } else {
      await tx.set(favoritesReference, {
        'favoriteList': [updateItemID]
      });
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}