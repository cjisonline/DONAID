import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Organization/organization_beneficiary_full.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Beneficiary card display set up
class BeneficiaryCard extends StatefulWidget {
  final Beneficiary beneficiary;

  const BeneficiaryCard( this.beneficiary, {Key? key}) : super(key: key);

  @override
  State<BeneficiaryCard> createState() => _BeneficiaryCardState();
}

class _BeneficiaryCardState extends State<BeneficiaryCard> {
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //Navigate to the selected beneficiary page
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return OrganizationBeneficiaryFullScreen(widget.beneficiary);
        })).then((value){
          setState(() {});
        });
      },
      //Display card
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: 275.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey.shade300, width: 2.0)),
          // Display icon
            child: Column(children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {},
                icon: const Icon(Icons.apartment,
                    color: Colors.blue,
                    size: 50),
              ),
              // Display beneficiary name populated from firebase
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(widget.beneficiary.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
              // Display beneficiary bio populated from firebase
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
              // Display beneficiary amount raised populated from firebase
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$'+f.format(widget.beneficiary.amountRaised),
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
                // Display beneficiary goal amount populated from firebase
                Text(
                  '\$'+f.format(widget.beneficiary.goalAmount),
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),
              ]),
              // Display beneficiary progress bar
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
            ]),
          )),
    );
  }
}