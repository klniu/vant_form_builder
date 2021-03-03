import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class DateTimeField extends StatefulWidget {
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
  _DateTimeFieldState createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  @override
  Widget build(BuildContext context) {
    return FormBuilderDateTimePicker(
        name: widget.name,
        // onChanged: _onChanged,
        inputType: widget.inputType,
        decoration: InputDecoration(
            labelText: widget.label + (widget.required ? " *" : ''),
            labelStyle: widget.required ? TextStyle(color: Colors.red) : null,
            hintText: widget.placeholder ?? "请输入" + widget.label),
        initialValue: widget.defaultTime,
        validator: widget.validator);
  }
}
