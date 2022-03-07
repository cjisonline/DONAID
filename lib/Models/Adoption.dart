import 'package:cloud_firestore/cloud_firestore.dart';

class Adoption {
  String name;
  String description;
  double adoptionCost;
  String category;
  Timestamp dateCreated;
  String id;
  String organizationID;
  bool active;

  Adoption(
      {
        required this.name,
        required this.description,
        required this.adoptionCost,
        required this.category,
        required this.dateCreated,
        required this.id,
        required this.organizationID,
        required this.active,
      });
}
