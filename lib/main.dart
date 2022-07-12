import 'package:flutter/material.dart';
import 'package:lottery_app/utils/constants.dart';
import 'package:lottery_app/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'utils/helper.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var lotteryService = context.watch<LotteryService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lottery App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connect Button
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary:
                        !lotteryService.connected ? Colors.red : Colors.green),
                onPressed: () async {
                  await lotteryService.walletConnect();
                  await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog('Connection attempt',
                            'Metamask wallet connection: ${lotteryService.connected}');
                      });
                },
                child: const Text(
                  'Connect',
                  style: TextStyle(fontSize: 25, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5),
                ),
                child: Row(
                  children: [
                    Text('Account:',
                        style: TextStyle(fontSize: 30, color: Colors.black)),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      truncateEthAddress(lotteryService.account),
                      style: TextStyle(fontSize: 20, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: lotteryService.account.isEmpty
                    ? null
                    : () async {
                        String result = await lotteryService.sendEtherToContract();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog('Transaction output', 
                              result
                              );
                            });
                      },
                child: Text("Send 0.001 Ether"),
              ),
              ElevatedButton(
                onPressed: lotteryService.account != managerPublicKey
                    ? null
                    : () async {
                        await lotteryService.getBalance();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                  'Balance has been updated', '');
                            });
                      },
                child: Text("Get Balance"),
              ),
              ElevatedButton(
                onPressed: lotteryService.account != managerPublicKey
                    ? null
                    : () async {
                        await lotteryService.pickWinner();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                  'Winner has been randomly selected!',
                                  'Please wait a few seconds for transaction to be completed.');
                            });
                      },
                child: Text("Pick Winner"),
              ),
              ElevatedButton(
                onPressed: lotteryService.winner.isEmpty ||
                        lotteryService.account != managerPublicKey
                    ? null
                    : () async {
                        String result = await lotteryService.callSendPrize();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                  'Transaction output',
                                  result);
                            });
                           
                      },
                child: Text("Send Prize"),
              ),
            ],
          ),
          Center(
            child: Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Balance: ${lotteryService.balance}',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Winner: ${truncateEthAddress(lotteryService.winner)}',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
