import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 详情行，child与text二选一
class DetailRow extends StatelessWidget {
  final String label;
  final Widget? child;
  final double? labelWidth;
  final String? text;
  final Color? textColor;
  final FontWeight? textFontWeight;
  final bool required;
  final EdgeInsets? padding;

  const DetailRow(this.label,
      {Key? key,
      this.labelWidth,
      this.child,
      this.text,
      this.textColor,
      this.textFontWeight,
      this.required = false,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding ?? EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Row(children: [
          Container(
              width: labelWidth ?? 80.0,
              height: 30.0,
              child: Row(children: [
                if (required) Text("*", style: Get.textTheme.bodyText2!.copyWith(color: Colors.red)),
                Flexible(
                    child: Text(label,
                        textAlign: TextAlign.start, overflow: TextOverflow.ellipsis)),
              ])),
          Expanded(
              child: child ??
                  Text(text ?? "",
                      style: Get.textTheme.bodyText2!.copyWith(color: this.textColor, fontWeight: textFontWeight)))
        ]));
  }
}
