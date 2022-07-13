import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:lottery_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

import '../credentials/wallet_connect_credentials.dart';

class LotteryService extends ChangeNotifier {
  String winner = '';
  String account = '';
  String balance = '0';
  bool connected = false;
  String? sessionUrl;
  SessionStatus? session;
  late WalletConnectEthereumCredentials credentials;
  late DeployedContract contract;
  late Web3Client client;
  late Logger logger;

  LotteryService() {
    init();
  }

  Future<void> init() async {
    contract = await loadContract();
    client = Web3Client(infuraUrl, Client());
    logger = Logger();
    logger.d('Initializing deployed contract, client and logger');
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddress = lotteryContractAddress;
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'Lottery'),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<void> walletConnect() async {
    logger.d('Connecting your wallet...');
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'WalletConnect',
        description: 'WalletConnect Developer App',
        url: 'https://walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );

    connector.on('connect', (session) {
      logger.d('Connecting to WalletConnect bridge. Session details are: ');
      logger.d(session);
    });
    // this updates when you switch metamask accounts
    connector.on('session_update', (payload) {
      logger.d('Session is updating');
      WCSessionUpdateResponse res = payload as WCSessionUpdateResponse;
      account = res.accounts[0];
      notifyListeners();
    });
    connector.on('disconnect', (session) {
      logger.d('Session is disconnecting');
      connected = false;
      notifyListeners();
    });

    // Create a new session
    if (!connector.connected) {
      logger.d('Creating a new session on Metamask');
      session = await connector.createSession(
          chainId: 42,
          onDisplayUri: (uri) async {
            sessionUrl = uri;
            await launchUrl(Uri.parse(sessionUrl!));
          });
    }

    connected = true;
    account = session!.accounts[0];

    EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);
    credentials = WalletConnectEthereumCredentials(provider: provider);
    notifyListeners();
  }

  Future<String> sendEtherToContract() async {
    WalletConnectEthereumCredentials credentials = this.credentials;

    Transaction transaction = Transaction(
      from: EthereumAddress.fromHex(account),
      to: EthereumAddress.fromHex(lotteryContractAddress),
      gasPrice: await client.getGasPrice(),
      value: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 100000000),
      maxGas: null,
    );

    logger.d('Sending transaction...');
    _openMetamask();

    String result;
    try {
      result = await client.sendTransaction(
        credentials,
        transaction,
        fetchChainIdFromNetworkId: false,
        chainId: 42,
      );
      result = 'tx: $result';
      logger.d('send ether to contract hash is: $result');
    } catch (e) {
      logger.e('Transaction Failed. Message is: ${e.toString()}');
      result = e.toString();
    }

    return result;
  }

  Future<String> sendTransactionToFunction(String functionName) async {
    WalletConnectEthereumCredentials credentials = this.credentials;
    final ethFunction = contract.function(functionName);
    // don't need to send a value because we are just calling functions

    Transaction transaction = Transaction.callContract(
      from: EthereumAddress.fromHex(account),
      function: ethFunction,
      contract: contract,
      parameters: [],
      gasPrice: await client.getGasPrice(),
      value: null,
      maxGas: null,
    );

    logger.d('Sending transaction...');
    _openMetamask();

    String result;
    try {
      result = await client.sendTransaction(
        credentials,
        transaction,
        fetchChainIdFromNetworkId: false,
        chainId: 42,
      );
      result = 'tx: $result';
      logger.d('Sent transaction with tx: $result');
    } catch (e) {
      logger.e('Transaction Failed. Message is: ${e.toString()}');
      result = e.toString();
    }

    logger.d('Send prize transaction hash is: $result');
    return result;
  }

  Future<List<dynamic>> callFunction(String functionName) async {
    final ethFunction = contract.function(functionName);
    final result = await client.call(
        contract: contract,
        function: ethFunction,
        params: [],
        sender: EthereumAddress.fromHex(account));

    return result;
  }

  Future<void> getBalance() async {
    List<dynamic> res = await callFunction('getBalance');
    logger.d('The balance is: ${res[0].toString()}');

    balance = convertGweiToEth(res[0].toString());
    notifyListeners();
  }

  String convertGweiToEth(String amount) {
    return EtherAmount.fromUnitAndValue(EtherUnit.wei, amount)
        .getValueInUnit(EtherUnit.ether)
        .toString();
  }

  Future<void> pickWinner() async {
    await sendTransactionToFunction('pickWinner');
    Future.delayed(const Duration(seconds: 10), () async {
      await getWinner();
    });
  }

  Future<String> callSendPrize() async {
    String res = await sendTransactionToFunction('sendPrize');
    logger.d('callSendPrize result is: $res');
    Future.delayed(const Duration(seconds: 6), () async {
      await getWinner();
    });
    return res;
  }

  Future<void> getWinner() async {
    List<dynamic> res = await callFunction('winner');
    winner = res[0].toString();
    notifyListeners();
  }

  void _openMetamask() async {
    logger.d('Opening metamask...');
    await launchUrl(Uri.parse(sessionUrl!));
  }
}
