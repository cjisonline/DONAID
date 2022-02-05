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
          icon: const Icon(Icons.menu),
          onPressed: (){

          },
        ),
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
        child:
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
              'Charity Campaign',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.start,
            ),
              Text(
                'See more >',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.start,
              ),
          ]
          ),
        ),
      ),
          SizedBox(
            height: 150.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  width: 125.0,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child :  Column(
                      children: [
                        IconButton(
                          enableFeedback: false,
                          onPressed: () {},
                          icon: const Icon(
                              Icons.apartment,
                              color: Colors.white,
                              size: 50
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Charity 1',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 20, )
                            ),
                        )
                      ]
                  ),
                )
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      width: 125.0,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child :  Column(
                          children: [
                            IconButton(
                              enableFeedback: false,
                              onPressed: () {},
                              icon: const Icon(
                                  Icons.apartment,
                                  color: Colors.white,
                                  size: 50
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text('Charity 2',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 20, )
                              ),
                            )
                          ]
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      width: 125.0,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child :  Column(
                          children: [
                            IconButton(
                              enableFeedback: false,
                              onPressed: () {},
                              icon: const Icon(
                                  Icons.apartment,
                                  color: Colors.white,
                                  size: 50
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text('Charity 3',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 20, )
                              ),
                            )
                          ]
                      ),
                    )
                ),
              ],
            )
          ),

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
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {},
                  icon: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 35
                  ),

                ),
                Text('Home',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10)
                ),
              ]
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    style: TextStyle(color: Colors.white, fontSize: 10)
                ),
              ]
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {},
                  icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 35
                  ),

                ),
                Text('Notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10)
                ),
              ]
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {},
                  icon: const Icon(
                      Icons.message,
                      color: Colors.white,
                      size: 35
                  ),

                ),
                Text('Messages',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10)
                ),
              ]
          ),
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
            child: Text('DONAID'),
          ),
          ListTile(
            title: const Text('Favorites'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Edit Profile'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Donations History'),
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
