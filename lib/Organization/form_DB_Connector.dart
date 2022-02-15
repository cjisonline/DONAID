import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormCRUD {
  late FirebaseFirestore firestore;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  initiliase() {
    firestore = FirebaseFirestore.instance;
    _getCurrentUser();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  Future<void> create(String category,
      String description, int goalAmount,
      String title) async {
    try {
      await firestore.collection("CampaignsTest").add({
        'amountRaised': 0,
        'category': category,
        'dataCreated': FieldValue.serverTimestamp(),
        'description': description,
        'endDate': FieldValue.serverTimestamp(),
        'goalAmount': goalAmount,
        'organizationID': loggedInUser,
        'title' : title
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await firestore.collection("CampaignsTest").doc(id).delete();
    } catch (e) {
      print(e);
    }
  }


  Future<void> update(int amountRaised, String category,
      String description, Timestamp endDate, int goalAmount,
      String id, String title) async {
    try {
      await firestore
          .collection("CampaignsTest")
          .doc(id)
          .update(
          {'category': category,
        'dataCreated': FieldValue.serverTimestamp(),
        'description': description,
        'endDate': endDate,
        'goalAmount': goalAmount,
        'title' : title});
    } catch (e) {
      print(e);
    }
  }
}