import 'package:flutter/material.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/exchanges.dart';
import 'package:ofoqe_naween/pages/money_exchange/pages/transactions.dart';
import 'package:ofoqe_naween/pages/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
import 'package:ofoqe_naween/values/strings.dart';

class MoneyExchangeHome extends StatefulWidget {
  @override
  _MoneyExchangeHomeState createState() => _MoneyExchangeHomeState();
}

class _MoneyExchangeHomeState extends State<MoneyExchangeHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: StreamBuilder<double>(
              stream: MoneyExchangeService.getBalanceStream(),
              builder: (context, snapshot) {
                double balance = snapshot.hasData ? snapshot.data! : 0.0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(Strings.moneyExchange),
                    Text(
                      '${Strings.balance}: ${GeneralFormatter.formatNumber(balance.abs().toString()).split('.')[0]}${balance >= 0 ? '\$ ' : ' - \$'}',
                      // textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: balance >= 0
                              ? Colors.green
                              : Colors.red), // Set text alignment to start
                    ),
                  ],
                );
              },
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: Strings.transactions),
                Tab(text: Strings.moneyExchanges),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              TransactionsPage(),
              const ExchangesPage(),
            ],
          )),
    );
  }
}
