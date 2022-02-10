// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:donaid/Organization/urgent_case_list_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'OrganizationWidget/add_categorys.dart';
// import 'add_page.dart';
// import 'beneficiary_list_screen.dart';
// import 'campaign_list_screen.dart';
// import 'search_screen.dart';
// import '../home_screen.dart';
//
// ///Author: Raisa Zaman
// ///Main is here for testing purposes
//
// class OrganizationDashboard extends StatefulWidget {
//   static const id = 'organization_dashboard';
//   const OrganizationDashboard({Key? key}) : super(key: key);
//
//   @override
//   _OrganizationDashboardState createState() => _OrganizationDashboardState();
// }
//
// final FirebaseAuth auth = FirebaseAuth.instance;
//
//
// class _OrganizationDashboardState extends State<OrganizationDashboard> {
//     final _firestore = FirebaseFirestore.instance;
//   List<Beneficiary> beneficiaries = [];
//   List<Campaign> campaigns = [];
//   List<UrgentCase> urgentCases = [];
//   // This OrganizationWidget is the root of your application.
//   final _auth = FirebaseAuth.instance;
//   User? loggedInUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//     _getBeneficiaries();
//     _getCampaign();
//     _getUrgentCases();
//   }
//
//
//   void _getCurrentUser(){
//     loggedInUser = _auth.currentUser;
//   }
//
//     _getCampaign() async {
//     var ret = await _firestore.collection('Campaigns').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//     ret.docs.forEach((element) {
//       Campaign campaign = Campaign(
//           name: element.data()['title'],
//           goal: element.data()['goalAmount'],
//           category: element.data()['category']);
//       campaigns.add(campaign);
//     });
//
//     setState(() {});
//   }
//   _getUrgentCases() async {
//     var ret = await _firestore.collection('UrgentCases').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//
//     final documents = ret.docs;
//
//     ret.docs.forEach((doc){
//       UrgentCase urgentCase = UrgentCase(
//           name: doc.data()['title'],
//           goal: doc.data()['goalAmount'],
//           category: doc.data()['category']);
//       urgentCases.add(urgentCase);
//     });
//
//     setState(() {});
//   }
//
//   _getBeneficiaries() async {
//     var ret = await _firestore.collection('Beneficiaries').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//
//     ret.docs.forEach((element) {
//       Beneficiary beneficiary = Beneficiary(
//           name: element.data()['name'],
//           goal: element.data()['goalAmount'],
//           category: element.data()['category']); // need to add category
//       beneficiaries.add(beneficiary);
//     });
//
//     print('Beneficiaries list: $beneficiaries');
//
//     setState(() {});
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BottomNavBarV2(beneficiaries),
//     );
//   }
// }
//
// class BottomNavBarV2 extends StatefulWidget {
//   List<Beneficiary> beneficiaries0 =[];
//   BottomNavBarV2(List<Beneficiary> beneficiaries){
//     beneficiaries0 = beneficiaries;
//     print(beneficiaries0);
//   }
//
//
//   @override
//   _BottomNavBarV2State createState() => _BottomNavBarV2State(beneficiaries0);
// }
//
//
// class _BottomNavBarV2State extends State<BottomNavBarV2> {
//   List<Beneficiary> beneficiaries0 =[];
//   _BottomNavBarV2State(List<Beneficiary> beneficiaries){
//     beneficiaries0 = beneficiaries;
//     print(beneficiaries0);
//   }
//   int currentIndex = 0;
//   final _auth = FirebaseAuth.instance;
//
//
//   setBottomBarIndex(index) {
//     setState(() {
//       currentIndex = index;
//     });
//   }
//
//
//
//   TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   _onSearchChanged() {
//     print(_searchController.text);
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     final Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               child: Stack(
//                 children: [
//                   Positioned(
//                     bottom: 8.0,
//                     left: 4.0,
//                     child: Text(
//                       "Organization",
//                       style: TextStyle(color: Colors.white, fontSize: 20),
//                     ),
//                   )
//                 ],
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.settings),
//               title: Text("Settings"),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: Icon(Icons.article_outlined),
//               title: Text("About"),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: Icon(Icons.help),
//               title: Text("Help"),
//               onTap: () {},
//             ),
//             ListTile(
//                 leading: Icon(Icons.logout),
//                 title: Text("Logout"),
//                 onTap: () {
//                   Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.id));
//                   _auth.signOut();
//                 }),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         title: Text('DONAID'),
//       ),
//       backgroundColor: Colors.white.withAlpha(55),
//       body: Stack(
//         children: [
//           ListView(
//             children: <Widget>[
//               Container(
//                   padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//                   child: Text('My Campaigns',
//                       style: TextStyle(fontSize: 20, color: Colors.white))),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 alignment: Alignment.centerRight,
//                 icon: Text('See more >',
//                     style: TextStyle(fontSize: 14, color: Colors.white)),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => CampaignList()),
//                   );
//                 },
//               ),
//               Category(beneficiaries0),
//               Container(
//                   padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//                   child: Text('My Urgent Cases',
//                       style: TextStyle(fontSize: 20, color: Colors.white))),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 alignment: Alignment.centerRight,
//                 icon: Text('See more >',
//                     style: TextStyle(fontSize: 14, color: Colors.white)),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => UrgentList()),
//                   );
//                 },
//               ),
//               Category(beneficiaries0),
//               Container(
//                   padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//                   child: Text('My Beneficiary',
//                       style: TextStyle(fontSize: 20, color: Colors.white))),
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 alignment: Alignment.centerRight,
//                 icon: Text('See more >',
//                     style: TextStyle(fontSize: 14, color: Colors.white)),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => BeneficiaryList()),
//                   );
//                 },
//               ),
//               Category(beneficiaries0),
//               //AllProducts(),
//             ],
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             child: Container(
//                 width: size.width,
//                 height: 80,
//                 child: Stack(
//                   overflow: Overflow.visible,
//                   children: [
//                     CustomPaint(
//                       size: Size(size.width, 80),
//                       painter: BNBCustomPainter(),
//                     ),
//                     Center(
//                       heightFactor: 0.6,
//                       child: FloatingActionButton(
//                           backgroundColor: Colors.blue,
//                           child: Icon(Icons.add),
//                           elevation: 0.1,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => addPage()),
//                             );
//                           }),
//                     ),
//                     Container(
//                       width: size.width,
//                       height: 80,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           IconButton(
//                             icon: Icon(
//                               Icons.home,
//                               color: currentIndex == 0
//                                   ? Colors.blue
//                                   : Colors.grey.shade400,
//                             ),
//                             onPressed: () {
//                               setBottomBarIndex(0);
//                               {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           OrganizationDashboard()),
//                                 );
//                               }
//                             },
//                             splashColor: Colors.white,
//                           ),
//                           IconButton(
//                               icon: Icon(
//                                 Icons.search,
//                                 color: currentIndex == 1
//                                     ? Colors.blue
//                                     : Colors.grey.shade400,
//                               ),
//                               onPressed: () {
//                                 setBottomBarIndex(1);
//                                 {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => SearchPage()),
//                                   );
//                                 }
//                               }),
//                           Container(
//                             width: size.width * 0.20,
//                           ),
//                           IconButton(
//                               icon: Icon(
//                                 Icons.notifications,
//                                 color: currentIndex == 2
//                                     ? Colors.blue
//                                     : Colors.grey.shade400,
//                               ),
//                               onPressed: () {
//                                 setBottomBarIndex(2);
//                               }),
//                           IconButton(
//                               icon: Icon(
//                                 Icons.message,
//                                 color: currentIndex == 3
//                                     ? Colors.blue
//                                     : Colors.grey.shade400,
//                               ),
//                               onPressed: () {
//                                 setBottomBarIndex(3);
//                               }),
//                         ],
//                       ),
//                     )
//                   ],
//                 )),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class BNBCustomPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = new Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
//
//     Path path = Path();
//     path.moveTo(0, 20); // Start
//     path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
//     path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
//     path.arcToPoint(Offset(size.width * 0.60, 20),
//         radius: Radius.circular(20.0), clockwise: false);
//     path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
//     path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.lineTo(0, 20);
//     canvas.drawShadow(path, Colors.black, 5, true);
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
// class Campaign {
//   String name;
//   int goal;
//   String category;
//
//   Campaign(
//       {
//         required this.name,
//         required this.goal,
//         required this.category,
//       });
// }
//
// class UrgentCase {
//   String name;
//   int goal;
//   String category;
//
//   UrgentCase(
//       {
//         required this.name,
//         required this.goal,
//         required this.category,});
// }
//
// class Beneficiary {
//   String name;
//   int goal;
//   String category;
//
//   Beneficiary({
//     required this.name,
//     required this.goal,
//     required this.category,
//   });
// }



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../home_screen.dart';
// import 'OrganizationWidget/navbar_org_dashboard.dart';
//
// ///Author: Raisa Zaman
// ///Main is here for testing purposes
//
// class OrganizationDashboard extends StatefulWidget {
//   static const id = 'organization_dashboard';
//   const OrganizationDashboard({Key? key}) : super(key: key);
//
//   @override
//   _OrganizationDashboardState createState() => _OrganizationDashboardState();
// }
//
// final FirebaseAuth auth = FirebaseAuth.instance;
//
//
// class _OrganizationDashboardState extends State<OrganizationDashboard> {
//   final _auth = FirebaseAuth.instance;
//   User? loggedInUser;
//   final _firestore = FirebaseFirestore.instance;
//   List<Beneficiary> beneficiaries = [];
//   List<Campaign> campaigns = [];
//   List<UrgentCase> urgentCases = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//     _getBeneficiaries();
//     _getCampaign();
//     _getUrgentCases();
//   }
//
//
//   void _getCurrentUser(){
//     loggedInUser = _auth.currentUser;
//   }
//
//
//   _beneficiaryBody() {
//     return ListView.builder(
//       itemCount: beneficiaries.length,
//       shrinkWrap: true,
//       itemBuilder: (context, int index) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           elevation: 3,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               children: [
//                 Text('Name: ${beneficiaries[index].name}'),
//                 SizedBox(height: 8),
//                 Text('Goal: ${beneficiaries[index].goal.toString()}'),
//                 SizedBox(height: 8),
//                 Text('Category: ${beneficiaries[index].category}'),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   _urgentBody() {
//     return ListView.builder(
//       itemCount: urgentCases.length,
//       shrinkWrap: true,
//       itemBuilder: (context, int index) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           elevation: 3,
//           child: ListTile(
//             title: Text(urgentCases[index].name),
//             subtitle: Text(urgentCases[index].category),
//             trailing: Text(urgentCases[index].goal.toString()),
//           ),
//         );
//       },
//     );
//   }
//
//   _campaignBody() {
//     return ListView.builder(
//       itemCount: campaigns.length,
//       shrinkWrap: true,
//       itemBuilder: (context, int index) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           elevation: 3,
//           child: ListTile(
//             title: Text(campaigns[index].name),
//             subtitle: Text(campaigns[index].category),
//             trailing: Text(campaigns[index].goal.toString()),
//           ),
//         );
//       },
//     );
//   }
//
// //Need a field
//   _getUrgentCases() async {
//     var ret = await _firestore.collection('UrgentCases').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//
//     final documents = ret.docs;
//
//     ret.docs.forEach((doc){
//       UrgentCase urgentCase = UrgentCase(
//           name: doc.data()['title'],
//           goal: doc.data()['goalAmount'],
//           category: doc.data()['category']);
//       urgentCases.add(urgentCase);
//     });
//
//     setState(() {});
//   }
//
//   _getCampaign() async {
//     var ret = await _firestore.collection('Campaigns').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//     ret.docs.forEach((element) {
//       Campaign campaign = Campaign(
//           name: element.data()['title'],
//           goal: element.data()['goalAmount'],
//           category: element.data()['category']);
//       campaigns.add(campaign);
//     });
//
//     setState(() {});
//   }
//
//   _getBeneficiaries() async {
//     var ret = await _firestore.collection('Beneficiaries').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//
//     ret.docs.forEach((element) {
//       Beneficiary beneficiary = Beneficiary(
//           name: element.data()['name'],
//           goal: element.data()['goalAmount'],
//           category: element.data()['category']); // need to add category
//       beneficiaries.add(beneficiary);
//     });
//
//     print('Beneficiaries list: $beneficiaries');
//
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 1,
//       child: Scaffold(
//         drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               child: Stack(
//                 children: [
//                   Positioned(
//                     bottom: 8.0,
//                     left: 4.0,
//                     child: Text(
//                       "Organization",
//                       style: TextStyle(color: Colors.white, fontSize: 20),
//                     ),
//                   )
//                 ],
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.settings),
//               title: Text("Settings"),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: Icon(Icons.article_outlined),
//               title: Text("About"),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: Icon(Icons.help),
//               title: Text("Help"),
//               onTap: () {},
//             ),
//             ListTile(
//                 leading: Icon(Icons.logout),
//                 title: Text("Logout"),
//                 onTap: () {
//                   Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.id));
//                   _auth.signOut();
//                 }),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         title: const Text('DONAID'),
//       ),
//       body: ListView(
//         children: [
//           BottomNavBarV2(),
//           _beneficiaryBody(),
//         ],
//       ),
//
//       // bottomNavigationBar: BottomNavigationBar(
//       //   items: const <BottomNavigationBarItem>[
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.home, color: Colors.black),
//       //       label: 'Home',
//       //     ),
//       //
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.search, color: Colors.black),
//       //       label: 'Search',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.add, color: Colors.black),
//       //       label: 'add',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.phonelink_ring_rounded, color: Colors.black),
//       //       label: 'notification',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.message, color: Colors.black),
//       //       label: 'messages',
//       //     ),
//       //   ],
//       // ),
//       )
//     );
//   }
// }
//
//
// class Campaign {
//   String name;
//   int goal;
//   String category;
//
//   Campaign(
//       {
//         required this.name,
//         required this.goal,
//         required this.category,
//       });
// }
//
// class UrgentCase {
//   String name;
//   int goal;
//   String category;
//
//   UrgentCase(
//       {
//         required this.name,
//         required this.goal,
//         required this.category,});
// }
//
// class Beneficiary {
//   String name;
//   int goal;
//   String category;
//
//   Beneficiary({
//     required this.name,
//     required this.goal,
//     required this.category,
//   });
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:donaid/Organization/urgent_case_list_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'OrganizationWidget/add_categorys.dart';
// import 'add_page.dart';
// import 'beneficiary_list_screen.dart';
// import 'campaign_list_screen.dart';
// import 'search_screen.dart';
// import '../home_screen.dart';
//
// ///Author: Raisa Zaman
// ///Main is here for testing purposes
//
// class OrganizationDashboard extends StatefulWidget {
//   static const id = 'organization_dashboard';
//   const OrganizationDashboard({Key? key}) : super(key: key);
//
//   @override
//   _OrganizationDashboardState createState() => _OrganizationDashboardState();
// }
//
// final FirebaseAuth auth = FirebaseAuth.instance;
//
//
// class _OrganizationDashboardState extends State<OrganizationDashboard> {
//   final _auth = FirebaseAuth.instance;
//   User? loggedInUser;
//   final _firestore = FirebaseFirestore.instance;
//   List<Beneficiary> beneficiaries = [];
//   List<Campaign> campaigns = [];
//   List<UrgentCase> urgentCases = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//     _getBeneficiaries();
//     _getCampaign();
//     _getUrgentCases();
//   }
//
//
//
//   void _getCurrentUser(){
//     loggedInUser = _auth.currentUser;
//   }
//
//
//
//   _getCampaign() async {
//     var ret = await _firestore.collection('Campaigns').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//     ret.docs.forEach((element) {
//       Campaign campaign = Campaign(
//           name: element.data()['title'],
//           goal: element.data()['goalAmount'],
//           category: element.data()['category']);
//       campaigns.add(campaign);
//     });
//
//     setState(() {});
//   }
//   _getUrgentCases() async {
//     var ret = await _firestore.collection('UrgentCases').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//
//     final documents = ret.docs;
//
//     ret.docs.forEach((doc){
//       UrgentCase urgentCase = UrgentCase(
//           name: doc.data()['title'],
//           goal: doc.data()['goalAmount'],
//           category: doc.data()['category']);
//       urgentCases.add(urgentCase);
//     });
//
//     setState(() {});
//   }
//
//   _getBeneficiaries() async {
//     var ret = await _firestore.collection('Beneficiaries').where(
//         'organizationID', isEqualTo: loggedInUser?.uid).get();
//
//     ret.docs.forEach((element) {
//       Beneficiary beneficiary = Beneficiary(
//           name: element.data()['name'],
//           goal: element.data()['goalAmount'],
//           category: element.data()['category']); // need to add category
//       beneficiaries.add(beneficiary);
//     });
//
//     print('Beneficiaries list: $beneficiaries');
//
//     setState(() {});
//   }
//
//   _beneficiaryBody() {
//     return ListView.builder(
//       itemCount: beneficiaries.length,
//       shrinkWrap: true,
//       itemBuilder: (context, int index) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           elevation: 3,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               children: [
//                 Text('Name: ${beneficiaries[index].name}'),
//                 SizedBox(height: 8),
//                 Text('Goal: ${beneficiaries[index].goal.toString()}'),
//                 SizedBox(height: 8),
//                 Text('Category: ${beneficiaries[index].category}'),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   _urgentBody() {
//     return ListView.builder(
//       itemCount: urgentCases.length,
//       shrinkWrap: true,
//       itemBuilder: (context, int index) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           elevation: 3,
//           child: ListTile(
//             title: Text(urgentCases[index].name),
//             subtitle: Text(urgentCases[index].category),
//             trailing: Text(urgentCases[index].goal.toString()),
//           ),
//         );
//       },
//     );
//   }
//
//   _campaignBody() {
//     return ListView.builder(
//       itemCount: campaigns.length,
//       shrinkWrap: true,
//       itemBuilder: (context, int index) {
//         return Card(
//           margin: const EdgeInsets.all(8),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           elevation: 3,
//           child: ListTile(
//             title: Text(campaigns[index].name),
//             subtitle: Text(campaigns[index].category),
//             trailing: Text(campaigns[index].goal.toString()),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         drawer: Drawer(
//           child: ListView(
//             children: [
//               DrawerHeader(
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       bottom: 8.0,
//                       left: 4.0,
//                       child: Text(
//                         "Organization",
//                         style: TextStyle(color: Colors.white, fontSize: 20),
//                       ),
//                     )
//                   ],
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                 ),
//               ),
//               ListTile(
//                 leading: Icon(Icons.settings),
//                 title: Text("Settings"),
//                 onTap: () {},
//               ),
//               ListTile(
//                 leading: Icon(Icons.article_outlined),
//                 title: Text("About"),
//                 onTap: () {},
//               ),
//               ListTile(
//                 leading: Icon(Icons.help),
//                 title: Text("Help"),
//                 onTap: () {},
//               ),
//               ListTile(
//                   leading: Icon(Icons.logout),
//                   title: Text("Logout"),
//                   onTap: () {
//                     Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.id));
//                     _auth.signOut();
//                   }),
//             ],
//           ),
//         ),
//         appBar: AppBar(
//           title: Text('DONAID'),
//         ),
//       body:
//     ListView(
//       children: <Widget>[
//         Container(
//             padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//             child: Text('My Campaigns',
//                 style: TextStyle(fontSize: 20, color: Colors.black))),
//         IconButton(
//           padding: EdgeInsets.zero,
//           alignment: Alignment.centerRight,
//           icon: Text('See more >',
//               style: TextStyle(fontSize: 14, color: Colors.black)),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => CampaignList()),
//             );
//           },
//         ),
//         Container(
//             padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//             child: Text('My Urgent Cases',
//                 style: TextStyle(fontSize: 20, color: Colors.black))),
//         IconButton(
//           padding: EdgeInsets.zero,
//           alignment: Alignment.centerRight,
//           icon: Text('See more >',
//               style: TextStyle(fontSize: 14, color: Colors.black)),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => UrgentList()),
//             );
//           },
//         ),
//         Container(
//             padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//             child: Text('My Beneficiary',
//                 style: TextStyle(fontSize: 20, color: Colors.black))),
//         IconButton(
//           padding: EdgeInsets.zero,
//           alignment: Alignment.centerRight,
//           icon: Text('See more >',
//               style: TextStyle(fontSize: 14, color: Colors.black)),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => BeneficiaryList()),
//             );
//           },
//         ),
//         //AllProducts(),
//       ],
//
//     ),
//     );
//   }
// }
//
// class Campaign {
//   String name;
//   int goal;
//   String category;
//
//   Campaign(
//       {
//         required this.name,
//         required this.goal,
//         required this.category,
//       });
// }
//
// class UrgentCase {
//   String name;
//   int goal;
//   String category;
//
//   UrgentCase(
//       {
//         required this.name,
//         required this.goal,
//         required this.category,});
// }
//
// class Beneficiary {
//   String name;
//   int goal;
//   String category;
//
//   Beneficiary({
//     required this.name,
//     required this.goal,
//     required this.category,
//   });
// }
//
// class BottomNavBarV2 extends StatefulWidget {
//   @override
//   _BottomNavBarV2State createState() => _BottomNavBarV2State();
// }
//
//
// class _BottomNavBarV2State extends State<BottomNavBarV2> {
//   int currentIndex = 0;
//   final _auth = FirebaseAuth.instance;
//
//
//   setBottomBarIndex(index) {
//     setState(() {
//       currentIndex = index;
//     });
//   }
//
//
//
//   TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   _onSearchChanged() {
//     print(_searchController.text);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     final Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Colors.white.withAlpha(55),
//       body: Stack(
//         children: [
//           // ListView(
//           //   children: <Widget>[
//           //     Container(
//           //         padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//           //         child: Text('My Campaigns',
//           //             style: TextStyle(fontSize: 20, color: Colors.black))),
//           //     IconButton(
//           //       padding: EdgeInsets.zero,
//           //       alignment: Alignment.centerRight,
//           //       icon: Text('See more >',
//           //           style: TextStyle(fontSize: 14, color: Colors.black)),
//           //       onPressed: () {
//           //         Navigator.push(
//           //           context,
//           //           MaterialPageRoute(builder: (context) => CampaignList()),
//           //         );
//           //       },
//           //     ),
//           //     Container(
//           //         padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//           //         child: Text('My Urgent Cases',
//           //             style: TextStyle(fontSize: 20, color: Colors.black))),
//           //     IconButton(
//           //       padding: EdgeInsets.zero,
//           //       alignment: Alignment.centerRight,
//           //       icon: Text('See more >',
//           //           style: TextStyle(fontSize: 14, color: Colors.black)),
//           //       onPressed: () {
//           //         Navigator.push(
//           //           context,
//           //           MaterialPageRoute(builder: (context) => UrgentList()),
//           //         );
//           //       },
//           //     ),
//           //     Container(
//           //         padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
//           //         child: Text('My Beneficiary',
//           //             style: TextStyle(fontSize: 20, color: Colors.black))),
//           //     IconButton(
//           //       padding: EdgeInsets.zero,
//           //       alignment: Alignment.centerRight,
//           //       icon: Text('See more >',
//           //           style: TextStyle(fontSize: 14, color: Colors.black)),
//           //       onPressed: () {
//           //         Navigator.push(
//           //           context,
//           //           MaterialPageRoute(builder: (context) => BeneficiaryList()),
//           //         );
//           //       },
//           //     ),
//           //     //AllProducts(),
//           //   ],
//           // ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             child: Container(
//                 width: size.width,
//                 height: 80,
//                 child: Stack(
//                   overflow: Overflow.visible,
//                   children: [
//                     CustomPaint(
//                       size: Size(size.width, 80),
//                       painter: BNBCustomPainter(),
//                     ),
//                     Center(
//                       heightFactor: 0.6,
//                       child: FloatingActionButton(
//                           backgroundColor: Colors.blue,
//                           child: Icon(Icons.add),
//                           elevation: 0.1,
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => addPage()),
//                             );
//                           }),
//                     ),
//                     Container(
//                       width: size.width,
//                       height: 80,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           IconButton(
//                             icon: Icon(
//                               Icons.home,
//                               color: currentIndex == 0
//                                   ? Colors.grey.shade400
//                                   : Colors.blue,
//                             ),
//                             onPressed: () {
//                               setBottomBarIndex(0);
//                               {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           OrganizationDashboard()),
//                                 );
//                               }
//                             },
//                             splashColor: Colors.white,
//                           ),
//                           IconButton(
//                               icon: Icon(
//                                 Icons.search,
//                                 color: currentIndex == 1
//                                     ? Colors.blue
//                                     : Colors.grey.shade400,
//                               ),
//                               onPressed: () {
//                                 setBottomBarIndex(1);
//                                 {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => SearchPage()),
//                                   );
//                                 }
//                               }),
//                           Container(
//                             width: size.width * 0.20,
//                           ),
//                           IconButton(
//                               icon: Icon(
//                                 Icons.notifications,
//                                 color: currentIndex == 2
//                                     ? Colors.blue
//                                     : Colors.grey.shade400,
//                               ),
//                               onPressed: () {
//                                 setBottomBarIndex(2);
//                               }),
//                           IconButton(
//                               icon: Icon(
//                                 Icons.message,
//                                 color: currentIndex == 3
//                                     ? Colors.blue
//                                     : Colors.grey.shade400,
//                               ),
//                               onPressed: () {
//                                 setBottomBarIndex(3);
//                               }),
//                         ],
//                       ),
//                     )
//                   ],
//                 )),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class BNBCustomPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = new Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
//
//     Path path = Path();
//     path.moveTo(0, 20); // Start
//     path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
//     path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
//     path.arcToPoint(Offset(size.width * 0.60, 20),
//         radius: Radius.circular(20.0), clockwise: false);
//     path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
//     path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.lineTo(0, 20);
//     canvas.drawShadow(path, Colors.black, 5, true);
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:donaid/Organization/OrganizationWidget/campaign_card.dart';
import 'package:donaid/Organization/OrganizationWidget/urgent_case_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/beneficiary_card.dart';

