import 'package:flutter/material.dart';
///Author: Raisa Zaman
class MyCustomForm extends StatelessWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: TextFormField(
            decoration: const InputDecoration(
              filled: true, fillColor: Colors.white,
              border: UnderlineInputBorder(),
              labelText: 'Enter Title',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: TextFormField(
            decoration: const InputDecoration(
              filled: true, fillColor: Colors.white,
              border: UnderlineInputBorder(),
              labelText: 'Enter Category',
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: TextFormField(
            decoration: const InputDecoration(
              filled: true, fillColor: Colors.white,
              border: UnderlineInputBorder(),
              labelText: 'Goal Amount',
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: TextFormField(
            decoration: const InputDecoration(
              filled: true, fillColor: Colors.white,
              border: UnderlineInputBorder(),
              labelText: 'Needed by',
            ),
          ),
        ),

      ],
    );
  }
}