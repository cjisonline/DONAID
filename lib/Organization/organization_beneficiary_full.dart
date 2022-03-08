import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_beneficiary.dart';


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
    await _firestore.collection('Beneficiaries').doc(widget.beneficiary.id).update({
      'active': false
    });


  }

  _resumeBeneficiary() async {
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
            title: const Center(
              child: Text('Are You Sure?'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'Stopping this charity will make it not visible to donors. Once you stop this charity '
                    'you can reactivate it from the Inactive Charities page. Would you like to continue'
                    'with stopping this charity?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _stopBeneficiary();
                    Navigator.pop(context);
                    _refreshBeneficiary();
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
                    'you can deactivate it again from the dashboard or the My Beneficiaries page. Would you like '
                    'to continue?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _resumeBeneficiary();
                    Navigator.pop(context);
                    _refreshBeneficiary();

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

  _beneficiaryFullBody() {
    return Center(
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
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 75, 20, 0),
                    child: Material(
                        elevation: 5.0,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(32.0),
                        child: MaterialButton(
                            child: const Text(
                              'Edit',
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
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(32.0),
                          child: MaterialButton(
                              child: const Text(
                                'Stop Charity',
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
                              child: const Text(
                                'Resume Charity',
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
