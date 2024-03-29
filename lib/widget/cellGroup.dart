import 'package:flutter/material.dart';
import 'package:vant_form_builder/widget/divider.dart';

class CellGroup extends StatelessWidget {
  // 分组标题
  final String? title;

  // 是否显示外边框
  final bool border;

  // 自定义边框样式
  final BoxDecoration? decoration;

  final bool isDivider;

  final EdgeInsetsGeometry? childrenPadding;

  // 默认插槽
  final List<Widget>? children;

  CellGroup({Key? key, this.title, this.children, this.border: true, this.decoration, this.childrenPadding, this
      .isDivider = true})
      : super(key: key);

  buildItems(List list) {
    List<Widget> widgets = [];
    for (int i = 0; i < list.length; i++) {
      widgets.add(Padding(padding: childrenPadding ?? EdgeInsets.symmetric(horizontal: 5.0), child: list[i]));
      if (isDivider && i < list.length - 1)
        widgets.add(Container(
          margin: childrenPadding ?? EdgeInsets.symmetric(horizontal: 5.0),
          child: NDivider(),
        ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title != null
            ? Container(
                width: double.infinity,
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.only(left: 10.0, top: 5.0, right: 10.0, bottom: 5.0),
                child: Text(title!,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            : Container(),
        ...buildItems(children!),
        SizedBox(height: 10)
      ],
    );
  }
}
