import 'package:donaid/Donor/DonorAlertDialog/DonorAlertDialogs.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:flutter/material.dart';

import '../organization_tab_view.dart';

class OrganizationCard extends StatefulWidget {
  final Organization organization;

  const OrganizationCard(this.organization, {Key? key}) : super(key: key);

  @override
  State<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (){
        DonorAlertDialogs.showFullOrganizationDetails(context, widget.organization);
      },
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return (OrganizationTabViewScreen(organization: widget.organization));
        }));
      },
      child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0,0,10.0,10.0),
          child: Container(
            width: 175.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey.shade300, width: 2.0)),
            child: Column(children: [
                (widget.organization.profilePictureDownloadURL != null && widget.organization.profilePictureDownloadURL.toString() != ""
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        widget.organization.profilePictureDownloadURL!.toString(),
                        fit: BoxFit.contain,
                      ),),
                  ],)
              : const Icon(
                  Icons.apartment,
                  color: Colors.blue,
                  size: 60,
                )),
              Container(
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10.0,0,10.0,10.0),
                        child: Text(widget.organization.organizationName,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            )),
                      ),
                    ),
                    Text(widget.organization.organizationDescription.toString(),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        )),
                  ],
                ),
              ),

            ]),
          )),
    );
  }
}
