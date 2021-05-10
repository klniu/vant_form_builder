import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class RadioGroupField extends StatelessWidget {
  final String name;
  final List<FormBuilderFieldOption> items;
  final String label;
  final bool required;
  final FormFieldValidator? validator;
  final dynamic defaultValue;
  final Axis direction;
  final String? placeholder;
  final bool enabled;
  final void Function(dynamic)? onChanged;

  const RadioGroupField(this.name, this.items,
      {Key? key,
      this.label = "",
      this.required = false,
      this.validator,
      this.defaultValue,
      this.placeholder,
      this.onChanged,
      this.enabled = true,
      this.direction = Axis.vertical})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderRadioGroup(
      name: this.name,
      initialValue: this.defaultValue,
      validator: this.validator,
      enabled: this.enabled,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: this.label + (this.required ? " *" : ''),
        labelStyle: this.required
            ? Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(color: Colors.red)
            : Theme.of(context).inputDecorationTheme.labelStyle,
        hintText: this.placeholder ?? "请输入" + this.label,
      ),
      options: items,
      onChanged: onChanged,
    );
  }
}
