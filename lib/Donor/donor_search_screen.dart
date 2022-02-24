import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Donor/DonorWidgets/search_suggestion_item.dart';
import 'package:donaid/Models/SearchResult.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'DonorWidgets/donor_bottom_navigation_bar.dart';
import 'DonorWidgets/donor_drawer.dart';
import 'DonorWidgets/search_result_item.dart';

class DonorSearchScreen extends StatefulWidget {
  static const id = 'donor_search_screen';

  const DonorSearchScreen({Key? key}) : super(key: key);

  @override
  _DonorSearchScreenState createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  TextEditingController? _searchController;
  String searchQuery = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<SearchResult> searchResult = [];
  List<SearchResult> data = <SearchResult>[];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getBeneficiaries();
    _getUrgentCases();
    _getOrganizationUsers();
  }

  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }


  _getOrganizationUsers() async {
    var ret = await _firestore.collection('OrganizationUsers').where('approved', isEqualTo: true).get();
    for (var element in ret.docs) {
      SearchResult searchResult = SearchResult(
        title: element.data()['organizationName'],
        id: element.data()['id'],
        collection: "OrganizationUsers"
      );
      data.add(searchResult);
    }
    setState(() {});
  }

  _getBeneficiaries() async {
    var ret = await _firestore.collection('Beneficiaries')
        .where('active',isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
        .get();
    for (var element in ret.docs) {
      SearchResult searchResult = SearchResult(
          title: element.data()['name'],
          id: element.data()['id'],
          collection: "Beneficiaries"
      );
      data.add(searchResult);
    }
    setState(() {});
  }

  _getUrgentCases() async {
    var ret = await _firestore.collection('UrgentCases')
        .where('approved',isEqualTo: true)
        .where('active', isEqualTo: true)
        .where('endDate',isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate',descending: false)
        .get();

    for (var element in ret.docs) {
      SearchResult searchResult = SearchResult(
          title: element.data()['title'],
          id: element.data()['id'],
          collection: "UrgentCases"
      );
      data.add(searchResult);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Search'),
      ),
      drawer: const DonorDrawer(),
      body: _body(),
      bottomNavigationBar: const DonorBottomNavigationBar(),
    );
  }

  Widget _buildSearchField() {
    _searchController = TextEditingController();
    return Container(
        padding: const EdgeInsets.all(8.0),
        width: 300,
        child: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
              )),
          onSaved: (value) {
            searchQuery = value!;
          },
        ));
  }

  _body() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
                  _buildSearchField(),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                        showSearch(context: context, delegate: SearchQuery(data: data));
                    },
                    icon: const Icon(Icons.search, color: Colors.blue, size: 40),
                  ),
                ],
              )
          ),
        ),
      );

  }
}

class SearchQuery extends SearchDelegate<String>{
  List<SearchResult> data = <SearchResult>[];
  SearchQuery({required this.data,});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [Container()];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "closing search");
      },
    );

  }

  @override
  Widget buildResults(BuildContext context) {
    final resultsList = data.where((currentData) => currentData.title.contains(query)).toList();
    return ListView.builder(
        itemCount: resultsList.length,
        itemBuilder: (context, int index) {
          if(resultsList[index].collection == "Organizations"){
            return SearchResultItem(resultsList[index].title, Icons.apartment);
          }
          if(resultsList[index].collection == "Beneficiaries"){
            return SearchResultItem(resultsList[index].title, Icons.person);
          }
          if(resultsList[index].collection == "UrgentCases"){
            return SearchResultItem(resultsList[index].title, Icons.assistant);
          }
          else{
            return SearchResultItem(resultsList[index].title, Icons.apartment);
          }
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<SearchResult> suggestionList =  data.where((currentData) => currentData.title.contains(query)).toList();
    // return ListView.builder(
    //     itemCount: suggestionList.length,
    //     itemBuilder: (context, int index) {
    //       if(suggestionList[index].collection == "Organizations"){
    //         return SearchSuggestionItem(suggestionList[index].title, Icons.apartment);
    //       }
    //       if(suggestionList[index].collection == "Beneficiaries"){
    //         return SearchSuggestionItem(suggestionList[index].title, Icons.person);
    //       }
    //       if(suggestionList[index].collection == "UrgentCases"){
    //         return SearchSuggestionItem(suggestionList[index].title, Icons.assistant);
    //       }
    //       else{
    //         return SearchSuggestionItem(suggestionList[index].title, Icons.apartment);
    //       }
    //     },
    // );

    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (content, index) => ListTile(
          onTap: () {
            query = suggestionList[index].title;
            buildResults(context);
            showResults(context);
          },
          title: Text(suggestionList[index].title)),
    );
  }
}