import 'package:flutter/material.dart';
///Author: Raisa Zaman
import '../home_screen.dart';
import 'campaign_form_screen.dart';

class CampaignList extends StatefulWidget {
  static const id = 'campaign_list_screen';
  const CampaignList({Key? key}) : super(key: key);

  @override
  _CampaignList createState() => _CampaignList();
}

class _CampaignList extends State<CampaignList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DONAID'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add, size: 30,), onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CampaignForm()),
            );}),
        ],
      ),
        backgroundColor: Colors.white.withAlpha(55),
        body: Stack(
            children: [
              ListView(
                  children:<Widget>[
                    Container(
                        padding: EdgeInsets.fromLTRB(20, 20,0,0),
                        child: Text('My Campaigns', style: TextStyle(fontSize: 20,
                            color: Colors.white))
                    )
                  ]
              )
            ]
        )
    );
  }
}