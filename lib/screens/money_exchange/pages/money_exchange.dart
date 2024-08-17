import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/buttons/button_icon.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/no_data.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/screens/money_exchange/pages/add_transaction.dart';
import 'package:ofoqe_naween/screens/money_exchange/collection_fields/collection_fields.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/transaction_model.dart';
import 'package:ofoqe_naween/screens/money_exchange/pages/transactions.dart';
import 'package:ofoqe_naween/screens/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/theme/constants.dart';
import 'package:ofoqe_naween/utilities/date_time_utils.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
import 'package:ofoqe_naween/utilities/screen_size.dart';
import 'package:ofoqe_naween/values/collection_names.dart';
import 'package:ofoqe_naween/values/strings.dart';

class MoneyExchange extends StatefulWidget {
  @override
  _MoneyExchangeState createState() => _MoneyExchangeState();
}

class _MoneyExchangeState extends State<MoneyExchange> {

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
                children: [
                  Expanded(
                      child: Text(
                    '${balance >= 0 ? '\$ ' : '\$ - '}${Strings.balance}: ${GeneralFormatter.formatNumber(balance.abs().toString()).split('.')[0]}',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: balance >= 0
                            ? Colors.green
                            : Colors.red), // Set text alignment to start
                  )),
                  const Text(Strings.moneyExchange, textAlign: TextAlign.right),
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
            TransactionsPage(),
          ],
        )
      ),
    );
  }

}
