import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, text;

  const CustomDialog(this.title, this.text, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
              title: new Text(title),
              content: new Text(text),
              actions: <Widget>[
                new ElevatedButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
  }
}
