import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_campaign_full.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrganizationCampaignsExpandedScreen extends StatefulWidget {
  static const id = 'organization_campaigns_expanded_screen';
  const OrganizationCampaignsExpandedScreen({Key? key}) : super(key: key);

  @override
  _OrganizationCampaignsExpandedScreenState createState() =>
      _OrganizationCampaignsExpandedScreenState();
}

class _OrganizationCampaignsExpandedScreenState
    extends State<OrganizationCampaignsExpandedScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Campaign> campaigns = [];

  @override
  void initState() {
    super.initState();
    _getCampaigns();
  }

  _getCampaigns() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .where('active', isEqualTo: true)
        .orderBy('endDate', descending: false)
        .get();

    for (var element in ret.docs) {
      Campaign campaign = Campaign(
        title: element.data()['title'],
        description: element.data()['description'],
        goalAmount: element.data()['goalAmount'].toDouble(),
        amountRaised: element.data()['amountRaised'].toDouble(),
        category: element.data()['category'],
        endDate: element.data()['endDate'],
        dateCreated: element.data()['dateCreated'],
        id: element.data()['id'],
        organizationID: element.data()['organizationID'],
        active: element.data()['active'],
      );
      campaigns.add(campaign);
    }
    setState(() {});
  }

  _campaignsBody() {
    return ListView.builder(
        itemCount: campaigns.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    //TODO: implement on tap
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return (OrganizationCampaignFullScreen(campaigns[index]));
                    }));
                  },
                  title: Text(campaigns[index].title),
                  subtitle: Text(campaigns[index].description),
                  trailing: IconButton(
                          icon: const Icon(
                            Icons.stop,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            //TODO: end charity button
                          },
                        )
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '\$${(campaigns[index].amountRaised.toStringAsFixed(2))}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15)),
                      Text(
                        '\$${campaigns[index].goalAmount.toStringAsFixed(2)}',
                        textAlign: TextAlign.start,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ]),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                  value: (campaigns[index].amountRaised /
                      campaigns[index].goalAmount),
                  minHeight: 10,
                ),
                const Divider()
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Campaigns'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const OrganizationDrawer(),
      body: _campaignsBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
