import 'package:cloud_firestore/cloud_firestore.dart';

class Donation{
  String charityID;
  String charityName;
  Timestamp donatedAt;
  double donationAmount;
  String donorID;
  String organizationID;
  String id;
  String category;
  String charityType;

  Donation({
  required this.charityID,
  required this.charityName,
  required this.donatedAt,
  required this.donationAmount,
  required this.donorID,
  required this.organizationID,
  required this.id,
  required this.category,
  required this.charityType
  });
}