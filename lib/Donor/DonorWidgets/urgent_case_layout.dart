import 'package:flutter/material.dart';

class UrgentCaseSection extends StatelessWidget {
  final String title;
  final String description;
  final int goalAmount;

  UrgentCaseSection( this.title, this.description, this.goalAmount);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: 275.0,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.apartment,
                  color: Colors.white,
                  size: 50),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            ),
            SizedBox(
                height: 75.0,
                child: Text(
                  description,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('70%',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              Text(
                '\$$goalAmount',
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ]),
            LinearProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor),
              value: 0.7,
              minHeight: 10,
            ),
            Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(children: [
                    IconButton(
                      enableFeedback: false,
                      onPressed: () {},
                      icon: const Icon(Icons.favorite,
                          color: Colors.white, size: 20),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: Text('Donate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                    )
                  ]),
                ),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ))
          ]),
        ));
  }
}