class OrganizationDashboard extends StatefulWidget {
  static const id = 'donor_dashboard';

  const OrganizationDashboard({Key? key}) : super(key: key);

  @override
  _OrganizationDashboardState createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends State<OrganizationDashboard> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
    List<Beneficiary> beneficiaries = [];
  List<Campaign> campaigns = [];
  List<UrgentCase> urgentCases = [];



  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getCampaign();
    _getUrgentCases();
    _getBeneficiaries();

  }

  _getCampaign() async {
    var ret = await _firestore.collection('Campaigns').where(
        'organizationID', isEqualTo: loggedInUser?.uid).get();
    ret.docs.forEach((element) {
      Campaign campaign = Campaign(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
        endDate: element.data()['endDate'],
        dateCreated: element.data()['dateCreated'],
        id: element.data()['id'],
        organizationID: element.data()['organizationID']
      );
      campaigns.add(campaign);
    });

    setState(() {});
  }
  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases').where(
        'organizationID', isEqualTo: loggedInUser?.uid).get();

    ret.docs.forEach((element){
      UrgentCase urgentCase = UrgentCase(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']
      );
      urgentCases.add(urgentCase);
    });

    setState(() {});
  }
  _getBeneficiaries() async {
    var ret = await _firestore.collection('Beneficiaries').where(
        'organizationID', isEqualTo: loggedInUser?.uid).get();

    ret.docs.forEach((element) {
      Beneficiary beneficiary = Beneficiary(
          name: element.data()['name'],
          biography: element.data()['biography'],
          goalAmount: element.data()['goalAmount'],
          amountRaised: element.data()['amountRaised'],
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']
      ); // need to add category
      beneficiaries.add(beneficiary);
    });

    print('Beneficiaries list: $beneficiaries');

    setState(() {});
  }

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
                  children: const [
                    Text(
                      'Campaign',
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
              child: ListView.builder(
                itemCount: campaigns.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return CampaignCard(
                      campaigns[index].title, campaigns[index].description, campaigns[index].goalAmount, campaigns[index].amountRaised);
                },
              )),

          // organization list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
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
              child: ListView.builder(
                itemCount: urgentCases.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return UrgentCaseCard(
                      urgentCases[index].title, urgentCases[index].description, urgentCases[index].goalAmount, urgentCases[index].amountRaised);
                },
              )),

          // urgent case list
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Beneficiary',
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
              child: ListView.builder(
                itemCount: beneficiaries.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return BeneficiaryCard(beneficiaries[index].name,beneficiaries[index].biography, beneficiaries[index].goalAmount, beneficiaries[index].amountRaised);
                },
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







