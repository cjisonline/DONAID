import 'package:donaid/Models/SearchResult.dart';
import 'package:flutter/material.dart';

class SearchResultItem extends StatelessWidget {
  final SearchResult searchResult;
  final IconData iconData;

  const SearchResultItem(this.searchResult, this.iconData, {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Icon(
                  iconData,
                  color: Colors.blue,
                  size: 40,
                ),
                Text(searchResult.title),
              ],
            ),
            subtitle: Text(searchResult.description),
          ),
          const Divider()
        ],
      ),
    );
  }
}
