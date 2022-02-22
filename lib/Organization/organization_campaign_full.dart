import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:flutter/material.dart';

class OrganizationCampaignFullScreen extends StatefulWidget {
  final Campaign campaign;
  const OrganizationCampaignFullScreen(this.campaign, {Key? key}) : super(key: key);

  @override
  _OrganizationCampaignFullScreenState createState() => _OrganizationCampaignFullScreenState();
}

class _OrganizationCampaignFullScreenState extends State<OrganizationCampaignFullScreen> {
  final _firestore = FirebaseFirestore.instance;

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
                              //TODO: On pressed
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
                              //TODO: On pressed
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
                              //TODO: On pressed
                            }))
                  : (!widget.campaign.active && widget.campaign.endDate.compareTo(Timestamp.now()) < 0)
                        ? Center(
                          child: Container(
                            child: const Text(
                              'Charity Has Ended',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
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
