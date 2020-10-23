import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vant_kit/widgets/radioGroup.dart';

import 'custom_form_field.dart';

class RadioField extends StatefulWidget {
  final String name;
  final List<RadioItem> items;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final String defaultValue;
  final Axis direction;
  final void Function(String) onChanged;

  const RadioField(this.name, this.items,
      {Key key,
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.defaultValue,
      this.onChanged,
      this.direction = Axis.vertical})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RadioFieldState();
}

class _RadioFieldState extends State<RadioField> {
  String _value;

  static FormBuilderState of(BuildContext context) => context.findAncestorStateOfType<FormBuilderState>();

  @override
  void initState() {
    if (widget.defaultValue != null) {
      _value = widget.defaultValue;
    } else {
      FormBuilderState formBuilderState = of(context);
      if (formBuilderState != null && formBuilderState.initialValue != null) {
        _value = formBuilderState.initialValue[widget.name] ?? [];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        initialValue: widget.defaultValue,
        onReset: () {
          setState(() {
            _value = widget.defaultValue;
          });
        },
        builder: (FormFieldState<dynamic> field) {
          return CustomFormField(
              label: widget.label,
              labelWidth: widget.labelWidth,
              required: widget.required,
              errorText: field.errorText,
              child: RadioGroup(
                  value: _value,
                  list: widget.items,
                  direction: widget.direction,
                  onChange: (val) {
                    field.didChange(val);
                    if (widget.onChanged != null) {
                      widget.onChanged(val);
                    }
                  }));
        });
  }
}
