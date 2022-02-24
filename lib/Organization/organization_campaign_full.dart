import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_activecampaigns_expanded_screen.dart';
import 'package:flutter/material.dart';

import 'edit_campaign.dart';

class OrganizationCampaignFullScreen extends StatefulWidget {
  final Campaign campaign;
  const OrganizationCampaignFullScreen(this.campaign, {Key? key}) : super(key: key);

  @override
  _OrganizationCampaignFullScreenState createState() => _OrganizationCampaignFullScreenState();
}

class _OrganizationCampaignFullScreenState extends State<OrganizationCampaignFullScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState(){
    super.initState();
    _refreshCampaign();
  }

  _refreshCampaign() async{
    var ret = await _firestore.collection('Campaigns').where('id',isEqualTo: widget.campaign.id).get();

    var doc = ret.docs[0];
    widget.campaign.title = doc['title'];
    widget.campaign.description = doc['description'];
    widget.campaign.category = doc['category'];
    widget.campaign.goalAmount = doc['goalAmount'].toDouble();
    widget.campaign.endDate = doc['endDate'];
    setState(() {
    });

  }

  _stopCampaign() async {
    await _firestore.collection('Campaigns').doc(widget.campaign.id).set({
      'active': false
    });


  }

  _resumeCampaign() async {
    await _firestore.collection('Campaigns').doc(widget.campaign.id).set({
      'active': true
    });
  }

  Future<void> _stopCharityConfirm() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text('Are You Sure?'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'Stopping this charity will make it not visible to donors. Once you stop this charity '
                    'you can reactivate it from the Expired Charities page. Would you like to continue'
                    'with stopping this charity?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _stopCampaign();
                    Navigator.pushNamed(context, OrganizationCampaignsExpandedScreen.id);
                  },
                  child: const Text('Yes'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _resumeCharityConfirm() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
              child: Text('Are You Sure?'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'Resuming this charity will make it visible to donors again. Once you resume this charity '
                    'you can deactivate it again from the dashboard or the My Campaigns page. Would you like '
                    'to continue?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _resumeCampaign();
                    //TODO: Navigate to expired charities page
                  },
                  child: const Text('Yes'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
              ),
            ],
          );
        });
  }

  _campaignFullBody() {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.campaign.title),
            Text(widget.campaign.description),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${(widget.campaign.amountRaised.toStringAsFixed(2))}',
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      '\$${widget.campaign.goalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                value:
                (widget.campaign.amountRaised / widget.campaign.goalAmount),
                minHeight: 10,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 75, 20, 0),
                    child: (!widget.campaign.active && widget.campaign.endDate.compareTo(Timestamp.now()) > 0)
                        ? Container()
                        : Material(
                        elevation: 5.0,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(32.0),
                        child: MaterialButton(
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return EditCampaign(campaign: widget.campaign);
                              })).then((value) => _refreshCampaign());
                            })),),
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: (widget.campaign.active && widget.campaign.endDate.compareTo(Timestamp.now()) > 0)
                    ? Material(
                        elevation: 5.0,
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(32.0),
                        child: MaterialButton(
                            child: const Text(
                              'Stop Charity',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              _stopCharityConfirm();

                            }))
                : (!widget.campaign.active && widget.campaign.endDate.compareTo(Timestamp.now()) > 0)
                        ? Material(
                        elevation: 5.0,
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(32.0),
                        child: MaterialButton(
                            child: const Text(
                              'Resume Charity',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              _resumeCharityConfirm();
                            }))
                  : (widget.campaign.endDate.compareTo(Timestamp.now()) < 0)
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              child: const Text(
                                'Note: This charity has expired. To reactive this charity and make it visible to donors again, edit the end date for the charity.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                        : Container()
                ),
              ],
            ),
          ])
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaign.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const OrganizationDrawer(),
      body: _campaignFullBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
