import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/dialogs/dialog_button.dart';
import 'package:ofoqe_naween/components/text_form_fields/text_form_field.dart';
import 'package:ofoqe_naween/services/notification_service.dart';
import 'package:ofoqe_naween/utilities/responsiveness_helper.dart';
import 'package:ofoqe_naween/values/enums/enums.dart';
import 'package:ofoqe_naween/values/strings.dart';

class FieldConfig {
  final String label;
  final String? initialValue;
  final String? validationMessage;
  final bool canBeEmpty;
  final TextInputType? keyboardType;
  final int? maxLines;
  final void Function(String?)? onSaved;
  final Widget? customWidget;

  FieldConfig({
    required this.label,
    this.initialValue,
    this.validationMessage,
    this.canBeEmpty = false,
    this.keyboardType,
    this.maxLines,
    this.onSaved,
    this.customWidget,
  });
}

class GenericAddPage<T> extends StatefulWidget {
  final T? model;
  final String? id;
  final List<FieldConfig> fields;
  final Future<void> Function(T, String?) saveService;
  final String addTitle;
  final String editTitle;
  final String addSuccessMessage;
  final String editSuccessMessage;
  final String errorMessage;

  const GenericAddPage({
    super.key,
    this.model,
    this.id,
    required this.fields,
    required this.saveService,
    required this.addTitle,
    required this.editTitle,
    required this.addSuccessMessage,
    required this.editSuccessMessage,
    required this.errorMessage,
  });

  @override
  _GenericAddPageState<T> createState() => _GenericAddPageState<T>();
}

class _GenericAddPageState<T> extends State<GenericAddPage<T>> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600
          ? MediaQuery.of(context).size.width / 2
          : MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...ResponsiveHelper.genResponsiveWidgets(
                widget.fields.map((config) {
                  return config.customWidget != null
                      ? config.customWidget!
                      : CustomTextFormField(
                    enabled: !_isLoading,
                    label: config.label,
                    controller: TextEditingController(text: config.initialValue),
                    validationMessage: config.validationMessage,
                    canBeEmpty: config.canBeEmpty,
                    keyboardType: config.keyboardType,
                    maxLines: config.maxLines,
                    onSaved: config.onSaved,
                  );
                }).toList(),
                context,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: DialogButton(
                      buttonType: ButtonType.positive,
                      title: Strings.save,
                      onPressed: _isLoading
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await _saveToFirestore();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: DialogButton(
                      title: Strings.cancel,
                      buttonType: ButtonType.negative,
                      onPressed: _isLoading
                          ? null
                          : () {
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
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      Navigator.pop(context);
      await widget.saveService(widget.model as T, widget.id);
      NotificationService().showSuccess(
        widget.id != null ? widget.editSuccessMessage : widget.addSuccessMessage,
      );
    } catch (e) {
      NotificationService().showError(widget.errorMessage);
      setState(() => _isLoading = false);
    }
  }
}