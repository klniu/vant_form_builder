import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtil {
  static success(String text) {
    // EasyLoading.instance.backgroundColor = Colors.green;
    // EasyLoading.showSuccess(text);
    Get.snackbar("", "",
        titleText: SizedBox(),
        messageText: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          SizedBox(width: 5),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white)))
        ]),
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

  static info(String text) {
    // EasyLoading.instance.backgroundColor = Colors.grey;
    // EasyLoading.showInfo(text);
    Get.snackbar("", "",
        titleText: Container(),
        messageText: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(
            Icons.info,
            color: Colors.white,
          ),
          SizedBox(width: 5),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white)))
        ]),
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        duration: Duration(seconds: 3));
  }

  static error(String text) {
    // EasyLoading.instance.backgroundColor = Colors.red;
    // EasyLoading.showError(text);
    Get.snackbar("", "",
        titleText: SizedBox(),
        messageText: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(
            Icons.warning,
            color: Colors.white,
          ),
          SizedBox(width: 5),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white)))
        ]),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3));
  }
}
