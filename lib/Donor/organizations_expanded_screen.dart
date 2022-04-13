import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/organization_tab_view.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';

class OrganizationsExpandedScreen extends StatefulWidget {
  static const id = 'organizations_expanded_screen';
  const OrganizationsExpandedScreen({Key? key})
      : super(key: key);

  @override
  _OrganizationsExpandedScreenState createState() =>
      _OrganizationsExpandedScreenState();
}

class _OrganizationsExpandedScreenState extends State<OrganizationsExpandedScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Organization> organizations=[];

  @override
  void initState() {
    super.initState();
    _getOrganizations();
  }


  _getOrganizations() async{
      var ret = await _firestore.collection('OrganizationUsers')
          .where('approved', isEqualTo: true)
          .get();

      for(var element in ret.docs){
        Organization organization = Organization(
          organizationName: element.data()['organizationName'],
          uid: element.data()['uid'],
          organizationDescription: element.data()['organizationDescription'],
          country: element.data()['country'],
          gatewayLink: element.data()['gatewayLink'],
        );
        organizations.add(organization);
      }
      setState(() {});
    }

  _organizationsBody() {
    return ListView.builder(
        itemCount: organizations.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return (OrganizationTabViewScreen(organization: organizations[index]));
                    }));
                  },
                  title: Text(organizations[index].organizationName),
                  subtitle: Text(organizations[index].organizationDescription.toString()),
                ),
                SizedBox(height:10)
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('organization'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _organizationsBody(),
      bottomNavigationBar: DonorBottomNavigationBar(),
    );
  }
}
