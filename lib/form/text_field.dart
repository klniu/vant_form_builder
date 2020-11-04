import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vant_kit/theme/style.dart';
import 'package:flutter_vant_kit/widgets/field.dart';

class CustomTextField extends StatefulWidget {
  final String name;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final String type;
  final int rows;
  final int maxLength;
  final bool showWordLimit;
  final String defaultValue;
  final String placeholder;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final Function(String) onChange;
  final bool disabled;

  const CustomTextField(this.name,
      {Key key,
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.type,
      this.rows,
      this.maxLength,
      this.showWordLimit,
      this.placeholder,
      this.keyboardType,
      this.defaultValue,
        this.inputFormatters,
      this.onChange,
      this.disabled = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  TextEditingController _controller = new TextEditingController();

  static FormBuilderState of(BuildContext context) => context.findAncestorStateOfType<FormBuilderState>();

  @override
  void initState() {
    if (widget.defaultValue != null) {
      _controller.text = widget.defaultValue;
    } else {
      FormBuilderState formBuilderState = of(context);
      if (formBuilderState != null && formBuilderState.initialValue != null) {
        _controller.text = formBuilderState.initialValue[widget.name];
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        enabled: !widget.disabled,
        initialValue: widget.defaultValue,
        onReset: () => _controller.text = widget.defaultValue,
        onChanged: (val) {
          if (val.toString() == _controller.text) return;
          _controller.text = val.toString();
          _controller.selection = TextSelection.collapsed(offset: val?.length ?? -1);
        },
        builder: (FormFieldState field) {
          return Field(
              label: widget.label,
              labelWidth: widget.labelWidth ?? Style.fieldLabelWidth,
              placeholder: widget.placeholder ?? "请输入" + widget.label,
              errorMessage: field.errorText,
              require: widget.required,
              controller: _controller,
              type: widget.type ?? "text",
              rows: widget.rows,
              maxLength: widget.maxLength,
              showWordLimit: widget.showWordLimit,
              keyboardType: widget.keyboardType,
              disabled: widget.disabled,
              inputFormatters: widget.inputFormatters,
              onChange: (val) {
                field.didChange(val);
                if (widget.onChange != null) {
                  widget.onChange(val);
                }
              });
        });
  }
}
