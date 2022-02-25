import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/Beneficiary.dart';
import 'package:donaid/Models/Campaign.dart';
import 'package:donaid/Models/UrgentCase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OrganizationWidget/beneficiary_card.dart';
import 'OrganizationWidget/button_nav_bar.dart';
import 'OrganizationWidget/search_list_card.dart';
import 'OrganizationWidget/urgent_case_card.dart';

class OrganizationSearch extends StatefulWidget {
  static const id = 'organization_search_screen';

  const OrganizationSearch({Key? key}) : super(key: key);

  @override
  _OrganizationSearchState createState() => _OrganizationSearchState();
}

class _OrganizationSearchState extends State<OrganizationSearch> {

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
    var ret = await _firestore
        .collection('Campaigns')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .get();
    for (var element in ret.docs) {
      Campaign campaign = Campaign(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']);
      campaigns.add(campaign);
      print(campaign);
    }

    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .get();

    for (var element in ret.docs) {
      UrgentCase urgentCase = UrgentCase(
          title: element.data()['title'],
          description: element.data()['description'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID: element.data()['organizationID']);
      urgentCases.add(urgentCase);
    }

    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('organizationID', isEqualTo: loggedInUser?.uid)
        .get();

    for (var element in ret.docs) {
      Beneficiary beneficiary = Beneficiary(
          name: element.data()['name'],
          biography: element.data()['biography'],
          goalAmount: element.data()['goalAmount'].toDouble(),
          amountRaised: element.data()['amountRaised'].toDouble(),
          category: element.data()['category'],
          endDate: element.data()['endDate'],
          dateCreated: element.data()['dateCreated'],
          id: element.data()['id'],
          organizationID:
          element.data()['organizationID']); // need to add category
      beneficiaries.add(beneficiary);
      print(beneficiary.name);
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Search'),
              actions: [
                IconButton(
                  onPressed: () {
                   // showSearch(context: context, delegate: SearchUser());
                  },
                  icon: Icon(Icons.search_sharp),
                )
              ],
            ),
             body: _body(),

      bottomNavigationBar: ButtomNavigation(),
        ));
  }


    _body() {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Urgent Case',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),
                    ]),
              ),
            ),
            SizedBox(
                height: 320.0,
                child: ListView.builder(
                    itemCount: urgentCases.length,
                    itemBuilder: (context, index) {
                      if (!urgentCases.isNotEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                        },
                                        icon: Icon(Icons.warning),
                                      )
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(urgentCases[index].title,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 10),
                                      Text(urgentCases[index].goalAmount.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(urgentCases[index].endDate.toDate().
                                      toString().substring(0, urgentCases[index].
                                      endDate.toDate().toString().indexOf(' ')),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ]),
                              ],

                            ),
                            // trailing: Text('More Info'),
                          ),
                        ),
                      );
                    }
                ),),

            // organization list
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Campaign',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),

                    ]),
              ),
            ),
            SizedBox(
                height: 110.0,
                child: ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      if (!campaigns.isNotEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                        },
                                        icon: Icon(Icons.apartment_outlined),
                                      )
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(campaigns[index].title,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 10),
                                      Text(campaigns[index].goalAmount.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(campaigns[index].endDate.toDate().
                                      toString().substring(0, campaigns[index].
                                      endDate.toDate().toString().indexOf(' ')),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ]),
                              ],
                            ),
                            // trailing: Text('More Info'),
                          ),
                        ),
                      );
                    }
                ),),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Beneficiary',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.start,
                      ),

                    ]),
              ),
            ),
            // urgent case list
            SizedBox(
                height: 225.0,
                child: ListView.builder(
                    itemCount: beneficiaries.length,
                    itemBuilder: (context, index) {
                      if (!beneficiaries.isNotEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlueAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                        },
                                        icon: Icon(Icons.person),
                                      )
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(beneficiaries[index].name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 10),
                                      Text(beneficiaries[index].goalAmount.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(beneficiaries[index].endDate.toDate().
                                      toString().substring(0, beneficiaries[index].
                                      endDate.toDate().toString().indexOf(' ')),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ]),
                              ],
                            ),
                            // trailing: Text('More Info'),
                          ),
                        ),
                      );
                    }
                ),),
        ],
        )
      );
    }
  }



class _SearchAppBarDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          close(context, "");
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        query,
        style: TextStyle(
            color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 30),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    String suggestionList = "";
    return suggestionList.isEmpty
        ? Text("no result found")
        : ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("jfjk"),
          onTap: () {
            showResults(context);
          },
        );
      },
      itemCount: suggestionList.length,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:search_list_api_working/Api_service.dart';
