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
