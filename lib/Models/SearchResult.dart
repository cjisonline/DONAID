import 'package:cloud_firestore/cloud_firestore.dart';

class SearchResult {
  String title;
  String collection;
  String id;
  String description;

  SearchResult(
      {
        required this.title,
        required this.collection,
        required this.id,
        required this.description
      });
}