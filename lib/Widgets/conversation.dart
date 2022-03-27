import 'package:flutter/material.dart';

Widget conversation(String name, String message, tab, tab2,
    {bool messageSeen = false}) {
  return InkWell(
      onTap: () => tab(),
      onLongPress: () => tab2(),
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 8.0),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Expanded(
                            child: Text(name,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    // color: Colors.white,
                                    fontWeight: FontWeight.w700))),
                      ]),
                      Row(children: [
                        Expanded(
                            child: Text(message,
                                maxLines: 2, style: TextStyle(fontSize: 16.0)))
                      ])
                    ]))
              ])));
}
