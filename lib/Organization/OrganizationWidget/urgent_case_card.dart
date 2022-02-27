import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/organization_urgentcase_full.dart';
import 'package:flutter/material.dart';

class UrgentCaseCard extends StatefulWidget {
  final UrgentCase urgentCase;

  const UrgentCaseCard( this.urgentCase, {Key? key}) : super(key: key);

  @override
  State<UrgentCaseCard> createState() => _UrgentCaseCardState();
}

class _UrgentCaseCardState extends State<UrgentCaseCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return OrganizationUrgentCaseFullScreen(widget.urgentCase);
        })).then((value){
          setState(() {});
        });
      },
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: 275.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.grey.shade300, width: 2.0)),

            child: Column(children: [
              IconButton(
                enableFeedback: false,
                onPressed: () {},
                icon: const Icon(Icons.apartment,
                    color: Colors.blue,
                    size: 50),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(widget.urgentCase.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$${widget.urgentCase.amountRaised.toStringAsFixed(2)}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
                Text(
                  '\$${widget.urgentCase.goalAmount}',
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),
              ]),
              LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
                value: (widget.urgentCase.amountRaised/widget.urgentCase.goalAmount),
                minHeight: 10,
              ),
            ]),
          )),
    );
  }
}