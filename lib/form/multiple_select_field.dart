import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/util/toast_util.dart';

import 'multiselect_dialog.dart';

class MultipleSelectField extends StatefulWidget {
  final String name;
  final List<TreeNode> nodes;
  final String label;
  final bool required;
  final FormFieldValidator? validator;
  final List<String>? defaultValue;
  final String? placeholder;
  final TextStyle? chipLabelStyle;
  final Color? chipBackGroundColor;
  final bool loading;
  final int limit;
  final dynamic Function(List)? onConfirm;

  MultipleSelectField(this.name,
      {Key? key,
      this.nodes = const [],
      this.label = "",
      this.required = false,
      this.validator,
      this.defaultValue,
      this.placeholder,
      this.chipLabelStyle,
      this.chipBackGroundColor,
      this.loading = false,
      this.onConfirm,
      this.limit = 1000})
      : super(key: key);

  @override
  _MultipleSelectFieldState createState() => _MultipleSelectFieldState();
}

class _MultipleSelectFieldState extends State<MultipleSelectField> {
  List<String> _selected = [];

  _MultipleSelectFieldState();

  static FormBuilderState? of(BuildContext context) => context.findAncestorStateOfType<FormBuilderState>();

  @override
  void initState() {
    if (widget.defaultValue != null) {
      _selected = widget.defaultValue!;
    } else {
      FormBuilderState? formBuilderState = of(context);
      if (formBuilderState != null) {
        _selected = formBuilderState.initialValue[widget.name] ?? [];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        initialValue: widget.defaultValue,
        onReset: () {
          if (widget.defaultValue != null) {
            setState(() {
              _selected = widget.defaultValue!;
            });
          }
        },
        builder: (FormFieldState<dynamic> field) {
          return GestureDetector(
              child: InputDecorator(
                  decoration: InputDecoration(
                      labelText: widget.label + (widget.required ? " *" : ''),
                      errorText: field.errorText,
                      labelStyle: widget.required
                          ? Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(color: Colors.red)
                          : Theme.of(context).inputDecorationTheme.labelStyle,
                      hintText: widget.placeholder ?? "请输入" + widget.label),
                  child: widget.loading
                      ? Text("数据加载中...")
                      : _selected.length > 0
                          ? _buildSelectedOptions()
                          : Text("请选择" + widget.label, style: Theme.of(context).inputDecorationTheme.labelStyle)),
              onTap: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (widget.nodes.length == 0) {
                  ToastUtil.info("无数据");
                  return;
                }
                List? selectedValues = await showDialog<List>(
                  context: context,
                  builder: (BuildContext context) {
                    return MultiSelectDialog(
                      title: Text(
                        "请选择" + widget.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      okButtonLabel: "确定",
                      cancelButtonLabel: "取消",
                      items: widget.nodes,
                      initialSelectedValues: _selected,
                      limit: widget.limit,
                    );
                  },
                );

                if (selectedValues != null) {
                  setState(() {
                    _selected = List.from(selectedValues);
                  });
                  field.didChange(_selected);
                  if (widget.onConfirm != null) {
                    widget.onConfirm!(_selected);
                  }
                }
              });
        });
  }

  Widget _buildSelectedOptions() {
    List<String> selectedOptions = [];

    for (var item in _selected) {
      var existingItem = widget.nodes.singleWhereOrNull((itm) => itm.value == item);
      if (existingItem == null) {
        continue;
      }
      selectedOptions.add(
        existingItem.title,
      );
    }
    return Text(selectedOptions.join(", "));
  }

  TreeNode getTreeNode(List<int> indices) {
    TreeNode node = widget.nodes[indices[0]];
    for (var index in indices.sublist(1)) {
      node = node.children![index];
    }
    return node;
  }
}
