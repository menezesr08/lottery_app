import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/lottery_service.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';
import 'dialog.dart';

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
                    const Text('Account:',
                        style: TextStyle(fontSize: 30, color: Colors.black)),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      truncateEthAddress(lotteryService.account),
                      style: const TextStyle(
                          fontSize: 20, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: lotteryService.account.isEmpty
                    ? null
                    : () async {
                        String result =
                            await lotteryService.sendEtherToContract();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog('Transaction output', result);
                            });
                      },
                child: const Text("Send 0.001 Ether"),
              ),
              ElevatedButton(
                onPressed: lotteryService.account.toUpperCase() !=
                        managerPublicKey.toUpperCase()
                    ? null
                    : () async {
                        await lotteryService.getBalance();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return const CustomDialog(
                                  'Balance has been updated', '');
                            });
                      },
                child: const Text("Get Balance"),
              ),
              ElevatedButton(
                onPressed: lotteryService.account.toUpperCase() !=
                        managerPublicKey.toUpperCase()
                    ? null
                    : () async {
                        await lotteryService.pickWinner();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return const CustomDialog(
                                  'Winner has been randomly selected!',
                                  'Please wait a few seconds for transaction to be completed.');
                            });
                      },
                child: const Text("Pick Winner"),
              ),
              ElevatedButton(
                onPressed: lotteryService.winner.isEmpty ||
                        lotteryService.account.toUpperCase() !=
                            managerPublicKey.toUpperCase()
                    ? null
                    : () async {
                        String result = await lotteryService.callSendPrize();
                        await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog('Transaction output', result);
                            });
                      },
                child: const Text("Send Prize"),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Balance: ${lotteryService.balance} ETH',
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Winner: ${truncateEthAddress(lotteryService.winner)}',
                    style: const TextStyle(
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
