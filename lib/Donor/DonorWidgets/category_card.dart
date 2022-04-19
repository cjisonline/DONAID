import 'package:donaid/Donor/category_campaigns_screen.dart';
import 'package:flutter/material.dart';

// set up the charity card
class CharityCategoryCard extends StatelessWidget {
  final String name;
  final String iconDownloadURL;

  const CharityCategoryCard(this.name, this.iconDownloadURL, {Key? key})
      : super(key: key);

  // create the charity category card
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          // navigate to the Category campaigns screen
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return (CategoryCampaignsScreen(categoryName: name));
            }));
          },
          child: Container(
            height: 75,
              width: 150,
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                // display the category's icon
                SizedBox(
                  width: 25,
                  height: 25,
                  child: Image.network(
                  iconDownloadURL,
                  fit: BoxFit.contain,
                ),),
                // display the category's name
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      )),
                )
              ])),
        ));
  }
}
