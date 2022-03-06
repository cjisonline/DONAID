import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Models/Organization.dart';
import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';

class OrganizationFullDetailsScreen extends StatefulWidget {
  final Organization organization;
  const OrganizationFullDetailsScreen(this.organization, {Key? key}) : super(key: key);

  @override
  _OrganizationFullDetailsScreenState createState() => _OrganizationFullDetailsScreenState();
}

class _OrganizationFullDetailsScreenState extends State<OrganizationFullDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  int beneficiaryCount=0;
  int campaignCount=0;

  @override
  void initState(){
    super.initState();
    _getCounts();
  }

  _getCounts() async{
    var campaignsRet = await _firestore.collection('Campaigns').where('organizationID', isEqualTo: widget.organization.uid).get();
    campaignCount = campaignsRet.docs.length;

    var beneficiariesRet = await _firestore.collection('Beneficiaries').where('organizationID', isEqualTo: widget.organization.uid).get();
    beneficiaryCount = beneficiariesRet.docs.length;

    setState(() {});
  }

  Widget _buildProfilePictureDisplay(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
      child: (widget.organization.profilePictureDownloadURL==null || widget.organization.profilePictureDownloadURL.toString().isEmpty)
          ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 150,
              height: 150,
              child: Icon(Icons.person,size: 150),
            ),])
          : (widget.organization.profilePictureDownloadURL.toString().isNotEmpty)
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Image.network(
              widget.organization.profilePictureDownloadURL.toString(),
              fit: BoxFit.contain,
            ),),
        ],
      )
          : Container(),
    );
  }

  _organizationDetailsBody(){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: Column(
          children: [
            _buildProfilePictureDisplay(),
            Text(widget.organization.organizationName,
            style: const TextStyle(
              fontSize: 25
            ),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Text(widget.organization.organizationDescription.toString(),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 50),
                  Text('${beneficiaryCount} Beneficiaries', style: TextStyle(fontSize: 18),)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, size: 50,),
                  Text('${campaignCount} Campaigns', style: TextStyle(fontSize: 18),)
                ],
              ),
            )
          ],
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.organization.organizationName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _organizationDetailsBody(),
      bottomNavigationBar:  DonorBottomNavigationBar(),
    );
  }
}
