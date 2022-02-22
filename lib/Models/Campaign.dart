import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  String title;
  String description;
  double goalAmount;
  double amountRaised;
  String category;
  Timestamp endDate;
  Timestamp dateCreated;
  String id;
  String organizationID;

  Campaign(
      {
        required this.title,
        required this.description,
        required this.goalAmount,
        required this.amountRaised,
        required this.category,
        required this.endDate,
        required this.dateCreated,
        required this.id,
        required this.organizationID,
      });
}