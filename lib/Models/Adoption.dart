import 'package:cloud_firestore/cloud_firestore.dart';

class Adoption {
  String name;
  String biography;
  double goalAmount;
  double amountRaised;
  String category;
  Timestamp dateCreated;
  String id;
  String organizationID;
  bool active;

  Adoption(
      {
        required this.name,
        required this.biography,
        required this.goalAmount,
        required this.amountRaised,
        required this.category,
        required this.dateCreated,
        required this.id,
        required this.organizationID,
        required this.active,
      });
}