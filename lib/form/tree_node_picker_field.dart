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

  static FormBuilderState of(BuildContext context) =>
      context.findAncestorStateOfType<FormBuilderState>();

  @override
  void initState() {
    if (widget.defaultValue != null) {
      _onChangeValueOutside(widget.defaultValue);
    } else {
      FormBuilderState formBuilderState = of(context);
      if (formBuilderState != null && formBuilderState.initialValue != null) {
        _onChangeValueOutside(formBuilderState.initialValue[widget.name]);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        enabled: !widget.disabled,
        initialValue: widget.defaultValue,
        onReset: () => _onChangeValueOutside(widget.defaultValue),
        onChanged: (val) {
          if (val == value) return;
          _onChangeValueOutside(val);
        },
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
                            style: TextStyle(color: Style.fieldInputTextColor,
                                fontSize: Style.fieldFontSize))
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
                    List<PickerItem> items = DataConverter.treeNode2PickerItem(
                        widget.nodes);
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          // 对于1级的，defaultIndex不能是数组
                          int level = DataConverter.getPickerItemDeep(items);
                          var defaultIndex;
                          if (index != null) {
                            if (level == 1 && index.length > 0) {
                              defaultIndex = index[0];
                            } else {
                              defaultIndex = List.generate(level, (i) {
                                if (index.length > i) {
                                  return index[i];
                                } else {
                                  return 0;
                                }
                              });
                            }
                          }
                          return Picker(
                              colums: items,
                              level: level,
                              defaultIndex: defaultIndex,
                              showToolbar: true,
                              itemHeight: 36,
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
                                  // picker在多维度如果不整齐的话，缺少的会补位"-"
                                  var tailIndex = values.indexOf("-");
                                  if (tailIndex == -1) {
                                    selectedText = values.join("/");
                                    value = getTreeNode(index).value;
                                  } else {
                                    selectedText =
                                        values.sublist(0, tailIndex).join("/");
                                    value =
                                        getTreeNode(index.sublist(0, tailIndex))
                                            .value;
                                  }
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
      var node = DataConverter.getIndexInTreeNodesByValue(val, widget.nodes);
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
