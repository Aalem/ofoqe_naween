import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/screens/money_exchange/models/exchange_model.dart';
import 'package:ofoqe_naween/screens/money_exchange/services/exchange_service.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/theme/constants.dart';
import 'package:ofoqe_naween/values/strings.dart';

class AddExchange extends StatefulWidget {
  final String? id;
  final ExchangeModel? exchangeModel;

  const AddExchange({Key? key, this.id, this.exchangeModel}) : super(key: key);

  @override
  _AddExchangeState createState() => _AddExchangeState();
}

class _AddExchangeState extends State<AddExchange> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isEditingMode = false;
  ExchangeService exchangeService = ExchangeService();

  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _phoneNumber1TextController = TextEditingController();
  final TextEditingController _phoneNumber2TextController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();

  late String _name;
  late String _phoneNumber1;
  late String _phoneNumber2;
  late String _address;

  @override
  void initState() {
    super.initState();
    if (widget.exchangeModel != null) {
      isEditingMode = true;
      _nameTextController.text = widget.exchangeModel!.name;
      _phoneNumber1TextController.text = widget.exchangeModel!.phoneNumber1;
      _phoneNumber2TextController.text = widget.exchangeModel!.phoneNumber2;
      _addressTextController.text = widget.exchangeModel!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              CustomTextFormField(
                controller: _nameTextController,
                label: Strings.exchangeName,
                enabled: !_isLoading,
                validationMessage: Strings.enterName,
                onSaved: (value) => _name = value!,
              ),
              CustomTextFormField(
                controller: _phoneNumber1TextController,
                label: Strings.phone1,
                enabled: !_isLoading,
                validationMessage: Strings.enterValidPhone,
                keyboardType: TextInputType.phone,
                onSaved: (value) => _phoneNumber1 = value!,
                canBeEmpty: true,
              ),
              CustomTextFormField(
                controller: _phoneNumber2TextController,
                label: Strings.phone2,
                enabled: !_isLoading,
                validationMessage: Strings.enterValidPhone,
                keyboardType: TextInputType.phone,
                onSaved: (value) => _phoneNumber2 = value!,
                canBeEmpty: true,
              ),
              CustomTextFormField(
                controller: _addressTextController,
                label: Strings.address,
                enabled: !_isLoading,
                validationMessage: Strings.enterAddress,
                onSaved: (value) => _address = value!,
                canBeEmpty: true,
              ),
              const SizedBox(height: 20.0),
              buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: DialogButton(
            title: Strings.save,
            buttonType: ButtonType.positive,
            onPressed: _isLoading ? null : () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await _saveExchange();
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
            onPressed: _isLoading
                ? null
                : () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Future<void> _saveExchange() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final ExchangeModel exchange = ExchangeModel(
        name: _name,
        phoneNumber1: _phoneNumber1,
        phoneNumber2: _phoneNumber2,
        address: _address,
        id: widget.id ?? '',
      );

      if (widget.exchangeModel == null) {
        await exchangeService.addExchange(exchange);
      } else {
        await exchangeService.updateExchange(widget.id!, exchange.toMap());
      }

      NotificationService().showSuccess(
          context,
          widget.id == null
              ? Strings.exchangeAddedSuccessfully
              : Strings.exchangeUpdatedSuccessfully);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      NotificationService().showError(
          context,
          widget.id == null
              ? Strings.errorAddingExchange
              : Strings.errorUpdatingExchange);
    }
  }
}
