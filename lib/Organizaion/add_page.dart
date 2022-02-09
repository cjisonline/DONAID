
import 'package:donaid/Organizaion/urgent_case_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'beneficiary_form_screen.dart';
import 'campaign_form_screen.dart';

class addPage extends StatefulWidget {
  static const id = 'add_page';
  const addPage({Key? key}) : super(key: key);

  @override
  _addPage createState() => _addPage();
}
class _addPage extends State<addPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('DONAID'),
          backgroundColor: Colors.blue,
    ),
        backgroundColor: Colors.white.withAlpha(55),
        body: Stack(
            children: [
              ListView(
                  children:<Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(40, 20,0,0),
                      child: Text('Select an item you would like to create: ', style: TextStyle(fontSize: 20,
                          color: Colors.white)),
                    )
                  ]
              ),
              ListView(
                  children:<Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 50,0,0),
                      child: const MyStatelessWidget(),
                    )
                  ]
              )
            ]
        )
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);
  ///Author: Raisa Zaman
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () { Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CampaignForm()),
                  );},
                  child: const Text('Create Campaign'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () { Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UrgentForm()),
                  );},
                  child: const Text('Create Urgent Case'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () { Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BeneficiaryForm()),
                  );},
                  child: const Text('Create Beneficiary'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
