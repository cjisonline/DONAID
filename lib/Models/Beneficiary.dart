import 'package:cloud_firestore/cloud_firestore.dart';

class Beneficiary {
  String name;
  String biography;
  double goalAmount;
  double amountRaised;
  String category;
  Timestamp endDate;
  Timestamp dateCreated;
  String id;
  String organizationID;
  bool active;

  Beneficiary(
      {
        required this.name,
        required this.biography,
        required this.goalAmount,
        required this.amountRaised,
        required this.category,
        required this.endDate,
        required this.dateCreated,
        required this.id,
        required this.organizationID,
        required this.active,
      });
}
