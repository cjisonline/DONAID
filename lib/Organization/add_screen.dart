
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/gradient_button.dart';

class AddPage extends StatefulWidget {
  static const id = 'add_page';
  const AddPage({Key? key}) : super(key: key);

  @override
  _addPage createState() => _addPage();
}
class _addPage extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('DONAID'),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Colors.white.withAlpha(55),
        body: Stack(
            children: [
              ListView(
                  children:<Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(40, 20,0,0),
                      child: Text('Select an item you would like to create: ', style: TextStyle(fontSize: 20,
                          color: Colors.white)),
                    )
                  ]
              ),
              ListView(
                  children:<Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 50,0,0),
                      child: const MyStatelessWidget(),
                    )
                  ]
              )
            ]
        )
    );
  }
}