// import 'package:search_list_api_working/search.dart';
// import 'package:search_list_api_working/user_model.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   FetchUserList _userList = FetchUserList();
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('UserList'),
//           actions: [
//             IconButton(
//               onPressed: () {
//                 showSearch(context: context, delegate: SearchUser());
//               },
//               icon: Icon(Icons.search_sharp),
//             )
//           ],
//         ),
//         body: Container(
//           padding: EdgeInsets.all(20),
//           child: FutureBuilder<List<Userlist>>(
//               future: _userList.getuserList(),
//               builder: (context, snapshot) {
//                 var data = snapshot.data;
//                 return ListView.builder(
//                     itemCount: data?.length,
//                     itemBuilder: (context, index) {
//                       if (!snapshot.hasData) {
//                         return Center(child: CircularProgressIndicator());
//                       }
//                       return Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ListTile(
//                             title: Row(
//                               children: [
//                                 Container(
//                                   width: 60,
//                                   height: 60,
//                                   decoration: BoxDecoration(
//                                     color: Colors.deepPurpleAccent,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       '${data?[index].id}',
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 20),
//                                 Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${data?[index].name}',
//                                         style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                       SizedBox(height: 10),
//                                       Text(
//                                         '${data?[index].email}',
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                       ),
//                                     ])
//                               ],
//                             ),
//                             // trailing: Text('More Info'),
//                           ),
//                         ),
//                       );
//                     });
//               }),
//         ),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:donaid/Models/Beneficiary.dart';
// import 'package:donaid/Models/Campaign.dart';
// import 'package:donaid/Models/UrgentCase.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import 'OrganizationWidget/search_list_card.dart';
//
//
// class OrganizationSearch extends StatefulWidget {
//   static const id = 'organization_search_screen';
//
//   const OrganizationSearch({Key? key}) : super(key: key);
//
//   @override
//   _OrganizationSearchState createState() => _OrganizationSearchState();
// }
//
// class _OrganizationSearchState extends State<OrganizationSearch> {
//  TextEditingController _searchController = TextEditingController();
//
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final _auth = FirebaseAuth.instance;
//   User? loggedInUser;
//   final _firestore = FirebaseFirestore.instance;
//   List<Beneficiary> beneficiaries = [];
//   List<Campaign> campaigns = [];
//   List<UrgentCase> urgentCases = [];
//
//   late Future resultsLoaded;
//   List _allResults = [];
//   List _resultsList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//     _getBeneficiaries();
//   }
//
//   _getBeneficiaries() async {
//     var ret = await _firestore
//         .collection('Beneficiaries')
//         .where('organizationID', isEqualTo: loggedInUser?.uid)
//         .get();
//
//     for (var element in ret.docs) {
//       Beneficiary beneficiary = Beneficiary(
//           name: element.data()['name'],
//           biography: element.data()['biography'],
//           goalAmount: element.data()['goalAmount'].toDouble(),
//           amountRaised: element.data()['amountRaised'].toDouble(),
//           category: element.data()['category'],
//           endDate: element.data()['endDate'],
//           dateCreated: element.data()['dateCreated'],
//           id: element.data()['id'],
//           organizationID:
//           element.data()['organizationID']); // need to add category
//       beneficiaries.add(beneficiary);
//       print(beneficiary);
//     }
//
//     print('Beneficiaries list: $beneficiaries');
//     _allResults = ret.docs;
//
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     resultsLoaded = _getBeneficiaries();
//   }
//
//
//   _onSearchChanged() {
//     searchResultsList();
//   }
//
//   searchResultsList() {
//     var showResults = [];
//
//     if(_searchController.text != "") {
//       for(var tripSnapshot in _allResults){
//         var title = beneficiaries[tripSnapshot].name.toString();
//
//         if(title.contains(_searchController.text.toLowerCase())) {
//           showResults.add(tripSnapshot);
//         }
//       }
//
//     } else {
//       showResults = List.from(_allResults);
//     }
//     setState(() {
//       _resultsList = showResults;
//     });
//   }
//
//
//   // getUsersPastTripsStreamSnapshots() async {
//   //   final uid = await Provider.of(context).auth.getCurrentUID();
//   //   var data = await Firestore.instance
//   //       .collection('userData')
//   //       .document(uid)
//   //       .collection('trips')
//   //       .where("endDate", isLessThanOrEqualTo: DateTime.now())
//   //       .orderBy('endDate')
//   //       .getDocuments();
//   //   setState(() {
//   //     _allResults = data.documents;
//   //   });
//   //   searchResultsList();
//   //   return "complete";
//   // }
//
//
//
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: <Widget>[
//           Text("Past Trips", style: TextStyle(fontSize: 20)),
//           Padding(
//             padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.search)
//               ),
//             ),
//           ),
//           Expanded(
//               child: ListView.builder(
//                 itemCount: _resultsList.length,
//                 itemBuilder: (BuildContext context, int index) =>
//                     SearchCard(beneficiaries[index].name,beneficiaries[index].goalAmount.toString()),
//               )
//
//           ),
//         ],
//       ),
//     );
//   }
// }
