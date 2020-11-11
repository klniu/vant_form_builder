import 'package:flutter/material.dart';
import 'package:flutter_vant_kit/theme/style.dart';
import 'package:quiver/strings.dart';

class CustomFormField extends StatefulWidget {
  final bool required;
  final String label;
  final Widget child;
  final double labelWidth;
  final String errorText;

  const CustomFormField({Key key, this.label = "", this.required = false, this.child, this.labelWidth, this.errorText})
      : super(key: key);

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        Column(children: [
          Container(
              width: widget.labelWidth ?? Style.fieldLabelWidth,
              height: Style.fieldMinHeight,
              child: Row(children: [
                if (widget.required)
                  Text("*",
                      style: TextStyle(
                        fontSize: Style.fieldFontSize,
                        color: Style.fieldRequiredColor,
                      )),
                Flexible(child: Text(widget.label,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: Style.fieldFontSize),
                    overflow: TextOverflow.ellipsis)),
              ])),
          if (isNotBlank(widget.errorText)) SizedBox(height: 5),
          if (isNotBlank(widget.errorText))
            Text("", style: TextStyle(color: Style.fieldErrorMessageColor, fontSize: Style.fieldErrorMessageTextSize)),
        ]),
        SizedBox(width: widget.label != null ? Style.intervalLg : 0),
        Expanded(
          child:
              Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
            widget.child,
            if (isNotBlank(widget.errorText)) SizedBox(height: 5),
            if (isNotBlank(widget.errorText))
              Text(widget.errorText,
                  style: TextStyle(color: Style.fieldErrorMessageColor, fontSize: Style.fieldErrorMessageTextSize)),
          ]),
        ),
      ]),
    );
  }
}
