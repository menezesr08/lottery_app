import 'package:flutter/material.dart';
import 'package:lottery_app/widgets/home_page.dart';
import 'package:provider/provider.dart';
import 'services/lottery_service.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => LotteryService(),
    child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),
  ));
}


