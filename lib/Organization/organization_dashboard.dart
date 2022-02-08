import 'package:flutter/material.dart';

class OrganizationDashboard extends StatefulWidget {
  static const id = 'organization_dashboard';
  const OrganizationDashboard({Key? key}) : super(key: key);

  @override
  _OrganizationDashboardState createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<OrganizationDashboard> {
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
