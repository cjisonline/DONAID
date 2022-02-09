import 'package:donaid/Organization/urgent_case_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/add_categorys.dart';
import 'add_page.dart';
import 'beneficiary_list_screen.dart';
import 'campaign_list_screen.dart';
import 'search_screen.dart';
import '../home_screen.dart';

///Author: Raisa Zaman
///Main is here for testing purposes

class OrganizationDashboard extends StatefulWidget {
  static const id = 'organization_dashboard';
  const OrganizationDashboard({Key? key}) : super(key: key);

  @override
  _OrganizationDashboardState createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<OrganizationDashboard> {
  // This OrganizationWidget is the root of your application.
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser(){
    loggedInUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bottom Nav Bar V2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BottomNavBarV2(),
    );
  }
}

class BottomNavBarV2 extends StatefulWidget {
  @override
  _BottomNavBarV2State createState() => _BottomNavBarV2State();
}

class _BottomNavBarV2State extends State<BottomNavBarV2> {
  int currentIndex = 0;
  final _auth = FirebaseAuth.instance;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    print(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8.0,
                    left: 4.0,
                    child: Text(
                      "Organization",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text("About"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Help"),
              onTap: () {},
            ),
            ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () {
                  Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.id));
                  _auth.signOut();
                }),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('DONAID'),
      ),
      backgroundColor: Colors.white.withAlpha(55),
      body: Stack(
        children: [
          ListView(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Text('My Campaigns',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                icon: Text('See more >',
                    style: TextStyle(fontSize: 14, color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CampaignList()),
                  );
                },
              ),
              Category(),
              Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Text('My Urgent Cases',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                icon: Text('See more >',
                    style: TextStyle(fontSize: 14, color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UrgentList()),
                  );
                },
              ),
              Category(),
              Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Text('My Beneficiary',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                icon: Text('See more >',
                    style: TextStyle(fontSize: 14, color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BeneficiaryList()),
                  );
                },
              ),
              Category(),
              //AllProducts(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
                width: size.width,
                height: 80,
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    CustomPaint(
                      size: Size(size.width, 80),
                      painter: BNBCustomPainter(),
                    ),
                    Center(
                      heightFactor: 0.6,
                      child: FloatingActionButton(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.add),
                          elevation: 0.1,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => addPage()),
                            );
                          }),
                    ),
                    Container(
                      width: size.width,
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.home,
                              color: currentIndex == 0
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(0);
                              {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrganizationDashboard()),
                                );
                              }
                            },
                            splashColor: Colors.white,
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.search,
                                color: currentIndex == 1
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(1);
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchPage()),
                                  );
                                }
                              }),
                          Container(
                            width: size.width * 0.20,
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: currentIndex == 2
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(2);
                              }),
                          IconButton(
                              icon: Icon(
                                Icons.message,
                                color: currentIndex == 3
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(3);
                              }),
                        ],
                      ),
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
