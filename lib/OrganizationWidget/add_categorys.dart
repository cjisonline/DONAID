import 'package:flutter/material.dart';
import './category_layout.dart';

class Category extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          CategorySection(
              Icon(Icons.house, size: 40,),//This is where you will get data from firebase
              'Shelter'
          ),
          CategorySection(
              Icon(Icons.book, size: 40,),
              'Studies'
          ),
          CategorySection(
              Icon(Icons.food_bank, size: 40,),
              'Food'
          ),
          CategorySection(
              Icon(Icons.build, size: 40,),
              'Building'
          ),
          CategorySection(
              Icon(Icons.airline_seat_individual_suite, size: 40,),
              'Hospital'
          ),
          CategorySection(
              Icon(Icons.weekend, size: 40,),
              'Furniture'
          ),
        ],
      ),
    );
  }
}