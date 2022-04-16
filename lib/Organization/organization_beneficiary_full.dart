import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:donaid/Organization/organization_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_beneficiary.dart';
import 'package:get/get.dart';


class OrganizationBeneficiaryFullScreen extends StatefulWidget {
  final Beneficiary beneficiary;
  const OrganizationBeneficiaryFullScreen(this.beneficiary, {Key? key}) : super(key: key);

  @override
  _OrganizationBeneficiaryFullScreenState createState() => _OrganizationBeneficiaryFullScreenState();
}

class _OrganizationBeneficiaryFullScreenState extends State<OrganizationBeneficiaryFullScreen> {
  final _firestore = FirebaseFirestore.instance;
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState(){
    super.initState();
    _refreshBeneficiary();
  }

  _refreshBeneficiary() async{
    //Refreshes the beneficiary information the page. This is used after the user edits a beneficiary
    var ret = await _firestore.collection('Beneficiaries').where('id',isEqualTo: widget.beneficiary.id).get();

    var doc = ret.docs[0];
    widget.beneficiary.name = doc['name'];
    widget.beneficiary.biography = doc['biography'];
    widget.beneficiary.category = doc['category'];
    widget.beneficiary.goalAmount = doc['goalAmount'].toDouble();
    widget.beneficiary.endDate = doc['endDate'];
    widget.beneficiary.active = doc['active'];
    setState(() {
    });

  }

  _stopBeneficiary() async {
    //Toggle the beneficiary to inactive. This makes it no longer display to donor users
    await _firestore.collection('Beneficiaries').doc(widget.beneficiary.id).update({
      'active': false
    });


  }

  _deleteBeneficiary() async {
    //Delete beneficiary from database
    await _firestore.collection('Beneficiaries').doc(widget.beneficiary.id).delete();
  }

  _resumeBeneficiary() async {
    //Toggle beneficiary to active. This will make it display to donors again
    await _firestore.collection('Beneficiaries').doc(widget.beneficiary.id).update({
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
                      _stopBeneficiary();
                      Navigator.pop(context);
                      _refreshBeneficiary();
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
                      _deleteBeneficiary();
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
            title: Center(
              child: Text('are_you_sure?'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: Text(
                'Resuming this charity will make it visible to donors again. Once you resume this charity you can deactivate it again from the dashboard or the My Beneficiaries page. Would you like to continue?'.tr),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _resumeBeneficiary();
                      Navigator.pop(context);
                      _refreshBeneficiary();

                    },
                    child: Text('yes'.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('no'.tr),
                  ),
                ],
              ),

            ],
          );
        });
  }

  _beneficiaryFullBody() {
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
                SizedBox(height:10),
                Text(widget.beneficiary.name, style: TextStyle(fontSize: 25),),
                Text(widget.beneficiary.biography, style: TextStyle(fontSize: 18),),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$'+f.format(widget.beneficiary.amountRaised),
                          style: const TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        Text(
                          '\$'+f.format(widget.beneficiary.goalAmount),
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
                        (widget.beneficiary.amountRaised / widget.beneficiary.goalAmount),
                        minHeight: 25,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.beneficiary.amountRaised < widget.beneficiary.goalAmount ? [
                    /*The UI for this page consists of several ternary operators to make different checks and
                        * display different UI. If the beneficiary does not have any contributions yet, it will display the edit and delete buttons
                        * along with the stop/resume button.
                        * If the beneficiary does have contributions, it will only show the stop/resume charity buttons.
                        * If the beneficiary has reached its goal amount, it will not show any buttons, and will simply show a message indicating that it has reached
                        * its goal
                        *
                        * Also, if the beneficiary has passed its end date but has not reached its goal, it will display a message telling the user
                        * that the charity has expired and that they can extend the charity by editing the end date.*/
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 75, 20, 0),
                      child: Material(
                          elevation: 5.0,
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(32.0),
                          child: MaterialButton(
                              child: Text(
                                'edit'.tr,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return EditBeneficiary(beneficiary: widget.beneficiary);
                                })).then((value) => _refreshBeneficiary());
                              })),),
                    Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: (widget.beneficiary.active && widget.beneficiary.endDate.compareTo(Timestamp.now()) > 0)
                            ? Material(
                            elevation: 5.0,
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(32.0),
                            child: MaterialButton(
                                child: Text(
                                  'stop_charity'.tr,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  _stopCharityConfirm();

                                }))
                            : (!widget.beneficiary.active && widget.beneficiary.endDate.compareTo(Timestamp.now()) > 0)
                            ? Material(
                            elevation: 5.0,
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(32.0),
                            child: MaterialButton(
                                child: Text(
                                  'resume_charity'.tr,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  _resumeCharityConfirm();
                                }))
                            : (widget.beneficiary.endDate.compareTo(Timestamp.now()) < 0)
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              child: Text(
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
                      child: widget.beneficiary.amountRaised ==0 ? Material(
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
                ),
              ])
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.beneficiary.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const OrganizationDrawer(),
      body: _beneficiaryFullBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
