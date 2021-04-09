import 'package:flutter/material.dart';
import 'package:vant_form_builder/widget/divider.dart';

class CellGroup extends StatelessWidget {
  // 分组标题
  final String title;

  // 是否显示外边框
  final bool border;

  // 自定义边框样式
  final BoxDecoration decoration;

  // 默认插槽
  final List<Widget> children;

  CellGroup({Key key, this.title, this.children, this.border: true, this.decoration}) : super(key: key);

  buildItems(List list) {
    List<Widget> widgets = [];
    for (int i = 0; i < list.length; i++) {
      widgets.add(Padding(padding: EdgeInsets.symmetric(horizontal: 10.0), child: list[i]));
      if (i < list.length - 1)
        widgets.add(Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
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
                padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 8.0),
                child: Text(title, style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.white)),
              )
            : Container(),
        Container(
          decoration: decoration ??
              BoxDecoration(
                border: border
                    ? Border(
                        top: BorderSide(width: 1.0, color: Theme.of(context).dividerColor),
                        bottom: BorderSide(width: 1.0, color: Theme.of(context).dividerColor),
                      )
                    : null,
              ),
          child: Column(
            children: buildItems(children),
          ),
        )
      ],
    );
  }
}