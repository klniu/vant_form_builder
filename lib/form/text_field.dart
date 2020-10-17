import 'package:flutter/material.dart';
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
  final String defaultText;
  final String placeholder;
  final TextInputType keyboardType;
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
      this.defaultText,
      this.onChange,
      this.disabled = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    _controller.text = widget.defaultText;
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
        initialValue: widget.defaultText,
        onReset: () => _controller.text = widget.defaultText,
        builder: (FormFieldState<dynamic> field) {
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
                field.didChange(val);
                if (widget.onChange != null) {
                  widget.onChange(val);
                }
              });
        });
  }
}
