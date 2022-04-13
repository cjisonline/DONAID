import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/organization_urgentcase_full.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Urgent Case card display set up
class UrgentCaseCard extends StatefulWidget {
  final UrgentCase urgentCase;

  const UrgentCaseCard( this.urgentCase, {Key? key}) : super(key: key);

  @override
  State<UrgentCaseCard> createState() => _UrgentCaseCardState();
}

class _UrgentCaseCardState extends State<UrgentCaseCard> {
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        //Navigate to the selected Urgent Case page
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return OrganizationUrgentCaseFullScreen(widget.urgentCase);
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
              // Display Urgent Case title populated from firebase
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50,
                  child: Text(widget.urgentCase.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      )),
                ),
              ),
              // Display Urgent case description populated from firebase
              SizedBox(
                  height: 75.0,
                  child: Text(
                    widget.urgentCase.description,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  )),
              // Display Urgent case amount raised populated from firebase
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$'+f.format(widget.urgentCase.amountRaised),
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
                // Display Urgent case amount raised populated from firebase
                Text(
                  '\$'+f.format(widget.urgentCase.goalAmount),
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),
              ]),
              // Display Urgent case progress bar
              Container(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green),
                    value: (widget.urgentCase.amountRaised/widget.urgentCase.goalAmount),
                    minHeight: 10,
                  ),
                ),
              ),
            ]),
          )),
    );
  }
}