import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Organization/organization_campaign_full.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//Campaign card display set up
class CampaignCard extends StatefulWidget {
  final Campaign campaign;

  const CampaignCard( this.campaign, {Key? key}) : super(key: key);

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  var f = NumberFormat("###,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //Navigate to the selected Campaign page
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return OrganizationCampaignFullScreen(widget.campaign);
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
              Icon(Icons.campaign,
                    color: Colors.blue,
                    size: 50),
              // Display Campaign title populated from firebase
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50,
                  child: Text(widget.campaign.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      )),
                ),
              ),
              // Display Campaign description populated from firebase
              SizedBox(
                  height: 75.0,
                  child: Text(
                    widget.campaign.description,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  )),
              // Display Campaign amount raised populated from firebase
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$'+f.format(widget.campaign.amountRaised),
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
                // Display Campaign amount raised populated from firebase
                Text(
                  '\$'+f.format(widget.campaign.goalAmount),
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),
              ]),
              // Display Campaign progress bar
              Container(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green),
                    value: (widget.campaign.amountRaised/widget.campaign.goalAmount),
                    minHeight: 10,
                  ),
                ),
              ),
            ]),
          )),
    );
  }
}