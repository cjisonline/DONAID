import 'package:donaid/Models/Beneficiary.dart';
import 'package:flutter/material.dart';

class BeneficiaryCard extends StatefulWidget {
  final Beneficiary beneficiary;

  const BeneficiaryCard( this.beneficiary, {Key? key}) : super(key: key);

  @override
  State<BeneficiaryCard> createState() => _BeneficiaryCardState();
}

class _BeneficiaryCardState extends State<BeneficiaryCard> {
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
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.apartment,
                  color: Colors.blue,
                  size: 50),
            ),
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
              Text(('\$${widget.beneficiary.amountRaised.toStringAsFixed(2)}'),
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black, fontSize: 15)),
              Text(
                '\$${widget.beneficiary.goalAmount.toStringAsFixed(2)}',
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
            ]),
            LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor),
              value: (widget.beneficiary.amountRaised/widget.beneficiary.goalAmount),
              minHeight: 10,
            ),
          ]),
        ));
  }
}