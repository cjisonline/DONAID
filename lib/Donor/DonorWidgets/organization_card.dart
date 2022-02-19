import 'package:flutter/material.dart';

class OrganizationCard extends StatelessWidget {
  final String name;

  const OrganizationCard( this.name, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: 175.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey.shade300, width: 2.0)),
          child: Column(
              children: [
            const Icon(Icons.apartment, color: Colors.blue, size: 40,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
            )
          ]),
        ));
  }
}
