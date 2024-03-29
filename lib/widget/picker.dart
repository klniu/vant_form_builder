import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Picker extends StatefulWidget {
  // 对象数组，配置每一列显示的数据
  final List<PickerItem>? colums;

  // 是否显示顶部栏
  final bool showToolbar;

  // 顶部栏位置，可选值为bottom
  final String toolbarPosition;

  // 顶部栏标题
  final String? title;

  // 是否显示加载状态
  final bool loading;

  // 选项高度
  final double itemHeight;

  // 确认按钮文字
  final String confirmButtonText;

  // 取消按钮文字
  final String cancelButtonText;

  // 默认选中项索引
  final dynamic defaultIndex;

  // 多列选择的列数
  final int level;

  // 点击取消按钮时触发
  final Function(List<String?> selectedValues, dynamic selectedIndex)? onCancel;

  // 点击完成按钮时触发
  final Function(List<String?> selectedValues, dynamic selectedIndex)? onConfirm;

  // 选项改变时触发
  final Function(List<String?> selectedValues, dynamic selectedIndex)? onChange;

  const Picker(
      {Key? key,
      this.colums,
      this.showToolbar: false,
      this.toolbarPosition: "top",
      this.title,
      this.loading: false,
      this.itemHeight: 44.0,
      this.confirmButtonText: "确认",
      this.cancelButtonText: "取消",
      this.defaultIndex,
      this.level: 1,
      this.onConfirm,
      this.onCancel,
      this.onChange})
      : super(key: key);

  @override
  _Picker createState() => _Picker();
}

class _Picker extends State<Picker> {
  late List<FixedExtentScrollController> scrollControllers;

  List _columns = [];
  List<String?> _selectValues = [];
  dynamic _selectIndex = [];
  bool isMultiple = false;

  @override
  void initState() {
    scrollControllers = List.generate(widget.level, (i) => FixedExtentScrollController());

    isMultiple = widget.level > 1;
    if (isMultiple) {
      _selectIndex = widget.defaultIndex ?? List.generate(widget.level, (i) => 0);
      List.generate(widget.level, (i) {
        int? index = _selectIndex[i];
        if (i == 0) {
          _selectValues.add(widget.colums![index!].text);
          _columns.add(widget.colums);
        } else {
          List<PickerItem> items = getFloatArr(widget.colums, i);
          _selectValues.add(items[index!].text);
          _columns.add(items);
        }
      });
    } else {
      _selectIndex = widget.defaultIndex ?? 0;
      _selectValues = [widget.colums![_selectIndex].text];
      _columns.add(widget.colums);
    }
    super.initState();
  }

  List<PickerItem> getFloatArr(List<PickerItem>? list, int level, {int? baseLevel}) {
    baseLevel = baseLevel ?? 0;
    int? index = _selectIndex[baseLevel];
    if (baseLevel < level && list != null) {
      return getFloatArr(list[index!].child, level, baseLevel: baseLevel + 1);
    } else {
      return list != null ? list : [PickerItem("-")];
    }
  }

  Widget buildToolbar(BuildContext context) {
    return Container(
      height: 44.0,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Theme.of(context).dividerColor, width: widget.toolbarPosition == "bottom" ? 1.0 : 0.0),
            bottom:
                BorderSide(color: Theme.of(context).dividerColor, width: widget.toolbarPosition == "top" ? 1.0 : 0.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildCancelButton(context),
          Text("${widget.title ?? ''}", style: Theme.of(context).textTheme.subtitle2),
          buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget buildConfirmButton(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          if (widget.onConfirm != null) widget.onConfirm!(_selectValues, _selectIndex);
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: AlignmentDirectional.center,
            child: Text("${widget.confirmButtonText}", style: Theme.of(context).textTheme.subtitle2)),
      ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          if (widget.onCancel != null) widget.onCancel!(_selectValues, _selectIndex);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: AlignmentDirectional.center,
          child: Text("${widget.cancelButtonText}", style: Theme.of(context).textTheme.subtitle2),
        ),
      ),
    );
  }

  List<Widget> buildPickerItem(List<PickerItem> items) {
    List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      PickerItem item = items[i];
      widgets.add(Container(
        height: widget.itemHeight,
        alignment: AlignmentDirectional.center,
        child: Text('${item.text}', style: Theme.of(context).textTheme.bodyText2),
      ));
    }
    return widgets;
  }

  Widget buildPicker(List<PickerItem> column, int i) {
    scrollControllers[i] = FixedExtentScrollController(initialItem: isMultiple ? _selectIndex[i] : _selectIndex);
    return Expanded(
      child: CupertinoPicker(
        scrollController: scrollControllers[i],
        itemExtent: widget.itemHeight,
        diameterRatio: 1.8,
        onSelectedItemChanged: (index) {
          setState(() {
            if (isMultiple) {
              _selectIndex[i] = index;
              _selectValues[i] = column[index].text;
              for (int x = i; x < widget.level - 1; x++) {
                int nextIndex = x + 1;
                _selectIndex[nextIndex] = 0;
                scrollControllers[nextIndex].jumpToItem(0);
                _columns[nextIndex] = getFloatArr(widget.colums, nextIndex);
                _selectValues[nextIndex] = _columns[nextIndex][_selectIndex[nextIndex]].text;
              }
            } else {
              _selectIndex = index;
              _selectValues[i] = column[index].text;
            }
          });
          if (widget.onChange != null) widget.onChange!(_selectValues, _selectIndex);
        },
        // 滚筒的曲率,就是弯曲的程度
        useMagnifier: false,
        magnification: 1.0,
        children: buildPickerItem(column),
      ),
    );
  }

  Widget buildLoadingMask() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.white70,
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 260.0,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                widget.showToolbar && widget.toolbarPosition == 'top' ? buildToolbar(context) : Container(),
                Expanded(
                  child: Row(
                    children: List.generate(_columns.length, (i) => buildPicker(_columns[i], i)),
                  ),
                ),
                widget.showToolbar && widget.toolbarPosition == 'bottom' ? buildToolbar(context) : Container(),
              ],
            ),
            widget.loading ? buildLoadingMask() : Container(),
          ],
        ));
  }
}

class PickerItem {
  final String text;
  final List<PickerItem>? child;

  PickerItem(this.text, {this.child});
}
