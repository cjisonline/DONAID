import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_campaign.dart';
import 'package:get/get.dart';

class OrganizationCampaignFullScreen extends StatefulWidget {
  final Campaign campaign;
  const OrganizationCampaignFullScreen(this.campaign, {Key? key}) : super(key: key);

  @override
  _OrganizationCampaignFullScreenState createState() => _OrganizationCampaignFullScreenState();
}

class _OrganizationCampaignFullScreenState extends State<OrganizationCampaignFullScreen> {
  final _firestore = FirebaseFirestore.instance;
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState(){
    super.initState();
    _refreshCampaign();
  }

  _refreshCampaign() async{
    //Refreshes the campaign information on the page. This is used for after when a user edits a campaign
    var ret = await _firestore.collection('Campaigns').where('id',isEqualTo: widget.campaign.id).get();

    var doc = ret.docs[0];
    widget.campaign.title = doc['title'];
    widget.campaign.description = doc['description'];
    widget.campaign.category = doc['category'];
    widget.campaign.goalAmount = doc['goalAmount'].toDouble();
    widget.campaign.endDate = doc['endDate'];
    widget.campaign.active = doc['active'];
    setState(() {
    });

  }

  _stopCampaign() async {
    //Toggles the campaign to inactive. This makes it no longer display to donors
    await _firestore.collection('Campaigns').doc(widget.campaign.id).update({
      'active': false
    });


  }

  _deleteCampaign() async{
    //Delete campaign from database
    await _firestore.collection('Campaigns').doc(widget.campaign.id).delete();
  }

  _resumeCampaign() async {
    //Toggles the campaign to active. This makes it display to donors again
    await _firestore.collection('Campaigns').doc(widget.campaign.id).update({
      'active': true
    });
  }

  Future<void> _stopCharityConfirm() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('are_you_sure?'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            //doubt
            content: Text(
                'Stopping this charity will make it not visible to donors. Once you stop this charity you can reactivate it from the Inactive Charities page. Would you like to continue with stopping this charity?'.tr),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _stopCampaign();
                      Navigator.pop(context);
                      _refreshCampaign();
                    },
                    child:  Text('yes'.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  Text('no'.tr),
                  ),
                ],
              ),

            ],
          );
        });
  }

  Future<void> _deleteCharityConfirm() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('are_you_sure?'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            //doubt
            content: Text(
                'Deleting this charity will completely remove it from the application. Would you like to continue?'.tr),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _deleteCampaign();
                      Navigator.popUntil(context, ModalRoute.withName(OrganizationDashboard.id));
                    },
                    child:  Text('yes'.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  Text('no'.tr),
                  ),
                ],
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
            title:  Center(
              child: Text('are_you_sure?'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            //doubt
            content: Text(
                'Resuming this charity will make it visible to donors again. Once you resume this charity you can deactivate it again from the dashboard or the My Beneficiaries page. Would you like to continue?'.tr),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _resumeCampaign();
                      Navigator.pop(context);
                      _refreshCampaign();
                    },
                    child:  Text('yes'.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  Text('no'.tr),
                  ),
                ],
              ),

            ],
          );
        });
  }

  _campaignFullBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  height: 100,
                  child: Image.asset('assets/DONAID_LOGO.png')
              ),
              Text(widget.campaign.title, style: TextStyle(fontSize: 25)),
              Text(widget.campaign.description, style: TextStyle(fontSize: 18)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$'+f.format(widget.campaign.amountRaised),
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Text(
                        '\$'+f.format(widget.campaign.goalAmount),
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.green),
                      value:
                      (widget.campaign.amountRaised / widget.campaign.goalAmount),
                      minHeight: 25,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: (widget.campaign.amountRaised < widget.campaign.goalAmount) ? [
                  /*The UI for this page consists of several ternary operators to make different checks and
                        * display different UI. If the campaign does not have any contributions yet, it will display the edit and delete buttons
                        * along with the stop/resume button.
                        * If the campaign does have contributions, it will only show the stop/resume charity buttons.
                        * If the campaign has reached its goal amount, it will not show any buttons, and will simply show a message indicating that it has reached
                        * its goal
                        *
                        * Also, if the campaign has passed its end date but has not reached its goal, it will display a message telling the user
                        * that the charity has expired and that they can extend the charity by editing the end date.*/
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 75, 20, 0),
                      child: Material(
                          elevation: 5.0,
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(32.0),
                          child: MaterialButton(
                              child:  Text(
                                'edit'.tr,
                                style: TextStyle(
                                  fontSize: 25,
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
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(32.0),
                          child: MaterialButton(
                              child:  Text(
                                'stop_charity'.tr,
                                style: TextStyle(
                                  fontSize: 25,
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
                              child:  Text(
                                'resume_charity'.tr,
                                style: TextStyle(
                                  fontSize: 25,
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
                                child:  Text(
                                  'note:this_charity_has_expired'.tr,
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
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: widget.campaign.amountRaised == 0 ?
                    Material(
                        elevation: 5.0,
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(32.0),
                        child: MaterialButton(
                            child:  Text(
                              'Delete'.tr,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              _deleteCharityConfirm();
                            }))
                  : Container()),
                ]
                  : [
                    SizedBox(
                      height:50
                    ),
                    Center(
                      child: Text(
                        'This charity has reached it\'s goal!'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                ],
              ),
            ])
          )),
    );
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
