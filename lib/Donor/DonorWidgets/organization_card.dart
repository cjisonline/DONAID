import 'package:donaid/Donor/organization_full_details_screen.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../organization_tab_view.dart';

class OrganizationCard extends StatefulWidget {
  final Organization organization;

  const OrganizationCard(this.organization, {Key? key}) : super(key: key);

  @override
  State<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  User? loggedInUser;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  // Create organization card
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to organization's Tab View screen
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return (OrganizationTabViewScreen(organization: widget.organization));
        })).then((value) {
          setState(() {});
        });
      },
      onLongPress: () {
        // Navigate to organization's Full Details screen
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return (OrganizationFullDetailsScreen(widget.organization));
        })).then((value) {
          setState(() {});
        });
      },
      // Display organization card
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: 275.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey.shade300, width: 2.0)),
            child: Column(children: [
              // Display icon
              (widget.organization.profilePictureDownloadURL == null || widget.organization.profilePictureDownloadURL.toString().isEmpty)
                  ? const Icon(
                      Icons.apartment,
                      color: Colors.blue,
                      size: 50,
                    )
                  : SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.network(
                        widget.organization.profilePictureDownloadURL
                            .toString(),
                        fit: BoxFit.contain,
                      ),
                    ),
              // Display organization's name
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 50,
                  child: Text(widget.organization.organizationName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                ),
              ),
              // Display organization's description
              Padding(
                padding: const EdgeInsets.all(10.0),
                child:
                    Text(widget.organization.organizationDescription.toString(),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        )),
              ),
            ]),
          )),
    );
  }
}
