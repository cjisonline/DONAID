import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donaid/Models/SearchResult.dart';
import 'package:filter_list/filter_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'DonorWidgets/search_result_item.dart';


class SearchQuery extends SearchDelegate<String> {
  List<SearchResult> data = <SearchResult>[];
  List<SearchResult> resultsList = <SearchResult>[];
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  String searchQuery = "";
  List<SearchResult> searchResult = [];
  SearchQuery(){
    _getCurrentUser();
    _getBeneficiaries();
    _getUrgentCases();
    _getOrganizationUsers();
  }
  void _getCurrentUser() {
    loggedInUser = _auth.currentUser;
  }

  _getOrganizationUsers() async {
    var ret = await _firestore
        .collection('OrganizationUsers')
        .where('approved', isEqualTo: true)
        .get();
    for (var element in ret.docs) {
      SearchResult searchResult = SearchResult(
        title: element.data()['organizationName'],
        id: element.data()['id'],
        collection: "OrganizationUsers",
        description: element.data()['organizationDescription'],
      );
      data.add(searchResult);
    }
  }

  _getBeneficiaries() async {
    var ret = await _firestore
        .collection('Beneficiaries')
        .where('active', isEqualTo: true)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate', descending: false)
        .get();
    for (var element in ret.docs) {
      SearchResult searchResult = SearchResult(
        title: element.data()['name'],
        id: element.data()['id'],
        collection: "Beneficiaries",
        description: element.data()['biography'],
      );
      data.add(searchResult);
    }
  }

  _getUrgentCases() async {
    var ret = await _firestore
        .collection('UrgentCases')
        .where('approved', isEqualTo: true)
        .where('active', isEqualTo: true)
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate', descending: false)
        .get();

    for (var element in ret.docs) {
      SearchResult searchResult = SearchResult(
        title: element.data()['title'],
        id: element.data()['id'],
        collection: "UrgentCases",
        description: element.data()['description'],
      );
      data.add(searchResult);
    }
  }


  List<String> filterOptions = [
    "OrganizationUsers",
    "Beneficiaries",
    "UrgentCases"
  ];
  List<String> selectedFilters = [];

  void openFilterDialog(BuildContext context) async {
    await FilterListDialog.display<String>(
      context,
      listData: filterOptions,
      selectedListData: selectedFilters,
      choiceChipLabel: (filter) => filter,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (filter, query) {
        return filter.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        selectedFilters = List.from(list!);
        print('about to call build results');
        Navigator.pop(context);
        buildResults(context);
        showResults(context);

      },
    );
  }

  void filterResultsList() {
    resultsList = resultsList.where((currentData) {
      bool includeCurrentData = false;
      for (int i = 0; i < selectedFilters.length; i++) {
        includeCurrentData = includeCurrentData ||
            currentData.collection.contains(selectedFilters[i]);
      }
      return includeCurrentData;
    }).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          }),
      IconButton(
        icon: const Icon(Icons.sort),
        onPressed: () {
          openFilterDialog(context);
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // close(context, "closing search");
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print('buildresults');
    resultsList =
        data.where((currentData) => currentData.title.contains(query)).toList();
    if (selectedFilters.isNotEmpty) {
      filterResultsList();
    }

    return ListView.builder(
        itemCount: resultsList.length,
        itemBuilder: (context, int index) {
          if (resultsList[index].collection == "Organizations") {
            return SearchResultItem(resultsList[index], Icons.apartment);
          }
          if (resultsList[index].collection == "Beneficiaries") {
            return SearchResultItem(resultsList[index], Icons.person);
          }
          if (resultsList[index].collection == "UrgentCases") {
            return SearchResultItem(resultsList[index], Icons.assistant);
          } else {
            return SearchResultItem(resultsList[index], Icons.apartment);
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<SearchResult> suggestionList = data
        .where((currentData) =>
            currentData.title.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

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
