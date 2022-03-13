import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopUpSuccessDialog extends StatefulWidget {
  const PopUpSuccessDialog({Key? key}) : super(key: key);

  @override
  _PopUpSuccessDialogState createState() => _PopUpSuccessDialogState();
}

class _PopUpSuccessDialogState extends State<PopUpSuccessDialog> {
  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: const Text('Success'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("The information you entered has been added."),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
