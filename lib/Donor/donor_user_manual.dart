import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:get/get.dart';

class DonorUserManual extends StatefulWidget {
  static const id = 'donor_user_manual';

  const DonorUserManual({Key? key}) : super(key: key);

  @override
  _DonorUserManualState createState() => _DonorUserManualState();
}

class _DonorUserManualState extends State<DonorUserManual> {
  bool _isLoading = true;
  late PDFDocument _pdf;

  void _loadFile() async {
    // Load the pdf file from the assets folder
    _pdf = await PDFDocument.fromAsset('assets/DonorUserManual.pdf');

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFile();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Donor User Manual'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child:_isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(document: _pdf),
      ),
    );
  }
}
