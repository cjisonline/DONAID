import 'package:flutter/material.dart';

class OrganizationSection extends StatelessWidget {
  final Icon icon;
  final String name;
  final String category;

  OrganizationSection(this.icon, this.name, this.category);
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          width: 125.0,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius:
              BorderRadius.all(Radius.circular(10))),
          child: Column(children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.apartment,
                  color: Colors.white, size: 50),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Org 1',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            )
          ]),
        ));
  }
}
