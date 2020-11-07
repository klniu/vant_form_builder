import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_vant_kit/theme/style.dart';
import 'package:intl/intl.dart';

import 'custom_form_field.dart';

class DateTimeField extends StatefulWidget {
  final String name;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final DateTime minTime;
  final DateTime maxTime;
  final DateTime defaultTime;
  final bool isTime;
  final String popupConfirmText;
  final String popupCancelText;

  const DateTimeField(this.name,
      {Key key,
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.isTime: false,
      this.minTime,
      this.maxTime,
      this.defaultTime,
      this.popupConfirmText,
      this.popupCancelText})
      : super(key: key);

  @override
  _DateTimeFieldState createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  DateTime _value;

  String get selectedText => _formatDate(_value);

  static FormBuilderState of(BuildContext context) =>
      context.findAncestorStateOfType<FormBuilderState>();

  @override
  void initState() {
    if (widget.defaultTime != null) {
      _value = widget.defaultTime;
    } else {
      FormBuilderState formBuilderState = of(context);
      if (formBuilderState != null && formBuilderState.initialValue != null) {
        _value = formBuilderState.initialValue[widget.name];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        initialValue: widget.defaultTime,
        onReset: () {
          setState(() {
            _value = widget.defaultTime;
          });
        },
        builder: (FormFieldState<dynamic> field) {
          return CustomFormField(
              label: widget.label,
              labelWidth: widget.labelWidth ?? Style.fieldLabelWidth,
              required: widget.required,
              errorText: field.errorText,
              child: GestureDetector(
                  child: Row(children: [
                    Expanded(
                        child: Text(selectedText,
                            style: TextStyle(fontSize: Style.fieldFontSize))),
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                      size: 18,
                    )
                  ]),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    new Picker(
                        confirmText: widget.popupConfirmText ?? "确定",
                        cancelText: widget.popupCancelText ?? "取消",
                        adapter: new DateTimePickerAdapter(
                          type: widget.isTime
                              ? PickerDateTimeType.kYMDHMS
                              : PickerDateTimeType.kYMD,
                          isNumberMonth: true,
                          minValue: widget.minTime,
                          maxValue: widget.maxTime,
                          minHour: 0,
                          maxHour: 23,
                          value: _value,
                        ),
                        backgroundColor: Style.pickerBackgroundColor,
                        textStyle: const TextStyle(
                            fontSize: Style.pickerOptionFontSize,
                            color: Style.pickerOptionTextColor),
                        confirmTextStyle: const TextStyle(
                            fontSize: Style.pickerActionFontSize,
                            color: Style.pickerActionTextColor),
                        cancelTextStyle: const TextStyle(
                            fontSize: Style.pickerActionFontSize,
                            color: Style.pickerActionTextColor),
                        title: new Text("选择" + widget.label,
                            style: const TextStyle(
                                fontSize: Style.pickerTitleFontSize)),
                        textAlign: TextAlign.right,
                        selectedTextStyle: TextStyle(color: Colors.blue),
                        delimiter: [
                          PickerDelimiter(
                              column: 5,
                              child: Container(
                                width: 16.0,
                                alignment: Alignment.center,
                                child: Text(':',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                color: Colors.white,
                              ))
                        ],
                        onConfirm: (Picker picker, List value) {
                          setState(() {
                            _value =
                                (picker.adapter as DateTimePickerAdapter).value;
                          });
                          field.didChange(_value);
                        }).showModal(context);
                  }));
        });
  }

  String _formatDate(DateTime value) {
    if (value == null) {
      return "";
    }
    return widget.isTime
        ? new DateFormat.yMd().add_Hms().format(value).replaceAll("/", "-")
        : new DateFormat.yMd().format(value).replaceAll("/", "-");
  }
}
