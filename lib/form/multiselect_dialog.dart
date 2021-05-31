import 'package:flutter/material.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/theme/button_styles.dart';
import 'package:vant_form_builder/util/toast_util.dart';
import 'package:vant_form_builder/vant_form_builder.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<TreeNode> items;
  final List? initialSelectedValues;
  final Widget? title;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final TextStyle? labelStyle;
  final ShapeBorder? dialogShapeBorder;
  final Color? checkBoxCheckColor;
  final Color? checkBoxActiveColor;
  final int limit;

  MultiSelectDialog({
    Key? key,
    required this.items,
    this.initialSelectedValues,
    this.title,
    this.okButtonLabel = "确定",
    this.cancelButtonLabel = "取消",
    this.labelStyle,
    this.dialogShapeBorder,
    this.checkBoxActiveColor,
    this.checkBoxCheckColor,
    this.limit = 1000,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  final _selectedValues = [];
  late List<TreeNode> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = widget.items;
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues!);
    }
  }

  void _onItemCheckedChange(dynamic itemValue, bool? checked) {
    setState(() {
      if (checked == true) {
        if (_selectedValues.length > widget.limit) {
          ToastUtil.error("最多只能选择${widget.limit}项");
        } else {
          _selectedValues.add(itemValue);
        }
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBarTheme(
        data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
        child: AlertDialog(
          title: widget.title,
          shape: widget.dialogShapeBorder,
          contentPadding: EdgeInsets.only(top: 2.0),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SearchBar(widget.items, (results) {
              setState(() {
                _searchResults = results;
              });
            }),
            Flexible(
                child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: ListTileTheme(
                    contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
                    child: ListBody(
                      children: _searchResults.map(_buildItem).toList(),
                    ),
                  )),
            )),
          ]),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyles.primary(),
              child: Text(widget.okButtonLabel),
              onPressed: _onSubmitTap,
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ButtonStyles.info(),
              child: Text(widget.cancelButtonLabel),
              onPressed: _onCancelTap,
            ),
          ],
        ));
  }

  Widget _buildItem(TreeNode item) {
    final checked = _selectedValues.contains(item.value);
    return SizedBox(
        height: 36,
        child: ListTile(
            title: Row(
          children: <Widget>[
            Expanded(child: Text(item.title)),
            SizedBox(
                width: 36,
                height: 36,
                child: Checkbox(
                  value: checked,
                  onChanged: (checked) => _onItemCheckedChange(item.value, checked),
                ))
          ],
        )));
  }
}

class SearchBar extends StatefulWidget {
  final List<TreeNode> list;
  final Function onResult;

  SearchBar(this.list, this.onResult);

  @override
  State<StatefulWidget> createState() {
    return SearchBarState();
  }
}

class SearchBarState extends State<SearchBar> {
  bool _delOff = true; //是否展示删除按钮
  String _key = ""; //搜索的关键字

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).accentColor,
            ),
            fillColor: Colors.white,
            filled: true,
            suffixIcon: GestureDetector(
              child: Offstage(
                offstage: _delOff,
                child: Icon(
                  Icons.highlight_off,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onTap: () {
                setState(() {
                  _key = "";
                  search(_key);
                });
              },
            )),
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: _key,
            selection: TextSelection.fromPosition(
              TextPosition(
                offset: _key.length, //保证光标在最后
              ),
            ),
          ),
        ),
        onChanged: search,
      ),
    );
  }

  ///关键字查找
  void search(String value) {
    _key = value;
    List<TreeNode> tmp = [];
    if (value.isEmpty) {
      //如果关键字为空，代表全匹配
      _delOff = true;
      widget.onResult(widget.list);
    } else {
      //如果有关键字，那么就去查找关键字
      _delOff = false;
      for (TreeNode n in widget.list) {
        if (n.title.toLowerCase().contains(value.toLowerCase())) {
          //匹配大小写
          tmp.add(n);
        }
      }
      widget.onResult(tmp);
    }
  }
}
