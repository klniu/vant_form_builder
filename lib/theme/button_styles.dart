import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonStyles {
  static ButtonStyle primary({double fontSize = 14}) {
    return ButtonStyle(
        textStyle:
            MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize)),
        backgroundColor: MaterialStateProperty.all(Get.theme.accentColor),
        foregroundColor: MaterialStateProperty.all(Colors.white));
  }

  static ButtonStyle success({double fontSize = 14}) {
    return ButtonStyle(
        textStyle:
            MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize)),
        backgroundColor: MaterialStateProperty.all(Colors.lightGreen),
        foregroundColor: MaterialStateProperty.all(Colors.white));
  }

  static ButtonStyle info({double fontSize = 14}) {
    return ButtonStyle(
        textStyle:
            MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize)),
        backgroundColor: MaterialStateProperty.all(Colors.white),
        foregroundColor: MaterialStateProperty.all(Colors.black));
  }

  static ButtonStyle danger({double fontSize = 14}) {
    return ButtonStyle(
        textStyle:
            MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize)),
        backgroundColor: MaterialStateProperty.all(Colors.red),
        foregroundColor: MaterialStateProperty.all(Colors.white));
  }

  static ButtonStyle warning({double fontSize = 14}) {
    return ButtonStyle(
        textStyle:
            MaterialStateProperty.all(TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize)),
        backgroundColor: MaterialStateProperty.all(Colors.orange),
        foregroundColor: MaterialStateProperty.all(Colors.white));
  }
}
