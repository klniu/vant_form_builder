import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vant_kit/theme/style.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/util/toast_util.dart';

import 'custom_form_field.dart';
import 'multiselect_dialog.dart';

class MultipleSelectField extends StatefulWidget {
  final String name;
  final List<TreeNode> nodes;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final List<String> defaultValue;
  final TextStyle chipLabelStyle;
  final Color chipBackGroundColor;
  final bool loading;
  final dynamic Function(String title, String value) onConfirm;

  MultipleSelectField(this.name,
      {Key key,
      this.nodes = const [],
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.defaultValue,
      this.chipLabelStyle,
      this.chipBackGroundColor,
      this.loading = false,
      this.onConfirm})
      : super(key: key);

  @override
  _MultipleSelectFieldState createState() => _MultipleSelectFieldState();
}

class _MultipleSelectFieldState extends State<MultipleSelectField> {
  List<String> selected;

  _MultipleSelectFieldState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selected ??= widget.defaultValue ?? [];
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        initialValue: widget.defaultValue,
        onReset: () {
          setState(() {
            selected = widget.defaultValue;
          });
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
                        child: widget.loading ? Text("数据加载中...",
                      style: TextStyle(color: Style.fieldInputTextColor, fontSize: Style.fieldFontSize))
                  :
                  selected != null && selected.length > 0
                            ? Wrap(spacing: 8.0, runSpacing: 0.0, children: _buildSelectedOptions())
                            : Text("请选择" + widget.label,
                                style:
                                    TextStyle(color: Style.fieldPlaceholderTextColor, fontSize: Style.fieldFontSize))),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.grey,
                      size: 18,
                    )
                  ]),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    if (widget.nodes == null || widget.nodes.length == 0) {
                      ToastUtil.info("无数据");
                      return;
                    }
                    final items = List<MultiSelectDialogItem<dynamic>>();
                    widget.nodes.forEach((item) {
                      items.add(MultiSelectDialogItem(item.value, item.title));
                    });

                    List selectedValues = await showDialog<List>(
                      context: context,
                      builder: (BuildContext context) {
                        return MultiSelectDialog(
                          title: Text("请选择" + widget.label, style: TextStyle(fontSize: Style.pickerTitleFontSize)),
                          okButtonLabel: "确定",
                          cancelButtonLabel: "取消",
                          items: items,
                          initialSelectedValues: selected,
                        );
                      },
                    );

                    if (selectedValues != null) {
                      setState(() {
                        selected = List.from(selectedValues);
                      });
                      field.didChange(selected);
                    }
                  }));
        });
  }

  List<Widget> _buildSelectedOptions() {
    List<Widget> selectedOptions = [];

    if (selected != null) {
      for (var item in selected) {
        var existingItem = widget.nodes.singleWhere((itm) => itm.value == item, orElse: () => null);
        if (existingItem == null) {
          continue;
        }
        selectedOptions.add(Chip(
          labelStyle: widget.chipLabelStyle ?? TextStyle(color: Colors.white, backgroundColor: Colors.lightBlue),
          backgroundColor: widget.chipBackGroundColor ?? Colors.lightBlue,
          label: Text(
            existingItem.title,
            overflow: TextOverflow.ellipsis,
          ),
        ));
      }
    }
    return selectedOptions;
  }

  TreeNode getTreeNode(List<int> indices) {
    TreeNode node = widget.nodes[indices[0]];
    for (var index in indices.sublist(1)) {
      node = node.children[index];
    }
    return node;
  }
}
