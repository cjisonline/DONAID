import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';
import 'organization_dashboard.dart';

class SearchPage extends StatefulWidget {
  static const id = 'organization_dashboard';
  const SearchPage({Key? key}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}
class _NavState extends State<SearchPage> {
  // This OrganizationWidget is the root of your application.
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

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }
  TextEditingController _searchController = TextEditingController();

  @override
  void initState () {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged (){
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
              leading: Icon(Icons.not_interested),
              title: Text("Report"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Help"),
              onTap: () {},
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('DONAID'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.logout, size: 30,), onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );}),
        ],
      ),
      backgroundColor: Colors.white.withAlpha(55),
      body: Stack(
        children: [
          ListView(
            children:<Widget>[
              TextField (
                controller: _searchController,
                decoration: InputDecoration(filled: true, fillColor: Colors.white,
                    hintText: 'Search',focusedBorder:OutlineInputBorder (borderSide:
                    const BorderSide (color: Colors.blue, width: 2.0), borderRadius:
                    BorderRadius.circular (25.0),),
                    prefixIcon: Icon(Icons.search)
                ),
              ),
              
              Text('Results', style: TextStyle(fontSize: 40, color: Colors.white),),
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
                      child: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add), elevation: 0.1, onPressed: () {}),
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
                                color: currentIndex == 1 ? Colors.blue : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(1);
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => OrganizationDashboard()),
                                  );}
                              }),
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              color: currentIndex == 0 ? Colors.blue : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(0);
                              {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SearchPage()),
                                );}
                            },
                            splashColor: Colors.white,
                          ),
                          Container(
                            width: size.width * 0.20,
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: currentIndex == 2 ? Colors.blue : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(2);
                              }),
                          IconButton(
                              icon: Icon(
                                Icons.message,
                                color: currentIndex == 3 ? Colors.blue : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                setBottomBarIndex(3);
                              }),
                        ],
                      ),
                    )
                  ],
                )
            ),
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
    path.arcToPoint(Offset(size.width * 0.60, 20), radius: Radius.circular(20.0), clockwise: false);
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