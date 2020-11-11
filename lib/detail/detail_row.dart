import 'package:flutter/material.dart';
import 'package:flutter_vant_kit/theme/style.dart';

/// 详情行，child与text二选一
class DetailRow extends StatelessWidget {
  final String label;
  final Widget child;
  final double labelWidth;
  final String text;
  final Color textColor;
  final FontWeight textFontWeight;
  final bool required;
  final EdgeInsets padding;

  const DetailRow(this.label,
      {Key key,
      this.labelWidth,
      this.child,
      this.text = "",
      this.textColor,
      this.textFontWeight,
      this.required = false,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding ?? EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(children: [
          Container(
              width: labelWidth ?? Style.fieldLabelWidth,
              height: Style.fieldMinHeight,
              child: Row(children: [
                if (required)
                  Text("*",
                      style: TextStyle(
                        fontSize: Style.fieldFontSize,
                        color: Style.fieldRequiredColor,
                      )),
                Flexible(
                    child: Text(label,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: Style.fieldFontSize))),
              ])),
          Expanded(
              child: child ??
                  Text(text ?? "",
                      style: TextStyle(
                          fontSize: Style.fieldFontSize,
                          color: this.textColor ?? Colors.black,
                          fontWeight: textFontWeight ?? FontWeight.normal)))
        ]));
  }
}
