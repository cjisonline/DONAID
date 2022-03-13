import 'package:donaid/Organization/add_beneficiary_screen.dart';
import 'package:donaid/Organization/add_urgentcase_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/organization_bottom_navigation.dart';
import 'add_campaigns_screen.dart';
import 'package:get/get.dart';


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
        title: Text('donaid'.tr),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white.withAlpha(55),
      body: Stack(children: [
        ListView(children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
            child: Text('select_an_item_you_would_like_to_create: '.tr,
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
                      child:  Text(
                        'create_campaign'.tr,
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
                      child:  Text(
                        'create_urgent_case'.tr,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, AddUrgentCaseForm.id);
                      }))),
          Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Material(
                  elevation: 5.0,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(32.0),
                  child: MaterialButton(
                      child:  Text(
                        'create_beneficiary'.tr,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(context, AddBeneficiaryForm.id);
                      })))
        ])
      ]),

      bottomNavigationBar: OrganizationBottomNavigation(),
    );
  }
}
