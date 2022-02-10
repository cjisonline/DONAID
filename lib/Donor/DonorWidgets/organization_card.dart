import 'package:flutter/material.dart';

class OrganizationCard extends StatelessWidget {
  final String name;

  const OrganizationCard( this.name, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          width: 125.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey.shade300, width: 2.0)),
          child: Column(children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.apartment,
                  color: Colors.blue, size: 50),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
            )
          ]),
        ));
  }
}
