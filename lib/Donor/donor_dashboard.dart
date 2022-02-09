import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonorDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';
  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser() async {
    try{
      final user = _auth.currentUser;
      if(user != null){
        loggedInUser = user;
        print('Logged in user: ${loggedInUser?.email}');
      }
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: (){

          },
        ),
      ),
    );
  }
}
