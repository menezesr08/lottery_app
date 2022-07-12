// shortens ETH address to format 0x0000…0000
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String truncateEthAddress(String address) {
  if (address.isEmpty) {
    return '';
  }
  const pattern = r"(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})";
  RegExp regexp = RegExp(pattern);
  final match = regexp.allMatches(address).first.group;
  return "${match(1)}…${match(2)}";
}

void openDialog(BuildContext context) async {
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) => new AlertDialog(
      title: new Text("title"),
      content: new Text("Message"),
      actions: <Widget>[
        new ElevatedButton(
          child: new Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
