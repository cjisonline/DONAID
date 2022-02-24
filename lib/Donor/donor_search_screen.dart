import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/donor_dashboard.dart';
import 'package:donaid/Models/Donor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'donor_profile.dart';

class DonorSearchScreen extends StatefulWidget {
  static const id = 'donor_search_screen';

  const DonorSearchScreen({Key? key}) : super(key: key);

  @override
  _DonorSearchScreenState createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  TextEditingController? _searchController;
  String searchQuery = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Search'),
      ),
      body: _body(),
      bottomNavigationBar: const DonorBottomNavigationBar(),
    );
  }

  Widget _buildSearchField() {
    _searchController = TextEditingController();
    return Container(
        padding: const EdgeInsets.all(8.0),
        width: 300,
        child: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              )),
          onSaved: (value) {
            searchQuery = value!;
          },
        ));
  }

  _searchQuery(){

  }

  _body() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
                  _buildSearchField(),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {

                    
                    },
                    icon: const Icon(Icons.search, color: Colors.blue, size: 40),
                  ),
                ],
              )
          ),
        ),
      );
  }
}
