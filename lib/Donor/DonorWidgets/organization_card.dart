import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';

import '../organization_tab_view.dart';
import '../updateFavorite.dart';

class OrganizationCard extends StatefulWidget {
  final Organization organization;

  const OrganizationCard(this.organization, {Key? key}) : super(key: key);

  @override
  State<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  final _firestore = FirebaseFirestore.instance;
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
            width: 275.0,
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FavoriteButton(
                  isFavorite: false,
                  valueChanged: (_isFavorite) {
                    updateFavorites(loggedInUser!.uid.toString(),"hfkdhjdhfkjsdfh");
                    print('Is Favorite : $_isFavorite');
                  },
                ),
              ),

            ]),
          )),
    );
  }
}
