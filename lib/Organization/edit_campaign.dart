import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/organization_campaign_full.dart';
import 'package:donaid/Organization/organization_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditCampaign extends StatefulWidget {
  Campaign campaign;

  EditCampaign({Key? key, required this.campaign}) : super(key: key);

  @override
  _EditCampaignState createState() => _EditCampaignState();
}

class _EditCampaignState extends State<EditCampaign> {
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController? _campaignNameController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _organizationDescriptionController;
  TextEditingController? _gatewayLinkController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Edit Campaign'),
          leadingWidth: 80,
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel',
                style: TextStyle(fontSize: 15.0, color: Colors.white)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return OrganizationCampaignFullScreen(widget.campaign);
                }));
              },
              child: const Text('Save',
                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
            ),
          ]),
      body: _body(),
      bottomNavigationBar: OrganizationBottomNavigation(),
    );
  }

  _body(){

  }


}
