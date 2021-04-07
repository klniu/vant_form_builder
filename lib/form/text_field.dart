import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomTextField extends StatefulWidget {
  final String name;
  final String label;
  final bool required;
  final FormFieldValidator validator;
  final int rows;
  final int maxLength;
  final String defaultValue;
  final String placeholder;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final Function(String) onChange;
  final bool disabled;
  final bool obscureText;
  final TextAlign inputAlign;
  final Widget prefixIcon;

  const CustomTextField(this.name,
      {Key key,
        this.label,
        this.required = false,
        this.validator,
        this.rows = 1,
        this.maxLength,
        this.placeholder,
        this.keyboardType,
        this.defaultValue,
        this.inputFormatters,
        this.onChange,
        this.disabled = false,
        this.obscureText = false,
        this.inputAlign = TextAlign.start,
        this.prefixIcon
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.name,
      decoration: InputDecoration(
          labelText: widget.label + (widget.required ? " *" : ''),
          labelStyle: widget.required ? TextStyle(color: Colors.red) : null,
          hintText: widget.placeholder ?? "请输入" + widget.label,
          suffix: widget.obscureText ? InkWell(
            onTap: () {
              setState(() {
                _isHidden = !_isHidden;
              });
            },
            child: Icon(Icons.visibility),
          ) : null,
          prefixIcon: widget.prefixIcon
      ),
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLines: widget.rows,
      textAlign: widget.inputAlign,
      validator: widget.validator,
      enabled: !widget.disabled,
      initialValue: widget.defaultValue,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.obscureText && _isHidden,
    );
  }
}
