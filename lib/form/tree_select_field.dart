import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vant_form_builder/form/tree_select_view.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/util/data_converter.dart';
import 'package:vant_form_builder/util/toast_util.dart';

class TreeSelectField extends StatefulWidget {
  final String name;
  final List<TreeNode> nodes;
  final String label;
  final String? placeholder;
  final bool required;
  final FormFieldValidator? validator;
  final List<String>? defaultValue;
  final TextStyle? chipLabelStyle;
  final Color? chipBackGroundColor;
  final bool loading;
  final int limit;
  final dynamic Function(List?)? onConfirm;

  TreeSelectField(
    this.name, {
    Key? key,
    this.nodes = const [],
    this.label = "",
    this.placeholder,
    this.required = false,
    this.validator,
    this.defaultValue,
    this.chipLabelStyle,
    this.chipBackGroundColor,
    this.loading = false,
    this.onConfirm,
    this.limit = 1000,
  }) : super(key: key);

  @override
  _TreeSelectFieldState createState() => _TreeSelectFieldState();
}

class _TreeSelectFieldState extends State<TreeSelectField> {
  List<String>? _selected;

  _TreeSelectFieldState();

  @override
  void initState() {
    if (widget.defaultValue != null) {
      _selected = widget.defaultValue;
    } else {
      FormBuilderState? formBuilderState = context.findAncestorStateOfType<FormBuilderState>();
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
          setState(() {
            _selected = widget.defaultValue;
          });
        },
        builder: (FormFieldState<dynamic> field) {
          return GestureDetector(
              onTap: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (widget.nodes.length == 0) {
                  ToastUtil.info("无数据");
                  return;
                }

                List? selectedValues = await showDialog<List>(
                  context: context,
                  builder: (BuildContext context) {
                    return TreeSelectView(
                      widget.nodes,
                      title: Text("请选择" + widget.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold)),
                      okButtonLabel: "确定",
                      cancelButtonLabel: "取消",
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
              },
              child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: widget.label + (widget.required ? " *" : ''),
                    errorText: field.errorText,
                    labelStyle: widget.required
                        ? Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(color: Colors.red)
                        : Theme.of(context).inputDecorationTheme.labelStyle,
                    hintText: widget.placeholder ?? "请输入" + widget.label,
                  ),
                  child: widget.loading
                      ? Text("数据加载中...")
                      : _selected != null && _selected!.length > 0
                          ? _buildSelectedOptions()
                          : Text(widget.placeholder ?? "请选择" + widget.label,
                              style: Theme.of(context).inputDecorationTheme.hintStyle)));
        });
  }

  Widget _buildSelectedOptions() {
    List<String> selectedOptions = [];

    if (_selected != null) {
      for (var item in _selected!) {
        var existingItem = DataConverter.getIndexInTreeNodesByValue(item, widget.nodes);
        if (existingItem == null) {
          continue;
        }
        selectedOptions.add(existingItem.text);
      }
    }
    return Text(selectedOptions.join(", "));
  }
}
