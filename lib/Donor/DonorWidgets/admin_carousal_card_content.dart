import 'package:donaid/Models/AdminCarouselImage.dart';
import 'package:flutter/material.dart';

class AdminCarouselCardContent extends StatefulWidget {
  final AdminCarouselImage carouselImage;
  const AdminCarouselCardContent(this.carouselImage, {Key? key}) : super(key: key);

  @override
  _AdminCarouselCardContentState createState() => _AdminCarouselCardContentState();
}

class _AdminCarouselCardContentState extends State<AdminCarouselCardContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.network(
          widget.carouselImage.pictureDownloadURL.toString(),
          fit: BoxFit.contain,
        ),),
    );
  }
}
