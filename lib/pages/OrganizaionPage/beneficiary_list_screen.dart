import 'package:flutter/material.dart';

import '../home_screen.dart';

class BeneficiaryList extends StatefulWidget {
  static const id = 'beneficiary_list_screen';
  const BeneficiaryList({Key? key}) : super(key: key);

  @override
  _BeneficiaryList createState() => _BeneficiaryList();
}

class _BeneficiaryList extends State<BeneficiaryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DONAID'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add, size: 30,), onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );}),
        ],
      ),
        backgroundColor: Colors.white.withAlpha(55),
        body: Stack(
          children: [
          ListView(
            children:<Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(20, 20,0,0),
              child: Text('My Beneficiary', style: TextStyle(fontSize: 20,
                  color: Colors.white))
        )
        ]
    )
    ]
    )
    );
  }
}

