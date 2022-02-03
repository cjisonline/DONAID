import 'package:flutter/material.dart';

class DonorDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';
  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
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
