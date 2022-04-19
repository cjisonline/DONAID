import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

/*This file contains a few static methods for actions that are used repeatedly throughout the application.
* the createGatewayVisit method is one of the most important. createGatewayVisit is called whenever a donor user clicks on
* the payment gateway link for an organization (the link is displayed by the paymentLinkPopUp method).
*
* createGatewayVisit will create record for each time the payment gateway is visited by donor users. This is then shown in the
* Gateway Visits page for foreign organizations where they can confirm/deny that a visit resulted in a donation.*/
class DonorAlertDialogs{
  static createGatewayVisit(Organization organization, String uidDonor, Map<String, dynamic> charity) async{
    final _firestore = FirebaseFirestore.instance;

    if(FirebaseAuth.instance.currentUser?.email != null) {
      try {
        var docRef = await _firestore.collection('GatewayVisits').add({});

        await _firestore.collection('GatewayVisits').doc(docRef.id).set({
          'organizationID': organization.uid,
          'donorID': uidDonor,
          'visitedAt': FieldValue.serverTimestamp(),
          'id': docRef.id,
          'charityType': charity['charityType'],
          'charityTitle': charity['charityTitle'],
          'charityID': charity['charityID'],
          'read': false,
          'guest':false
        });
      }
      catch (e) {
        print(e);
      }
    }
    else{

      try {
        var docRef = await _firestore.collection('GatewayVisits').add({});

        await _firestore.collection('GatewayVisits').doc(docRef.id).set({
          'organizationID': organization.uid,
          'donorID': uidDonor,
          'visitedAt': FieldValue.serverTimestamp(),
          'id': docRef.id,
          'charityType': charity['charityType'],
          'charityTitle': charity['charityTitle'],
          'charityID': charity['charityID'],
          'read': false,
          'guest':true
        });
      }
      catch (e) {
        print(e);
      }
    }


  }

  static paymentLinkPopUp(context, Organization organization, String uidDonor, Map<String, dynamic> charity){
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Center(
              child: Text('detour!'.tr),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: Linkify(
              onOpen: (link) async {
                print('IN ON OPEN');
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                  await createGatewayVisit(organization, uidDonor, charity);
                } else {
                  throw 'Could not launch $link';
                }
              },
             //doubt
              text: "the_organization_that_created".tr +'\n\n ${organization.gatewayLink}',
              linkStyle: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text('ok'.tr),
                ),
              ),
            ],
          );
        });
  }
}