import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchCard extends StatelessWidget {
  final String title;
  final String goalAmount;

  SearchCard(this.title, this.goalAmount);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(title),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(goalAmount.toString()),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
