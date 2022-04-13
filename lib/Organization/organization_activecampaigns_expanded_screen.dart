import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_campaign_full.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

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
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getCampaigns();
  }

  _refreshPage() async{
    campaigns.clear();
    _getCampaigns();
    setState(() {

    });
  }
  _getCampaigns() async {
    var ret = await _firestore
        .collection('Campaigns')
        .where('organizationID', isEqualTo: _auth.currentUser?.uid)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
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

    campaigns.sort((b,a) => (a.dateCreated).compareTo((b.dateCreated)));
    setState(() {});
  }

  _campaignsBody() {
    return RefreshIndicator(
      onRefresh: ()async{
        _refreshPage();
      },
      child: campaigns.isNotEmpty
        ? ListView.builder(
          itemCount: campaigns.length,
          shrinkWrap: true,
          itemBuilder: (context, int index) {
            return Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return (OrganizationCampaignFullScreen(campaigns[index]));
                      })).then((value) => _refreshPage());
                    },
                    title: Text(campaigns[index].title),
                    subtitle: Text(campaigns[index].description),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('\$'+f.format(campaigns[index].amountRaised),
                              textAlign: TextAlign.left,
                              style: const TextStyle(color: Colors.black, fontSize: 15)),
                          Text(
                            '\$'+f.format(campaigns[index].goalAmount),
                            textAlign: TextAlign.start,
                            style: const TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ]),
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green),
                            value: (campaigns[index].amountRaised/campaigns[index].goalAmount),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height:10)
                ],
              ),
            );
          })
      :  Center(child: Text('no_active_campaigns_to_show'.tr, style: TextStyle(fontSize: 18),)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('my_campaigns'.tr),
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
