import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:get/get.dart';

class OrganizationUserManual extends StatefulWidget {
  static const id = 'organization_user_manual';

  const OrganizationUserManual({Key? key}) : super(key: key);

  @override
  _OrganizationUserManualState createState() => _OrganizationUserManualState();
}

class _OrganizationUserManualState extends State<OrganizationUserManual> {
  bool _isLoading = true;
  late PDFDocument _pdf;

  void _loadFile() async {
    // Load the pdf file from the assets folder
    _pdf = await PDFDocument.fromAsset('assets/OrganizationUserManual.pdf');

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
        title: Text('Organization User Manual'.tr),
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
