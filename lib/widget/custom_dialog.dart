import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vant_form_builder/theme/button_styles.dart';

customDialog(Widget content,
    {String title = "",
    Widget titleWidget,
    VoidCallback onConfirmed,
    VoidCallback onCanceled,
    barrierDismissible: false}) {
  Get.dialog(
      Center(
          child: Container(
              padding: EdgeInsets.all(15.0),
              decoration: new BoxDecoration(
                  color: Get.theme.scaffoldBackgroundColor,
                  borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
              constraints: BoxConstraints(maxWidth: Get.size.width * 0.8, maxHeight: Get.size.height * 0.8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                titleWidget == null
                    ? Text(title, style: Get.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold))
                    : titleWidget,
                SizedBox(height: 10),
                Flexible(child: SingleChildScrollView(child: content)),
                SizedBox(height: 10),
                if (onConfirmed != null || onCanceled != null)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (onConfirmed != null)
                      ElevatedButton(onPressed: onConfirmed, style: ButtonStyles.primary(), child: Text("确定")),
                    if (onConfirmed != null && onCanceled != null) SizedBox(width: 40),
                    if (onCanceled != null)
                      ElevatedButton(onPressed: onCanceled, style: ButtonStyles.info(), child: Text("取消"))
                  ])
              ]))),
      barrierDismissible: barrierDismissible);
}
