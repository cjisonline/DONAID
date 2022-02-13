import 'package:flutter/material.dart';

class ProfileRow extends StatelessWidget {
  final String label;
  final String field;

  const ProfileRow( this.label, this.field, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Container(
                margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.5, color: Colors.grey),
                    )),
                child: Padding (
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children:  [
                                Container(
                                    margin: const EdgeInsets.only(bottom: 15.0),
                                    child : Text(
                                      label,
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15.0, fontWeight: FontWeight.bold),
                                    )
                                )
                              ]
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                              Container(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child : Text(
                                  field,
                                  style: TextStyle(fontSize: 25.0),
                                ),
                              )])
                        ])

                ));
  }
}
