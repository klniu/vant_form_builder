import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vant_kit/theme/style.dart';
import 'package:flutter_vant_kit/widgets/picker.dart';
import 'package:quiver/strings.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/util/data_converter.dart';
import 'package:vant_form_builder/util/toast_util.dart';

import 'custom_form_field.dart';

class TreeNodePickerField extends StatefulWidget {
  final String name;
  final List<TreeNode> nodes;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final String defaultValue;
  final String placeholder;
  final bool loading;
  final bool disabled;
  final dynamic Function(String title, String value) onConfirm;

  TreeNodePickerField(this.name,
      {Key key,
      this.nodes = const [],
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.defaultValue,
      this.placeholder,
      this.loading = false,
      this.disabled = false,
      this.onConfirm})
      : super(key: key);

  @override
  _TreeNodePickerFieldState createState() => _TreeNodePickerFieldState();
}

class _TreeNodePickerFieldState extends State<TreeNodePickerField> {
  String selectedText = "";
  List<int> index;
  String value;

  _TreeNodePickerFieldState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (index == null) {
      _onChangeValueOutside(widget.defaultValue);
    }
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        enabled: !widget.disabled,
        initialValue: widget.defaultValue,
        onReset: () => _onChangeValueOutside(widget.defaultValue),
        builder: (FormFieldState<dynamic> field) {
          return CustomFormField(
              label: widget.label,
              labelWidth: widget.labelWidth,
              required: widget.required,
              errorText: field.errorText,
              child: GestureDetector(
                  child: Row(children: [
                    Expanded(
                        child: widget.loading
                            ? Text("数据加载中...",
                                style: TextStyle(color: Style.fieldInputTextColor, fontSize: Style.fieldFontSize))
                            : isNotEmpty(selectedText)
                                ? Text(selectedText,
                                    style: TextStyle(
                                        color: widget.disabled
                                            ? Style.fieldInputDisabledTextColor
                                            : Style.fieldInputTextColor,
                                        fontSize: Style.fieldFontSize))
                                : Text(widget.placeholder ?? "请选择" + widget.label,
                                    style: TextStyle(
                                        color: widget.disabled
                                            ? Style.fieldInputDisabledTextColor
                                            : Style.fieldPlaceholderTextColor,
                                        fontSize: Style.fieldFontSize))),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.grey,
                      size: 18,
                    )
                  ]),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    if (widget.disabled) {
                      return;
                    }
                    if (widget.nodes == null || widget.nodes.length == 0) {
                      ToastUtil.info("无数据");
                      return;
                    }
                    List<PickerItem> items = DataConverter.treeNode2PickerItem(widget.nodes);
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          // 对于1级的，defaultIndex不能是数组
                          int level = DataConverter.getPickerItemDeep(items);
                          return Picker(
                              colums: items,
                              level: level,
                              defaultIndex: level == 1 && index != null && index.length > 0 ? index[0] : index,
                              showToolbar: true,
                              title: "请选择" + widget.label,
                              onCancel: (values, index) {
                                Navigator.pop(context);
                              },
                              onConfirm: (List<String> values, indies) {
                                setState(() {
                                  if (indies is int) {
                                    index = [indies];
                                  } else {
                                    index = indies;
                                  }
                                  selectedText = values.join("/");
                                  value = getTreeNode(index).value;
                                });
                                field.didChange(value);
                                if (widget.onConfirm != null) {
                                  widget.onConfirm(selectedText, value);
                                }
                                Navigator.pop(context);
                              });
                        });
                  }));
        });
  }

  TreeNode getTreeNode(List<int> indices) {
    TreeNode node = widget.nodes[indices[0]];
    for (var index in indices.sublist(1)) {
      node = node.children[index];
    }
    return node;
  }

  /// 在外部通过form_builder更改时调用
  _onChangeValueOutside(String val) {
    if (isNotBlank(val)) {
      var node = DataConverter.getIndexInTreeNodesByValue(widget.defaultValue, widget.nodes);
      if (node != null) {
        setState(() {
          value = node.value;
          index = node.index;
          selectedText = node.text;
        });
      }
    } else {
      setState(() {
        value = null;
        index = null;
        selectedText = "";
      });
    }
  }
}
