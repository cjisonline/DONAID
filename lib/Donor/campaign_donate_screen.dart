import 'package:donaid/Models/Campaign.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';

class CampaignDonateScreen extends StatefulWidget {
  Campaign campaign;
  CampaignDonateScreen(this.campaign, {Key? key}) : super(key: key);

  @override
  _CampaignDonateScreenState createState() => _CampaignDonateScreenState();
}

class _CampaignDonateScreenState extends State<CampaignDonateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showLoadingSpinner = false;

  _campaignDonateBody() {
    return ModalProgressHUD(
      inAsyncCall: showLoadingSpinner,
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(widget.campaign.title),
          Text(widget.campaign.description),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(widget.campaign.amountRaised / widget.campaign.goalAmount) * 100}%',
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  Text(
                    '\$${widget.campaign.goalAmount}',
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ]),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              value:
                  (widget.campaign.amountRaised / widget.campaign.goalAmount),
              minHeight: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onChanged: (value) {
                          //TODO: Implement onChanged
                        },
                        validator: (value) {
                          //TODO: Implement validator
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            label: Center(
                              child: RichText(
                                  text: TextSpan(
                                text: 'Donation Amount',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 20.0),
                              )),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32.0)),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5.0,
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(32.0),
                        child: MaterialButton(
                          child: const Text(
                            'Donate',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                showLoadingSpinner = true;
                              });
                              //TODO:Implement Donate function
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )),
          )
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate - ${widget.campaign.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      drawer: const DonorDrawer(),
      body: _campaignDonateBody(),
      bottomNavigationBar: const DonorBottomNavigationBar(),
    );
  }
}
