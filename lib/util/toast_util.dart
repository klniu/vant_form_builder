import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtil {
  static _toast(String text, IconData iconData, Color backgroundColor) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
      content: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Icon(
          iconData,
          color: Colors.white,
        ),
        SizedBox(width: 5),
        Expanded(child: Text(text, style: TextStyle(color: Colors.white)))
      ]),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    ));
  }

  static success(String text) {
    _toast(text, Icons.check_circle, Colors.green);
  }

  static info(String text) {
    _toast(text, Icons.info, Colors.grey);
  }

  static error(String text) {
    _toast(text, Icons.warning, Colors.red);
  }
}
