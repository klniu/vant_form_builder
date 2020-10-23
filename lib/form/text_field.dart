import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vant_kit/theme/style.dart';
import 'package:flutter_vant_kit/widgets/field.dart';

class CustomTextField<T> extends StatefulWidget {
  final String name;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final String type;
  final int rows;
  final int maxLength;
  final bool showWordLimit;
  final T defaultValue;
  final String placeholder;
  final TextInputType keyboardType;
  final Function(T) onChange;
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
      this.onChange,
      this.disabled = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState<T>();
}

class _CustomTextFieldState<T> extends State<CustomTextField<T>> {
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    _controller.text = widget.defaultValue?.toString();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<T>(
        name: widget.name,
        validator: widget.validator,
        enabled: !widget.disabled,
        initialValue: widget.defaultValue,
        onReset: () => _controller.text = widget.defaultValue?.toString(),
        onChanged: (val) {
          if (val.toString() == _controller.text) return;
          _controller.text = val.toString();
          _controller.selection = TextSelection.collapsed(offset: val?.toString().length ?? -1);
        },
        builder: (FormFieldState<T> field) {
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
              onChange: (val) {
                var value;
                if (T == int) {
                  value = int.parse(val);
                } else if (T == double) {
                  value = double.parse(val);
                } else {
                  value = val?.toString();
                }
                field.didChange(value);
                if (widget.onChange != null) {
                  widget.onChange(value);
                }
              });
        });
  }

  void patchValue(T value) {
  }
}
