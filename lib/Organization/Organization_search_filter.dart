
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//
// class CloudFirestoreSearch extends StatefulWidget {
//   static const id = 'organization_search_filter';
//   const CloudFirestoreSearch({Key? key}) : super(key: key);
//   @override
//   _CloudFirestoreSearchState createState() => _CloudFirestoreSearchState();
// }
//
// class _CloudFirestoreSearchState extends State<CloudFirestoreSearch> {
//   String name = "";
//   final _firestore = FirebaseFirestore.instance;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         title: Card(
//           child: TextField(
//             decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.search), hintText: 'Search...'),
//             onChanged: (val) {
//               setState(() {
//                 name = val;
//               });
//             },
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: (name != "" && name != null)
//             ? _firestore
//             .collection('Campaigns')
//             .where('title', arrayContains: name)
//             .snapshots()
//             : _firestore.collection("Campaigns").snapshots(),
//         builder: (context, snapshot) {
//           return (snapshot.connectionState == ConnectionState.waiting)
//               ? Center(child: CircularProgressIndicator())
//               : ListView.builder(
//             itemCount: snapshot.data?.docs.length,
//             itemBuilder: (context, index) {
//               DocumentSnapshot data = snapshot.data?.docs[index] as DocumentSnapshot<Object?>;
//               return Card(
//                 child: Row(
//                   children: <Widget>[
//                     Text(
//                       data['title'],
//                       style: TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 20,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 25,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
// }


class SearchPage extends StatefulWidget {
  static const id = 'organization_search_filter';

  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchAppBarDelegate createState() => SearchAppBarDelegate();
}


class SearchAppBarDelegate extends State<SearchPage>  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: _SearchAppBarDelegate());
            },
          )
        ],
      ),
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
    List<Item> suggestionList = query.isEmpty
        ? items
        : items.where((element) => element.title.startsWith(query)).toList();
    return suggestionList.isEmpty
        ? Text("no result found")
        : ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].title),
          onTap: () {
            showResults(context);
          },
        );
      },
      itemCount: suggestionList.length,
    );
  }
}

class Item {
  final String title;

  Item({required this.title});
}

List<Item> items = [
  Item(title: 'dfdf'),
  Item(title: 'sfd'),
  Item(title: 'dfsd'),
  Item(title: 'gtrfg'),
  Item(title: 'fgdfg'),
  Item(title: 'roke'),
];