import 'package:flutter/material.dart';
import 'package:flutter_vant_kit/theme/style.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  final List<MultiSelectDialogItem<V>> items;
  final List<V> initialSelectedValues;
  final Widget title;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final TextStyle labelStyle;
  final ShapeBorder dialogShapeBorder;
  final Color checkBoxCheckColor;
  final Color checkBoxActiveColor;

  MultiSelectDialog(
      {Key key,
      this.items,
      this.initialSelectedValues,
      this.title,
      this.okButtonLabel,
      this.cancelButtonLabel,
      this.labelStyle = const TextStyle(fontSize: Style.pickerOptionFontSize),
      this.dialogShapeBorder,
      this.checkBoxActiveColor,
      this.checkBoxCheckColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = List<V>();
  List<MultiSelectDialogItem<V>> _searchResults;

  void initState() {
    super.initState();
    _searchResults = widget.items;
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
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
    return AlertDialog(
      title: widget.title,
      shape: widget.dialogShapeBorder,
      contentPadding: EdgeInsets.only(top: 12.0),
      content: Column(children: [
        SearchBar<V>(widget.items, (results) {
          setState(() {
            _searchResults = results;
          });
        }),
        Expanded(
            child: SingleChildScrollView(
          child: ListTileTheme(
            contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
            child: ListBody(
              children: _searchResults.map(_buildItem).toList(),
            ),
          ),
        )),
      ]),
      actions: <Widget>[
        FlatButton(
          child: Text(widget.cancelButtonLabel),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text(widget.okButtonLabel),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return Container(
        height: 35,
        alignment: Alignment.centerLeft,
        child: CheckboxListTile(
          value: checked,
          checkColor: widget.checkBoxCheckColor,
          activeColor: widget.checkBoxActiveColor,
          title: Text(
            item.label,
            style: widget.labelStyle,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) => _onItemCheckedChange(item.value, checked),
        ));
  }
}

class SearchBar<V> extends StatefulWidget {
  final List<MultiSelectDialogItem<V>> list;
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
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.lightBlue,
            ),
            fillColor: Colors.white,
            filled: true,
            suffixIcon: GestureDetector(
              child: Offstage(
                offstage: _delOff,
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.grey,
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
                offset: _key == null ? 0 : _key.length, //保证光标在最后
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
    List<MultiSelectDialogItem> tmp = List();
    if (value.isEmpty) {
      //如果关键字为空，代表全匹配
      _delOff = true;
      widget.onResult(widget.list);
    } else {
      //如果有关键字，那么就去查找关键字
      _delOff = false;
      for (MultiSelectDialogItem n in widget.list) {
        if (n.label.toLowerCase().contains(value.toLowerCase())) {
          //匹配大小写
          tmp.add(n);
        }
      }
      widget.onResult(tmp);
    }
  }
}
