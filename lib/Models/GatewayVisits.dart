import 'package:cloud_firestore/cloud_firestore.dart';

class GatewayVisits{
  String charityTitle;
  String charityType;
  String donorID;
  String id;
  String organizationID;
  Timestamp visitedAt;

  GatewayVisits(this.charityType, this.charityTitle, this.donorID, this.id, this.organizationID, this.visitedAt );
}