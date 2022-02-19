import 'package:flutter/material.dart';

class ProfileRow extends StatelessWidget {
  final String label;
  final String field;

  const ProfileRow( this.label, this.field, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
       Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:  [
              Container(
                  margin: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 10.0, top: 20.0),
                  child : Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15.0, fontWeight: FontWeight.bold),
                  )
              )
            ]
        ),
        Container(
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 10.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey.shade300, width: 2.0)
            ),
            child: Padding (
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                field,
                                style: TextStyle(fontSize: 20.0,),
                              ),
                            )])
                    ])

            ))
      ]

    );

  }
}
