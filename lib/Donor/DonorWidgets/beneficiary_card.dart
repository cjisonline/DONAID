import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorAlertDialog/DonorAlertDialogs.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../beneficiary_donate_screen.dart';
import 'package:get/get.dart';

class BeneficiaryCard extends StatefulWidget {
  final Beneficiary beneficiary;

  const BeneficiaryCard( this.beneficiary, {Key? key}) : super(key: key);

  @override
  State<BeneficiaryCard> createState() => _BeneficiaryCardState();
}

class _BeneficiaryCardState extends State<BeneficiaryCard> {
  Organization? organization;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _getBeneficiaryOrganization();
  }


  _getBeneficiaryOrganization() async{

      var ret = await _firestore.collection('OrganizationUsers')
          .where('uid', isEqualTo: widget.beneficiary.organizationID)
          .get();

      for(var element in ret.docs){
        organization = Organization(
          organizationName: element.data()['organizationName'],
          uid: element.data()['uid'],
          organizationDescription: element.data()['organizationDescription'],
          country: element.data()['country'],
          gatewayLink: element.data()['gatewayLink'],
        );
      }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: 275.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey.shade300, width: 2.0)),

          child: Column(children: [
            Icon(Icons.person, color: Colors.blue, size: 40,),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(widget.beneficiary.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
            ),
            SizedBox(
                height: 75.0,
                child: Text(
                  widget.beneficiary.biography,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('\$'+f.format(widget.beneficiary.amountRaised),
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black, fontSize: 15)),
              Text(
              '\$'+f.format(widget.beneficiary.goalAmount),
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
            ]),
            Container(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green),
                  value: (widget.beneficiary.amountRaised/widget.beneficiary.goalAmount),
                  minHeight: 10,
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        if(organization?.country =='United States'){
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return (BeneficiaryDonateScreen(widget.beneficiary));
                          })).then((value){
                            setState(() {

                            });
                          });
                        }
                        else{
                          DonorAlertDialogs.paymentLinkPopUp(context, organization!, _auth.currentUser!.uid);
                        }

                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                         const Icon(Icons.favorite,
                              color: Colors.white, size: 20),
                        Container(
                          margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                          child:  Text('donate'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              )),
                        )
                      ]),
                    ),
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                )),

          ]),
        ));
  }
}
