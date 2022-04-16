import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/edit_urgent_case.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'organization_dashboard.dart';


class OrganizationUrgentCaseFullScreen extends StatefulWidget {
  final UrgentCase urgentCase;
  const OrganizationUrgentCaseFullScreen(this.urgentCase, {Key? key}) : super(key: key);

  @override
  _OrganizationUrgentCaseFullScreenState createState() => _OrganizationUrgentCaseFullScreenState();
}

class _OrganizationUrgentCaseFullScreenState extends State<OrganizationUrgentCaseFullScreen> {
  final _firestore = FirebaseFirestore.instance;
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState(){
    super.initState();
  }

  _refreshUrgentCase() async{
    //Refresh urgent case information on the page. This is used for after when an organization edits
    // a resubmits a denied urgent case
    var ret = await _firestore.collection('UrgentCases').where('id',isEqualTo: widget.urgentCase.id).get();

    var doc = ret.docs[0];
    widget.urgentCase.active = doc['active'];
    widget.urgentCase.rejected = doc['rejected'];
    widget.urgentCase.denialReason = doc['denialReason'];
    widget.urgentCase.category = doc['category'];
    widget.urgentCase.description = doc['description'];
    widget.urgentCase.goalAmount = doc['goalAmount'];
    widget.urgentCase.endDate = doc['endDate'];
    widget.urgentCase.title = doc['title'];
    setState(() {
    });

  }

  _stopUrgentCase() async {
    //Toggle the urgent case to inactive. This makes it no longer display to donors
    await _firestore.collection('UrgentCases').doc(widget.urgentCase.id).update({
      'active': false
    });


  }

  _deleteUrgentCase() async {
    //Delete urgent case from database
    await _firestore.collection('UrgentCases').doc(widget.urgentCase.id).delete();
  }

  _resumeUrgentCase() async {
    //Toggle urgent case to active. This makes it display to donors
    await _firestore.collection('UrgentCases').doc(widget.urgentCase.id).update({
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
                      _stopUrgentCase();
                      Navigator.pop(context);
                      _refreshUrgentCase();
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
                      _deleteUrgentCase();
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
                      _resumeUrgentCase();
                      Navigator.pop(context);
                      _refreshUrgentCase();
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

  _urgentCaseFullBody() {
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
                Text(widget.urgentCase.title, style: TextStyle(fontSize: 25)),
                Text(widget.urgentCase.description, style: TextStyle(fontSize: 18),),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$'+f.format(widget.urgentCase.amountRaised),
                          style: const TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        Text(
                          '\$'+f.format(widget.urgentCase.goalAmount),
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
                        (widget.urgentCase.amountRaised / widget.urgentCase.goalAmount),
                        minHeight: 25,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.urgentCase.amountRaised < widget.urgentCase.goalAmount ? [
                  /*The UI for this page consists of several ternary operators to make different checks and
                        * display different UI. If the urgent case does not have any contributions yet, it will display the delete button
                        * along with the stop/resume button.
                        * If the urgent case does have contributions, it will only show the stop/resume charity buttons.
                        * If the urgent case has reached its goal amount, it will not show any buttons, and will simply show a message indicating that it has reached
                        * its goal
                        *
                        * Also, if the urgent case has passed its end date but has not reached its goal, it will display a message telling the user
                        * that the charity has expired. Unlike other charity types, urgent cases cannot be extended because each urgent case requires admin approval*/
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: (widget.urgentCase.active && widget.urgentCase.endDate.compareTo(Timestamp.now()) > 0)
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
                          : (!widget.urgentCase.active && widget.urgentCase.endDate.compareTo(Timestamp.now()) > 0)
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
                          : (widget.urgentCase.endDate.compareTo(Timestamp.now()) < 0)
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            child:  Text(
                              '_note:this_charity_has_expired'.tr,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                          : Container()),
                    Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: widget.urgentCase.amountRaised ==0 ? Material(
                            elevation: 5.0,
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(32.0),
                            child: MaterialButton(
                                child: Text(
                                  'Delete'.tr,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  _deleteCharityConfirm();
                                }))
                            : Container()
                    ),
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
                )
              ])
          )),
    );
  }

  _urgentCaseDeniedBody() {
    /*
    * This UI is used when the urgent case that we are viewing is one that has been denied by the admin.
    * This method will create a UI that tells the organization user the reason for the denial (entered by the admin on the admin panel).
    *
    * Urgent cases that have been denied will be given the option to either delete the urgent case or edit and resubmit for review.
    * */

    return Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  height: 100,
                  child: Image.asset('assets/DONAID_LOGO.png')
              ),
              Text(widget.urgentCase.title, style: TextStyle(fontSize: 25)),
              SizedBox(
                height: 25,
              ),
              Text('Attention:'.tr,style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.red),),
              Text('Your Urgent Case Was Denied'.tr+'\n',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
              Text(
                "After administrative review, your urgent case was denied for the following reason:".tr+'\n',
                style: TextStyle(fontSize: 18),
              ),
              Text(widget.urgentCase.denialReason.toString(),style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
              SizedBox(
                height: 25,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child:Material(
                          elevation: 5.0,
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(32.0),
                          child: MaterialButton(
                              child: Text(
                                'Edit & Resubmit'.tr,
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return EditUrgentCase(urgentCase: widget.urgentCase);
                                })).then((value) => _refreshUrgentCase());
                              }))
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child:  Material(
                          elevation: 5.0,
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(32.0),
                          child: MaterialButton(
                              child: Text(
                                'Delete'.tr,
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                _deleteCharityConfirm();
                              }))
                  ),
                ],
              )
            ])
        ));
  }

  _urgentCasePendingBody() {
    /*
    * This method creates the UI for urgent cases that are pending (have not yet been reviewed by the admin)
    * This UI simply gives a message to the user that the urgent case is pending admin review and it provides the delete
    * button in case the organization wants to remove the urgent case from submission.
    * */
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  height: 100,
                  child: Image.asset('assets/DONAID_LOGO.png')
              ),
              Text(widget.urgentCase.title, style: TextStyle(fontSize: 25)),
              SizedBox(
                height: 25,
              ),
              Text('This urgent case is pending approval.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(
                height: 25,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child:  Material(
                          elevation: 5.0,
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(32.0),
                          child: MaterialButton(
                              child: Text(
                                'Delete'.tr,
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                _deleteCharityConfirm();
                              }))
                  ),
                ],
              )
            ])
        ));
  }

  _buildBody(){
    //This method checks the state of the urgent case (i.e. whether its approved, pending, or rejected)
    //and calls the appropriate method to build the corresponding UI
    if(widget.urgentCase.rejected){
      return _urgentCaseDeniedBody();
    }
    else if(!widget.urgentCase.approved && !widget.urgentCase.rejected){
      return _urgentCasePendingBody();
    }
    else{
      return _urgentCaseFullBody();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.urgentCase.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const OrganizationDrawer(),
      body: _buildBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
