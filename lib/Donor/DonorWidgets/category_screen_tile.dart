import 'package:donaid/Models/CharityCategory.dart';
import 'package:flutter/material.dart';
import '../category_campaigns_screen.dart';

class CategoryScreenTile extends StatefulWidget {
  final CharityCategory charityCategory;

  const CategoryScreenTile({Key? key, required this.charityCategory})
      : super(key: key);

  @override
  State<CategoryScreenTile> createState() => _CategoryScreenTileState();
}

class _CategoryScreenTileState extends State<CategoryScreenTile> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context){
            return(CategoryCampaignsScreen(categoryName: widget.charityCategory.name));
        }
        )).then((value){
          setState(() {

          });
        });
      },
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    widget.charityCategory.iconDownloadURL,
                    fit: BoxFit.contain,
                  ),
                  ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(widget.charityCategory.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                      )),
                )
              ]))),
    );
  }
}
