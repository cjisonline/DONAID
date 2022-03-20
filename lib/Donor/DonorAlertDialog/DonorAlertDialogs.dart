import 'package:donaid/Models/Organization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class DonorAlertDialogs{
  static paymentLinkPopUp(context, Organization organization){
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
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  throw 'Could not launch $link';
                }
              },
             //doubt
              text: "the_organization_that_created"
                  ' A link to the organization\'s payment gateway is below.\n\n ${organization.gatewayLink}',
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

  static Future<void> showFullOrganizationDetails(context, Organization organization) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(organization.organizationName),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            content: Text(organization.organizationDescription.toString()),
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