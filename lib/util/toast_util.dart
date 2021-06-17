import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ToastUtil {
  static _toast(String text, IconData iconData, Color backgroundColor) {
    showTopSnackBar(
        Get.context!,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
              iconData,
              color: Colors.white,
            ),
            SizedBox(width: 5),
            Expanded(child: Text(text, style: TextStyle(color: Colors.white)))
          ]),
        ),
      displayDuration: Duration(seconds: 1),
    );
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
