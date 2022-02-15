import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:flutter/material.dart';

import 'donor_bottom_navigation_bar.dart';
import 'donor_drawer.dart';

class CategoryCampaignsScreen extends StatefulWidget {
  static const id = 'category_campaigns_screen';
  final categoryName;
  const CategoryCampaignsScreen({Key? key, this.categoryName}) : super(key: key);

  @override
  _CategoryCampaignsScreenState createState() => _CategoryCampaignsScreenState();
}

class _CategoryCampaignsScreenState extends State<CategoryCampaignsScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Campaign> campaigns = [];


  _getCampaigns() async {
    var ret = await _firestore.collection('UrgentCases').get();
    for (var element in ret.docs) {
      Campaign campaign = Campaign(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']
      );
      campaigns.add(campaign);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: Center(child: Text('Name: ${widget.categoryName}')),
      bottomNavigationBar: const DonorBottomNavigationBar(),
    );
  }
}
