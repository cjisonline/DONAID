import 'package:donaid/Donor/DonorWidgets/category_campaigns_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CharityCategoryCard extends StatelessWidget {
  final String name;
  final _firebaseStorage = FirebaseStorage.instance;

  CharityCategoryCard(this.name, {Key? key}) : super(key: key);

  Future<String> downloadURL(String imageName) async {
    String downloadURL = await _firebaseStorage
        .ref()
        .child('icons/')
        .child('$imageName.png')
        .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return(CategoryCampaignsScreen(categoryName: name));
            }));
          },
          child: Container(
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(children: [
                const SizedBox(
                  width: 5,
                ),
                FutureBuilder(
                    future: downloadURL(name),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return SizedBox(
                          width: 25,
                          height: 25,
                          child: Image.network(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return const CircularProgressIndicator(color: Colors.white);
                      }
                      return const CircularProgressIndicator(color: Colors.white);
                    }),
                Container(
                  margin: const EdgeInsets.only(left: 0.0, right: 10.0),
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
