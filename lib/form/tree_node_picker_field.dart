import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/util/data_converter.dart';
import 'package:vant_form_builder/util/toast_util.dart';
import 'package:vant_form_builder/widget/cascade_picker.dart';

class TreeNodePickerField<T> extends StatefulWidget {
  final String name;
  final List<TreeNode<T>> nodes;
  final String label;
  final bool required;
  final FormFieldValidator? validator;
  final T? defaultValue;
  final String? placeholder;
  final bool loading;
  final bool disabled;
  // 节点内容变化的回调
  final dynamic Function(String title, T value)? onConfirm;

  TreeNodePickerField(this.name,
      {Key? key,
      this.nodes = const [],
      this.label = "",
      this.required = false,
      this.validator,
      this.defaultValue,
      this.placeholder,
      this.loading = false,
      this.disabled = false,
      this.onConfirm,
      })
      : super(key: key);

  @override
  _TreeNodePickerFieldState createState() => _TreeNodePickerFieldState<T>();
}

class _TreeNodePickerFieldState<T> extends State<TreeNodePickerField> {
  String selectedText = "";
  List<int>? index;
  T? value;
  final _cascadeController = CascadeController();
  FormFieldState<dynamic>? field;

  _TreeNodePickerFieldState();

  @override
  void initState() {
    super.initState();
    _defaultValueChanged();
  }

  _defaultValueChanged() {
    if (widget.defaultValue != null) {
      _onChangeValueOutside(widget.defaultValue);
    } else {
      FormBuilderState? formBuilderState = context.findAncestorStateOfType<FormBuilderState>();
      if (formBuilderState != null) {
        _onChangeValueOutside(formBuilderState.initialValue[widget.name]);
      }
    }
    // 默认值也在初始时激活一次onConfirmed
    if (value != null && widget.onConfirm != null) {
      widget.onConfirm!(selectedText, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    //  当nodes变化时，重新计算默认值
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        enabled: !widget.disabled,
        initialValue: widget.defaultValue,
        onReset: _defaultValueChanged,
        onChanged: (dynamic val) {
          if (val == value) return;
          _onChangeValueOutside(val);
        },
        builder: (FormFieldState<dynamic> field) {
          this.field = field;
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              if (widget.disabled) {
                return;
              }
              if (widget.nodes.length == 0) {
                ToastUtil.info("无数据");
                return;
              }
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                        height: 260.0,
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                _buildToolbar(context),
                                Expanded(
                                    child: CascadePicker(
                                  initialPageData: widget.nodes,
                                  nextPageData: (pageCallback, currentItem, currentPage, selectIndex) async {
                                    pageCallback(currentItem.children);
                                  },
                                  defaultIndices: index,
                                  controller: _cascadeController,
                                  maxPageNum: 4,
                                )),
                              ],
                            ),
                          ],
                        ));
                  });
            },
            child: InputDecorator(
                decoration: InputDecoration(
                    labelText: widget.label + (widget.required ? " *" : ''),
                    errorText: field.errorText,
                    labelStyle: widget.required
                        ? Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(color: Colors.red)
                        : Theme.of(context).inputDecorationTheme.labelStyle,
                    hintText: widget.placeholder ?? "请输入" + widget.label),
                child: widget.loading
                    ? Text("数据加载中...", style: Theme.of(context).textTheme.bodyText2)
                    : selectedText.isNotEmpty
                        ? Text(selectedText, style: Theme.of(context).textTheme.bodyText2)
                        : Text(widget.placeholder ?? "请选择" + widget.label,
                            style: Theme.of(context).inputDecorationTheme.hintStyle)),
          );
        });
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 44.0,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.0),
            bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildCancelButton(context),
          Text("请选择" + widget.label, style: Theme.of(context).textTheme.subtitle2),
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
          // 判断是否完成选择
          if (_cascadeController.isCompleted()) {
            List<TreeNode> selectedTitles = _cascadeController.selectedItems;
            setState(() {
              index = _cascadeController.selectedIndexes;
              selectedText = selectedTitles.map((e) => e.title).join("/");
              value = getTreeNode(index!).value;
            });
            field!.didChange(value);
            if (widget.onConfirm != null) {
              widget.onConfirm!(selectedText, value);
            }
            Navigator.pop(context);
          } else {
            ToastUtil.info("请选择至最后一级");
          }
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            alignment: AlignmentDirectional.center,
            child: Text("确定", style: Theme.of(context).textTheme.subtitle2)),
      ),
    );
  }

  Widget buildCancelButton(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: AlignmentDirectional.center,
          child: Text("取消", style: Theme.of(context).textTheme.subtitle2),
        ),
      ),
    );
  }

  TreeNode getTreeNode(List<int> indices) {
    TreeNode node = widget.nodes[indices[0]];
    for (var index in indices.sublist(1)) {
      node = node.children![index];
    }
    return node;
  }

  /// 在外部通过form_builder更改时调用
  _onChangeValueOutside(T? val) {
    if (val != null) {
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
