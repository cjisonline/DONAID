import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/button_nav_bar.dart';
import 'add_campaigns_screen.dart';

class OrgAddSelection extends StatefulWidget {
  static const id = 'add_selection_screen';
  const OrgAddSelection({Key? key}) : super(key: key);

  @override
  _addPage createState() => _addPage();
}

class _addPage extends State<OrgAddSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DONAID'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white.withAlpha(55),
      body: Stack(children: [
        ListView(children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
            child: Text('Select an item you would like to create: ',
                style: TextStyle(fontSize: 20, color: Colors.white)),
          )
        ]),
        ListView(children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(20, 150, 20, 0),
              child: Material(
                  elevation: 5.0,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32.0),
                  child: MaterialButton(
                      child: const Text(
                        'Create Campaign',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, AddCampaignForm.id);
                      }))),
          Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Material(
                  elevation: 5.0,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32.0),
                  child: MaterialButton(
                      child: const Text(
                        'Create Urgent Case',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, AddCampaignForm.id);
                      }))),
          Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Material(
                  elevation: 5.0,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32.0),
                  child: MaterialButton(
                      child: const Text(
                        'Create Beneficiary',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, AddCampaignForm.id);
                      })))
        ])
      ]),

      bottomNavigationBar: ButtomNavigation(),
    );
  }
}
