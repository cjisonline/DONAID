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
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return (OrganizationTabViewScreen(organization: widget.organization));
        })).then((value){
          setState(() {
            
          });
        });
      },
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: 175.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey.shade300, width: 2.0)),
            child: Column(children: [
              const Icon(
                Icons.apartment,
                color: Colors.blue,
                size: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(widget.organization.organizationName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(widget.organization.organizationDescription.toString(),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 3,
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
