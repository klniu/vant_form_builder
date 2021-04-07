import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Tag extends StatefulWidget {
  // 大小
  final String type;

  // 大小
  final String size;

  // 标签内文字
  final String text;

  // 是否为空心样式
  final bool plain;

  // 是否为圆角样式
  final bool round;

  // 是否为标记样式
  final bool mark;

  // 标签颜色
  final Color color;

  // 文字颜色，优先于color属性
  final Color textColor;

  // 是否为可关闭标签
  final Function() onClose;

  Tag({
    Key key,
    this.type: "default",
    this.size: "default",
    this.text: "",
    this.plain: false,
    this.round: false,
    this.mark: false,
    this.color,
    this.textColor,
    this.onClose,
  })  : assert(["default", "medium", "large"].indexOf(size) > -1, "size must be default, medium, or large"),
        assert(["default", "primary", "success", "danger", "warning"].indexOf(type) > -1,
            "type must be default, primary, success, danger or warning"),
        super(key: key);

  @override
  _Tag createState() => _Tag();
}

class _Tag extends State<Tag> {
  bool isShow = true;

  Map<String, dynamic> sizes = {
    "default": <String, double>{"fontSize": 10.0},
    "medium": <String, double>{"fontSize": 12.0},
    "large": <String, double>{"fontSize": 14.0}
  };

  Map<String, dynamic> colors = {
    "default": <String, Color>{"color": Colors.grey},
    "danger": <String, Color>{"color": Colors.red},
    "primary": <String, Color>{"color": Get.theme.primaryColor},
    "success": <String, Color>{"color": Colors.green},
    "warning": <String, Color>{"color": Colors.orange},
  };

  void close() {
    widget.onClose();
    setState(() {
      isShow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.color ?? colors[widget.type]['color'];
    Color bageColor = widget.plain ? Colors.white : widget.color ?? colors[widget.type]['color'];
    Color textColor = widget.textColor ?? (widget.plain ? widget.color ?? colors[widget.type]['color'] : Colors.white);
    return Visibility(
      visible: isShow,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: bageColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: widget.mark
              ? BorderRadius.horizontal(left: Radius.circular(2), right: Radius.circular(999))
              : BorderRadius.circular(widget.round ? 999 : 2),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: sizes[widget.size]['fontSize'],
                )),
            widget.onClose != null
                ? GestureDetector(
                    child: Icon(
                      Icons.close,
                      color: textColor,
                      size: sizes[widget.size]['fontSize'],
                    ),
                    onTap: () => close(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
