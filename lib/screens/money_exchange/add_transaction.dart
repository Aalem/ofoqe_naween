import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/transaction_model.dart';
import 'package:ofoqe_naween/screens/money_exchange/services/money_exchange_service.dart';
import 'package:ofoqe_naween/screens/money_exchange/providers/balance_provider.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/theme/constants.dart';
import 'package:ofoqe_naween/values/strings.dart';

class AddTransaction extends StatefulWidget {
  final String? id;

  const AddTransaction({Key? key, this.id}) : super(key: key);

  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false, isBalanceLoaded = false;
  bool paymentError = false;
  MEPaymentType? _selectedPaymentType;

  late String _description;
  late double _amount = 0;
  late double _balance = 0;
  final TextEditingController _jalaliDateTextController =
      TextEditingController();
  final TextEditingController _gregorianDateTextController =
      TextEditingController();
  final TextEditingController _balanceTextController = TextEditingController();
  Jalali? _selectedDate;

  Future<void> fetchCurrentBalance(BuildContext context) async {
    try {
      _balance = await MoneyExchangeService.getCurrentBalance();
      setBalanceText(_balance);
      Provider.of<BalanceProvider>(context, listen: false)
          .updateBalance(_balance);
    } catch (e) {
      print('Error fetching current balance: $e');
    }
  }

  void setBalanceText(double balance) {
    _balanceTextController.text =
        balance < 0 ? '${balance.abs()} -' : balance.toString();
  }

  void updateBalance(BalanceProvider balanceProvider) {
    balanceProvider.updateBalance(calculateBalance(_balance, _amount));
    setBalanceText(balanceProvider.balance);
  }

  @override
  Widget build(BuildContext context) {
    if(!isBalanceLoaded){
      fetchCurrentBalance(context);
      isBalanceLoaded = true;
    }
    return ChangeNotifierProvider<BalanceProvider>(
      create: (_) => BalanceProvider(),
      child: Consumer<BalanceProvider>(builder: (context, balanceProvider, _) {
        return SizedBox(
          width: MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width / 2
              : null,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildDateFields(),
                  CustomTextFormField(
                    label: Strings.description,
                    enabled: !_isLoading,
                    validationMessage: Strings.enterDescription,
                    onSaved: (value) => _description = value!,
                  ),
                  buildPaymentTypeSelection(balanceProvider),
                  buildAmountAndBalanceFields(balanceProvider),
                  const SizedBox(height: 20.0),
                  buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildDateFields() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: _jalaliDateTextController,
            label: Strings.jalaliDate,
            readOnly: true,
            validationMessage: Strings.selectADate,
            onTap: () async {
              final Jalali? picked = await showDariDatePicker(
                context: context,
                initialDate: _selectedDate ?? Jalali.now(),
                firstDate: Jalali(1385, 8),
                lastDate: Jalali(1450, 9),
                initialEntryMode: DDatePickerEntryMode.calendarOnly,
                initialDatePickerMode: DDatePickerMode.day,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData(
                      dialogTheme: const DialogTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _jalaliDateTextController.text =
                      _selectedDate!.formatCompactDate();
                  _gregorianDateTextController.text =
                      intl.DateFormat.yMd().format(
                    _selectedDate!.toGregorian().toDateTime(),
                  );
                });
              }
            },
          ),
        ),
        Expanded(
          child: CustomTextFormField(
            controller: _gregorianDateTextController,
            label: Strings.gregorianDate,
            readOnly: true,
            validationMessage: Strings.selectADate,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate:
                    _selectedDate?.toGregorian().toDateTime() ?? DateTime.now(),
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked.toJalali();
                  _jalaliDateTextController.text =
                      _selectedDate!.formatCompactDate();
                  _gregorianDateTextController.text =
                      intl.DateFormat.yMd().format(
                    _selectedDate!.toGregorian().toDateTime(),
                  );
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildPaymentTypeSelection(BalanceProvider balanceProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.textFieldBGColor,
            border: Border.all(
              color: paymentError
                  ? AppColors.errorColor
                  : AppColors.textFieldBorderColor,
              width: 1.0,
            ),
            borderRadius: textFieldBorderRadius,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  title: const Text(Strings.debit),
                  leading: Radio<MEPaymentType>(
                    value: MEPaymentType.debit,
                    groupValue: _selectedPaymentType,
                    onChanged: (MEPaymentType? value) {
                      setState(() {
                        _selectedPaymentType = value;
                        updateBalance(balanceProvider);
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text(Strings.credit),
                  leading: Radio<MEPaymentType>(
                    value: MEPaymentType.credit,
                    groupValue: _selectedPaymentType,
                    onChanged: (MEPaymentType? value) {
                      setState(() {
                        _selectedPaymentType = value;
                        updateBalance(balanceProvider);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: paymentError,
          child: Padding(
            padding: const EdgeInsets.only(right: 14, bottom: 8),
            child: Text(
              Strings.paymentTypeNotSelected,
              style: TextStyle(color: AppColors.errorColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAmountAndBalanceFields(BalanceProvider balanceProvider) {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            label: Strings.amount,
            suffixIcon: Icons.attach_money,
            enabled: !_isLoading,
            keyboardType: TextInputType.number,
            validationMessage: Strings.enterAmount,
            onSaved: (value) => _amount = double.tryParse(value!)!,
            onChanged: (val) {
              val = val!.isEmpty ? '0' : val;
              _amount = double.tryParse(val)!;
              updateBalance(balanceProvider);
            },
          ),
        ),
        Expanded(
          child: CustomTextFormField(
            controller: _balanceTextController,
            textStyle: TextStyle(
                color: balanceProvider.balance > 0 ? Colors.green : Colors.red),
            label: Strings.balance,
            suffixIcon: Icons.attach_money,
            enabled: false,
            keyboardType: TextInputType.number,
            validationMessage: Strings.enterCredit,
          ),
        ),
      ],
    );
  }

  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: DialogButton(
            title: Strings.save,
            buttonType: ButtonType.positive,
            onPressed: _isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (_selectedPaymentType != null) {
                        await _saveTransaction();
                      } else {
                        setState(() {
                          paymentError = true;
                        });
                      }
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(Strings.save),
                if (_isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: DialogButton(
            buttonType: ButtonType.negative,
            title: Strings.cancel,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text(Strings.dialogCancelTitle),
                      content: const Text(Strings.dialogCancelMessage),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text(Strings.yes),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(Strings.no),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  double calculateBalance(double currentBalance, double amount) {
    return _selectedPaymentType == MEPaymentType.debit
        ? currentBalance + amount
        : currentBalance - amount;
  }

  Future<void> _saveTransaction() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final double newBalance = calculateBalance(_balance, _amount);

      final TransactionModel transaction = TransactionModel(
        jalaliDate: _selectedDate!.toString(),
        gregorianDate: _selectedDate!.toDateTime(),
        date: DateTime.now(),
        description: _description,
        debit: _selectedPaymentType == MEPaymentType.debit ? _amount : 0,
        credit: _selectedPaymentType == MEPaymentType.credit ? _amount : 0,
        id: '',
      );

      await MoneyExchangeService.addTransaction(transaction);
      await MoneyExchangeService.updateBalance(newBalance);

      NotificationService()
          .showSuccess(context, Strings.transactionAddedSuccessfully);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      NotificationService().showError(context, Strings.errorAddingTransaction);
    }
  }
}
