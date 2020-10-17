import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vant_kit/main.dart';
import 'package:flutter_vant_kit/theme/style.dart';
import 'package:quiver/strings.dart';

import 'custom_form_field.dart';

class TextArrayField extends StatefulWidget {
  final String name;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final String defaultText;
  final String placeholder;
  final TextInputType keyboardType;
  final Function(String) onChange;
  final bool disabled;
  final String splitString;

  const TextArrayField(this.name,
      {Key key,
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.placeholder,
      this.keyboardType,
      this.defaultText,
      this.onChange,
      this.disabled = false,
      this.splitString = ","})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextArrayFieldState();
}

class _TextArrayFieldState extends State<TextArrayField> {
  List<TextEditingController> _controllers = [new TextEditingController()];
  List<TextEditingController> _toBeDisposed = [];

  @override
  void initState() {
    _splitText(widget.defaultText);
    super.initState();
  }

  @override
  void dispose() {
    _controllers.forEach((element) {
      element.dispose();
    });
    _toBeDisposed.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  _splitText(String text) {
    if (isBlank(text)) return;
    var texts = widget.defaultText.split(widget.splitString);
    if (texts.length < _controllers.length) {
      Iterable<int>.generate(_controllers.length - texts.length).forEach((_) {
        _controllers.removeLast().dispose();
      });
    }
    texts.asMap().forEach((index, text) {
      if (_controllers.length - 1 < index) {
        _controllers.add(new TextEditingController());
      }
      _controllers[index].text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        enabled: !widget.disabled,
        initialValue: widget.defaultText,
        onReset: () => _splitText(widget.defaultText),
        builder: (FormFieldState<dynamic> field) {
          return CustomFormField(
              label: widget.label,
              labelWidth: widget.labelWidth ?? Style.fieldLabelWidth,
              required: widget.required,
              errorText: field.errorText,
              child: Column(
                  children: _controllers.asMap().entries.map((entry) {
                return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                      child: TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: Style.fieldInputPadding,
                            hintText: widget.placeholder ?? "请输入" + widget.label,
                            hintStyle: TextStyle(
                              color: Style.fieldPlaceholderTextColor,
                              fontSize: Style.fieldFontSize,
                            ),
                          ),
                          keyboardType: widget.keyboardType,
                          enabled: !widget.disabled,
                          onChanged: (val) {
                            var val = _controllers.map((e) => e.text).join(widget.splitString);
                            field.didChange(val);
                            if (widget.onChange != null) {
                              widget.onChange(val);
                            }
                          })),
                  NButton(
                    size: "small",
                    height: 24,
                    color: Colors.blue,
                    icon: Icon(entry.key == 0 ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        color: Colors.white, size: 18),
                    onClick: () {
                      if (entry.key == 0) {
                        setState(() {
                          _controllers.add(TextEditingController());
                        });
                      } else {
                        setState(() {
                          _toBeDisposed.add(_controllers.removeAt(entry.key));
                        });
                        var val = _controllers.map((e) => e.text).join(widget.splitString);
                        field.didChange(val);
                        if (widget.onChange != null) {
                          widget.onChange(val);
                        }
                      }
                    },
                  )
                ]);
              }).toList()));
        });
  }
}
