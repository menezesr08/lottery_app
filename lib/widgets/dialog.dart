import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, text;

  const CustomDialog(this.title, this.text, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget>[
        ElevatedButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
