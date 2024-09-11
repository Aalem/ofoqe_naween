import 'package:dari_datetime_picker/dari_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:ofoqe_naween/utilities/formatter.dart';
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
  final TransactionModel? transactionModel;

  const AddTransaction({Key? key, this.id, this.transactionModel})
      : super(key: key);

  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool paymentError = false;
  bool isEditingMode = false;
  MEPaymentType? _selectedPaymentType;
  late double _balance = 0;
  late double _initialBalance = 0;
  late String _description;
  late double _amount = 0;
  final TextEditingController _descriptionTextController =
      TextEditingController();
  final TextEditingController _amountTextController = TextEditingController();
  final TextEditingController _jalaliDateTextController =
      TextEditingController();
  final TextEditingController _gregorianDateTextController =
      TextEditingController();
  final TextEditingController _balanceTextController = TextEditingController();
  late String _initialDescription = '';
  late double _initialAmount = 0;
  MEPaymentType? _initialPaymentType;
  late String _initialJalaliDate;
  late String _initialGregorianDate;

  Jalali? _selectedDate;
  TransactionModel? _transaction;

  @override
  void initState() {
    super.initState();
    if (widget.transactionModel != null) {
      isEditingMode = true;
      _transaction = widget.transactionModel;
      _selectedPaymentType =
          _transaction!.credit > 0 ? MEPaymentType.credit : MEPaymentType.debit;
      _descriptionTextController.text = _transaction!.description;
      _amount =
          _transaction!.debit > 0 ? _transaction!.debit : _transaction!.credit;
      _amountTextController.text = _amount.toString();
      _jalaliDateTextController.text =
          Jalali.fromDateTime(_transaction!.gregorianDate).formatCompactDate();
      _gregorianDateTextController.text =
          GeneralFormatter.formatDate(_transaction!.gregorianDate.toString());

      // Save initial values
      _initialDescription = _transaction!.description;
      _initialAmount = _amount;
      _initialPaymentType = _selectedPaymentType;
      _initialJalaliDate = _jalaliDateTextController.text;
      _initialGregorianDate = _gregorianDateTextController.text;
    }
    _fetchCurrentBalance();
  }

  Future<void> _fetchCurrentBalance() async {
    try {
      _balance = await MoneyExchangeService.getCurrentBalance();
      _initialBalance = _balance;
      _updateBalanceText();
      setState(() {});
    } catch (e) {
      print('Error fetching current balance: $e');
    }
  }

  void _updateBalanceText() {
    _balanceTextController.text =
        _balance < 0 ? '${_balance.abs()} -' : _balance.toString();
  }

  void formatBalance(String value) {
    final formattedPrice =
        GeneralFormatter.formatAndRemoveTrailingZeros(double.parse(value));
    _balanceTextController.value = TextEditingValue(
      text: formattedPrice.isEmpty ? 0.toString() : formattedPrice,
      selection: TextSelection.collapsed(offset: formattedPrice.length),
    );
  }

  void _updateBalance(BalanceProvider balanceProvider) {
    _balance = _calculateBalance(_initialBalance, _amount);
    formatBalance(_balance.toString());
    balanceProvider.updateBalance(_balance);
  }

  double _calculateBalance(double currentBalance, double newAmount) {
    if (isEditingMode) {
      double initialAmount = widget.transactionModel!.debit > 0
          ? widget.transactionModel!.debit
          : widget.transactionModel!.credit;
      double amountDifference = newAmount - initialAmount;

      if (_selectedPaymentType == MEPaymentType.debit) {
        return widget.transactionModel!.debit > 0
            ? currentBalance + amountDifference
            : currentBalance + initialAmount + newAmount;
      } else {
        return widget.transactionModel!.credit > 0
            ? currentBalance - amountDifference
            : currentBalance - initialAmount - newAmount;
      }
    } else {
      // For new transactions, adjust the balance directly with the new amount
      return _selectedPaymentType == MEPaymentType.debit
          ? currentBalance + newAmount
          : currentBalance - newAmount;
    }
  }

  bool _hasUnsavedChanges() {
    // print('${_descriptionTextController.text} / $_initialDescription');
    // print('${_amountTextController.text} / $_initialAmount');
    // print('${_selectedPaymentType} / ${_initialPaymentType??0}');
    // print('${_jalaliDateTextController.text} / $_initialJalaliDate');
    // print('${_gregorianDateTextController.text} / $_initialGregorianDate');
    return _descriptionTextController.text != _initialDescription ||
        _amountTextController.text != _initialAmount.toString() ||
        _selectedPaymentType != _initialPaymentType ||
        _jalaliDateTextController.text != _initialJalaliDate ||
        _gregorianDateTextController.text != _initialGregorianDate;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BalanceProvider>(
      create: (_) => BalanceProvider(),
      child: Consumer<BalanceProvider>(
        builder: (context, balanceProvider, _) {
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
                      controller: _descriptionTextController,
                      label: Strings.description,
                      enabled: !_isLoading,
                      validationMessage: Strings.enterDescription,
                      onSaved: (value) => _description = value!,
                      onChanged: (val) {
                        setState(() {});
                      },
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
        },
      ),
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
                      GeneralFormatter.formatDate(
                          _selectedDate!.toGregorian().toDateTime().toString());
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
              DateTime initialGregorianDate =
                  _selectedDate?.toGregorian().toDateTime() ?? DateTime.now();
              DateTime now = DateTime.now();
              DateTime firstDate = DateTime(2020, 1, 1);
              DateTime lastDate = now;

              // Ensure the initial date is within the allowable range
              if (initialGregorianDate.isAfter(lastDate)) {
                initialGregorianDate = lastDate;
              } else if (initialGregorianDate.isBefore(firstDate)) {
                initialGregorianDate = firstDate;
              }

              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initialGregorianDate,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked.toJalali();
                  _jalaliDateTextController.text =
                      _selectedDate!.formatCompactDate();
                  _gregorianDateTextController.text =
                      GeneralFormatter.formatDate(
                          _selectedDate!.toGregorian().toDateTime().toString());
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
                        _updateBalance(balanceProvider);
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
                        _updateBalance(balanceProvider);
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
            controller: _amountTextController,
            label: Strings.amount,
            suffixIcon: Icons.attach_money,
            enabled: !_isLoading && _selectedPaymentType != null,
            keyboardType: TextInputType.number,
            validationMessage: Strings.enterAmount,
            onSaved: (value) {
              String? rawValue = value?.replaceAll(',', '');
              _amount = double.tryParse(rawValue!)!;
              _updateBalance(balanceProvider);
            },
            onChanged: (val) {
              val = val!.isEmpty ? '0' : val;
              setState(() {
                _amount = double.tryParse(val!)!;
                _updateBalance(balanceProvider);
              });
            },
          ),
        ),
        Expanded(
          child: CustomTextFormField(
            controller: _balanceTextController,
            textStyle:
                TextStyle(color: _balance >= 0 ? Colors.green : Colors.red),
            label: Strings.balance,
            suffixIcon: Icons.attach_money,
            enabled: false,
            keyboardType: TextInputType.number,
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
            onPressed: _isLoading || !_hasUnsavedChanges()
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
            onPressed: (!_isLoading && _hasUnsavedChanges())
                ? () {
                    print('$_isLoading');
                    print(_hasUnsavedChanges());
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
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
                        );
                      },
                    );
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _saveTransaction() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final double newBalance = _calculateBalance(_initialBalance, _amount);

      final TransactionModel transaction = TransactionModel(
        jalaliDate: _selectedDate != null
            ? _selectedDate!.toString()
            : widget.transactionModel!.jalaliDate,
        gregorianDate: _selectedDate != null
            ? _selectedDate!.toDateTime()
            : widget.transactionModel!.gregorianDate,
        date: DateTime.now(),
        description: _description,
        debit: _selectedPaymentType == MEPaymentType.debit ? _amount : 0,
        credit: _selectedPaymentType == MEPaymentType.credit ? _amount : 0,
        id: widget.id ?? '',
        //TODO: fix exchange ID ?
        exchangeId: '',
        exchangeName: ''
      );

      if (widget.transactionModel == null) {
        await MoneyExchangeService.addTransaction(transaction);
      } else {
        await MoneyExchangeService.updateTransaction(
            widget.id!, transaction.toMap());
      }

      await MoneyExchangeService.updateBalance(newBalance);

      NotificationService().showSuccess(
          context,
          widget.id == null
              ? Strings.transactionAddedSuccessfully
              : Strings.transactionUpdatedSuccessfully);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      NotificationService().showError(
          context,
          widget.id == null
              ? Strings.errorAddingTransaction
              : Strings.errorUpdatingTransaction);
    }
  }
}
