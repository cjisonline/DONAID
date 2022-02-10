import 'package:flutter/material.dart';

import 'organization_layout.dart';
import 'urgent_case_layout.dart';

class DonorDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';

  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  String placeholderText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod "
      "tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim"
      " veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea "
      "commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit "
      "esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat "
      "non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: _drawer(),
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'See more >',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 75.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Row(children: [
                              IconButton(
                                enableFeedback: false,
                                onPressed: () {},
                                icon: const Icon(Icons.fastfood,
                                    color: Colors.white, size: 20),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 0.0, right: 10.0),
                                child: Text('Food',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    )),
                              )
                            ]),
                          ))),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Row(children: [
                              IconButton(
                                enableFeedback: false,
                                onPressed: () {},
                                icon: const Icon(Icons.health_and_safety,
                                    color: Colors.white, size: 20),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 0.0, right: 10.0),
                                child: Text('Health',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    )),
                              )
                            ]),
                          ))),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Row(children: [
                              IconButton(
                                enableFeedback: false,
                                onPressed: () {},
                                icon: const Icon(Icons.book,
                                    color: Colors.white, size: 20),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 0.0, right: 10.0),
                                child: Text('Education',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    )),
                              )
                            ]),
                          ))),
                ],
              )),

          // organization list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Organizations',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'See more >',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 150.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  OrganizationSection(
                      Icon(Icons.apartment, color: Colors.white, size: 50),
                      "Org 1",
                      "Category 1")
                ],
              )),

          // urgent case list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urgent Cases',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'See more >',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ]),
            ),
          ),
          SizedBox(
              height: 325.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  UrgentCaseSection(
                      Icon(Icons.apartment, color: Colors.white, size: 50),
                      "Urgent Case 1",
                      placeholderText),
                  UrgentCaseSection(
                      Icon(Icons.apartment, color: Colors.white, size: 50),
                      "Urgent Case 2",
                      placeholderText)
                ],
              )),
        ],
      ),
    );
  }

  _bottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.home, color: Colors.white, size: 35),
            ),
            Text('Home',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 35,
              ),
            ),
            Text('Search',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 35),
            ),
            Text('Notifications',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              enableFeedback: false,
              onPressed: () {},
              icon: const Icon(Icons.message, color: Colors.white, size: 35),
            ),
            Text('Messages',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ]),
        ],
      ),
    );
  }

  _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('DONAID',
                style: TextStyle(color: Colors.white, fontSize: 30)),
          ),
          ListTile(
            title: const Text('Favorites', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Edit Profile', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title:
                const Text('Donations History', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Log Out', style: TextStyle(fontSize: 20)),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
