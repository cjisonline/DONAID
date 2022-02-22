import 'package:flutter/material.dart';

class CharityCategoryCard extends StatelessWidget {
  final String name;

  const CharityCategoryCard( this.name, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return   Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius:
                BorderRadius.all(Radius.circular(10))),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Row(children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {},
                  icon: const Icon(Icons.apartment,
                      color: Colors.white, size: 20),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 0.0, right: 10.0),
                  child: Text(name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      )),
                )
              ]),
            )));
  }
}
