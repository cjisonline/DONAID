import 'package:cloud_firestore/cloud_firestore.dart';

class Adoptee {
  String name;
  String biography;
  double goalAmount;
  double amountRaised;
  String id;
  double monthlyAmount;

  Adoptee(
      {
        required this.name,
        required this.biography,
        required this.goalAmount,
        required this.amountRaised,
        required this.id,
        required this.monthlyAmount
      });
}