import 'package:cloud_firestore/cloud_firestore.dart';

class GatewayVisit {
  String charityTitle;
  String charityType;
  String donorID;
  String id;
  String organizationID;
  String charityID;
  Timestamp visitedAt;
  bool guest;

  GatewayVisit({
    required this.charityTitle,
    required this.charityType,
    required this.donorID,
    required this.id,
    required this.organizationID,
    required this.visitedAt,
    required this.charityID,
    required this.guest
  });
}