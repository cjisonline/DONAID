import 'package:flutter/material.dart';

class SearchSuggestionItem extends StatelessWidget {
  final String title;
  final IconData iconData;

  const SearchSuggestionItem( this.title, this.iconData, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container (
        padding: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(iconData, color: Colors.blue, size: 40,),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child : Text(
                        title,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    )])

            ])

    );

  }
}
