import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//Display organization search cards
class SearchCard extends StatelessWidget {
  final String title;
  final String goalAmount;
// Get the charity title and goal amount for the card
  SearchCard(this.title, this.goalAmount);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              //Display title
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(title),
                  ),
                ],
              ),
              //Display goal amount
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
