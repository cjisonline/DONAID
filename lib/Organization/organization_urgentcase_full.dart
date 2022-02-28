import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_bottom_navigation.dart';
import 'package:donaid/Organization/OrganizationWidget/organization_drawer.dart';
import 'package:flutter/material.dart';

class OrganizationUrgentCaseFullScreen extends StatefulWidget {
  final UrgentCase urgentCase;
  const OrganizationUrgentCaseFullScreen(this.urgentCase, {Key? key}) : super(key: key);

  @override
  _OrganizationUrgentCaseFullScreenState createState() => _OrganizationUrgentCaseFullScreenState();
}

class _OrganizationUrgentCaseFullScreenState extends State<OrganizationUrgentCaseFullScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState(){
    super.initState();
    _refreshUrgentCase();
  }

  _refreshUrgentCase() async{
    var ret = await _firestore.collection('UrgentCases').where('id',isEqualTo: widget.urgentCase.id).get();

    var doc = ret.docs[0];
    widget.urgentCase.active = doc['active'];
    setState(() {
    });

  }

  _stopUrgentCase() async {
    await _firestore.collection('UrgentCases').doc(widget.urgentCase.id).update({
      'active': false
    });


  }

  _resumeUrgentCase() async {
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
            title: const Center(
              child: Text('Are You Sure?'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: const Text(
                'Stopping this charity will make it not visible to donors. Once you stop this charity '
                    'you can reactivate it from the Inactive Charities page. Would you like to continue '
                    'with stopping this charity?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _stopUrgentCase();
                    Navigator.pop(context);
                    _refreshUrgentCase();
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
                    'you can deactivate it again from the dashboard or the My Urgent Cases page. Would you like '
                    'to continue?'),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    _resumeUrgentCase();
                    Navigator.pop(context);
                    _refreshUrgentCase();
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

  _urgentCaseFullBody() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.urgentCase.title),
              Text(widget.urgentCase.description),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(widget.urgentCase.amountRaised.toStringAsFixed(2))}',
                        style: const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                      Text(
                        '\$${widget.urgentCase.goalAmount.toStringAsFixed(2)}',
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
                  (widget.urgentCase.amountRaised / widget.urgentCase.goalAmount),
                  minHeight: 10,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: (widget.urgentCase.active && widget.urgentCase.endDate.compareTo(Timestamp.now()) > 0)
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
                        : (!widget.urgentCase.active && widget.urgentCase.endDate.compareTo(Timestamp.now()) > 0)
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
                        : (widget.urgentCase.endDate.compareTo(Timestamp.now()) < 0)
                        ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Container(
                          child: const Text(
                            'Note: This charity has expired.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                        : Container()),
                ],
              )
            ])
        ));
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
      body: _urgentCaseFullBody(),
      bottomNavigationBar: const OrganizationBottomNavigation(),
    );
  }
}
