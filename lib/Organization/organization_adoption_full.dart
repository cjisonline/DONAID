import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Adoption.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'edit_adoption.dart';
import 'organization_dashboard.dart';

class OrganizationAdoptionFullScreen extends StatefulWidget {
  final Adoption adoption;
  const OrganizationAdoptionFullScreen(this.adoption, {Key? key})
      : super(key: key);

  @override
  _OrganizationAdoptionFullScreenState createState() =>
      _OrganizationAdoptionFullScreenState();
}

class _OrganizationAdoptionFullScreenState
    extends State<OrganizationAdoptionFullScreen> {
  final _firestore = FirebaseFirestore.instance;
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _refreshAdoption();
  }

  _refreshAdoption() async {
    var ret = await _firestore
        .collection('Adoptions')
        .where('id', isEqualTo: widget.adoption.id)
        .get();

    var doc = ret.docs[0];
    widget.adoption.name = doc['name'];
    widget.adoption.biography = doc['biography'];
    widget.adoption.category = doc['category'];
    widget.adoption.goalAmount = doc['goalAmount'].toDouble();
    widget.adoption.active = doc['active'];
    setState(() {});
  }

  _stopAdoption() async {
    await _firestore
        .collection('Adoptions')
        .doc(widget.adoption.id)
        .update({'active': false});
  }

  _resumeAdoption() async {
    await _firestore
        .collection('Adoptions')
        .doc(widget.adoption.id)
        .update({'active': true});
  }

  _deleteAdoption() async {
    await _firestore.collection('Adoptions').doc(widget.adoption.id).delete();
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
            // TODO: edit this message
            content: const Text(
                'Stopping this charity will make it not visible to donors. Once you stop this charity '
                'you can reactivate it from the Inactive Charities page. Would you like to continue'
                'with stopping this charity?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _stopAdoption();
                    Navigator.pop(context);
                    _refreshAdoption();
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
            // TODO: edit this message
            content: const Text(
                'Resuming this charity will make it visible to donors again. Once you resume this charity '
                'you can deactivate it again from the dashboard or the My Beneficiaries page. Would you like '
                'to continue?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _resumeAdoption();
                    Navigator.pop(context);
                    _refreshAdoption();
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


  Future<void> _deleteCharityConfirm() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('are_you_sure?'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            //doubt
            content: Text(
                'Deleting this charity will completely remove it from the application. Would you like to continue?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _deleteAdoption();
                    Navigator.popUntil(context, ModalRoute.withName(OrganizationDashboard.id));
                  },
                  child:  Text('yes'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text('no'),
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  height: 100, child: Image.asset('assets/DONAID_LOGO.png')),
              SizedBox(height: 10),
              Text(
                widget.adoption.name,
                style: TextStyle(fontSize: 25),
              ),
              Text(
                widget.adoption.biography,
                style: TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$' + f.format(widget.adoption.amountRaised),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Text(
                        '\$' + f.format(widget.adoption.goalAmount),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
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
                      value: (widget.adoption.amountRaised /
                          widget.adoption.goalAmount),
                      minHeight: 25,
                    ),
                  ),
                ),
              ),
              Column(
                  children: (widget.adoption.amountRaised <
                          widget.adoption.goalAmount)
                      ? [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widget.adoption.amountRaised == 0
                                ? [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 75, 20, 0),
                                      child: Material(
                                          elevation: 5.0,
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                          child: MaterialButton(
                                              child: const Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return EditAdoption(
                                                      adoption:
                                                          widget.adoption);
                                                })).then((value) =>
                                                    _refreshAdoption());
                                              })),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 0),
                                        child: (widget.adoption.active)
                                            ? Material(
                                                elevation: 5.0,
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(32.0),
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
                                            : (!widget.adoption.active)
                                                ? Material(
                                                    elevation: 5.0,
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32.0),
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
                                                : Container()),
Container(
  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
  child:  Material(
      elevation: 5.0,
      color: Colors.red,
      borderRadius: BorderRadius.circular(32.0),
      child: MaterialButton(
          child: Text(
            'Delete',
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            _deleteCharityConfirm();
          }
)))
                                  ]
                                : [
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 0),
                                        child: (widget.adoption.active)
                                            ? Material(
                                                elevation: 5.0,
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(32.0),
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
                                            : (!widget.adoption.active)
                                                ? Material(
                                                    elevation: 5.0,
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32.0),
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
                                                : Container())
                                  ],
                          )
                        ]
                      : [
                          const SizedBox(height: 50),
                          const Center(
                            child: Text(
                              'This charity has reached it\'s goal!',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )
                        ]),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adoption.name),
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
