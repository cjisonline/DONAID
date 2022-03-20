import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopUpSuccessDialog extends StatefulWidget {
  const PopUpSuccessDialog({Key? key}) : super(key: key);

  @override
  _PopUpSuccessDialogState createState() => _PopUpSuccessDialogState();
}

class _PopUpSuccessDialogState extends State<PopUpSuccessDialog> {
  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title:  Text('success'.tr),
      content:  new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("the_information_you_entered+has_been_added".tr),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: Text('close'.tr),
        ),
      ],
    );
  }
}
