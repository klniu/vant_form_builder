import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class DateTimeField extends StatelessWidget {
  final String name;
  final String label;
  final bool required;
  final FormFieldValidator validator;
  final DateTime defaultTime;
  final InputType inputType;
  final String placeholder;

  const DateTimeField(this.name,
      {Key key,
      this.label,
      this.required = false,
      this.validator,
      this.inputType: InputType.date,
      this.placeholder,
      this.defaultTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderDateTimePicker(
        name: this.name,
        // onChanged: _onChanged,
        format: DateFormat('yyyy-MM-dd HH:mm:ss'),
        inputType: this.inputType,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: this.label + (this.required ? " *" : ''),
          labelStyle: this.required ? TextStyle(color: Colors.red) : null,
          hintText: this.placeholder ?? "请输入" + this.label,
        ),
        initialValue: this.defaultTime,
        validator: this.validator);
  }
}
