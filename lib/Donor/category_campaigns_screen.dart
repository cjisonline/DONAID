import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/campaign_donate_screen.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';

class CategoryCampaignsScreen extends StatefulWidget {
  final categoryName;
  const CategoryCampaignsScreen({Key? key, this.categoryName})
      : super(key: key);

  @override
  _CategoryCampaignsScreenState createState() =>
      _CategoryCampaignsScreenState();
}

class _CategoryCampaignsScreenState extends State<CategoryCampaignsScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Campaign> campaigns = [];
  List<Organization> organizations=[];

  @override
  void initState() {
    super.initState();
    _getCampaigns();
  }

  _getCampaigns() async {
    var ret = await _firestore.collection('Campaigns')
        .where('category', isEqualTo: widget.categoryName)
        .where('active', isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
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
          organizationID: element.data()['organizationID']);
      campaigns.add(campaign);
    }
    setState(() {});
    _getCampaignOrganizations();
  }

  _getCampaignOrganizations() async{
    for(var campaign in campaigns){
      var ret = await _firestore.collection('OrganizationUsers')
          .where('uid', isEqualTo: campaign.organizationID)
          .get();

      for(var element in ret.docs){
        Organization organization = Organization(
          organizationName: element.data()['organizationName'],
          uid: element.data()['uid'],
          organizationDescription: element.data()['organizationDescription'],
          country: element.data()['country'],
          gatewayLink: element.data()['gatewayLink'],
        );
        organizations.add(organization);
      }
    }
  }

  _paymentLinkPopUp(Organization organization){
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text('Detour!'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: Linkify(
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  throw 'Could not launch $link';
                }
              },
              text: 'The organization that created this charity is not based in the United States. Due to this, we cannot process your payment.'
                      'A link to the organization\'s payment gateway is below.\n\n ${organization.gatewayLink}',
              linkStyle: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          );
        });
  }
  _categoryCampaignsBody() {
    return ListView.builder(
        itemCount: campaigns.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    if(organizations[index].country =='United States'){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return (CampaignDonateScreen(campaigns[index]));
                      }));
                    }
                    else{
                      _paymentLinkPopUp(organizations[index]);
                    }
                  },
                  title: Text(campaigns[index].title),
                  subtitle: Text(campaigns[index].description),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('\$${(campaigns[index].amountRaised.toStringAsFixed(2))}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.black, fontSize: 15)),
                  Text(
                    '\$${campaigns[index].goalAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ]),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                  value: (campaigns[index].amountRaised/campaigns[index].goalAmount),
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
        title: Text('Campaigns - ${widget.categoryName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _categoryCampaignsBody(),
      bottomNavigationBar: const DonorBottomNavigationBar(),
    );
  }
}
