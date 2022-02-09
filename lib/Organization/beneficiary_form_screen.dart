
import 'package:flutter/material.dart';

import 'OrganizationWidget/form.dart';
///Author: Raisa Zaman
class BeneficiaryForm extends StatelessWidget {
  const BeneficiaryForm({Key? key}) : super(key: key);

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
                      padding: EdgeInsets.fromLTRB(20, 20,0,0),
                      child: Text('Create a beneficiary: ', style: TextStyle(fontSize: 20,
                          color: Colors.white)),
                    )
                  ]
              ),
              ListView(
                  children:<Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 50,0,0),
                      child: const MyCustomForm(),
                    )
                  ]
              )
            ]
        )
    );
  }
}