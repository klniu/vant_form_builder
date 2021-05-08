import 'package:flutter/material.dart';
import 'package:vant_form_builder/form/multiselect_dialog.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/theme/button_styles.dart';
import 'package:vant_form_builder/util/toast_util.dart';
import 'package:vant_form_builder/vant_form_builder.dart';

class TreeSelectView extends StatefulWidget {
  final List<TreeNode> nodes;
  final List? initialSelectedValues;
  final Widget? title;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final TextStyle? labelStyle;
  final ShapeBorder? dialogShapeBorder;
  final Color? checkBoxCheckColor;
  final Color? checkBoxActiveColor;
  final int limit;

  const TreeSelectView(
    this.nodes, {
    Key? key,
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
  State<StatefulWidget> createState() {
    return TreeSelectViewState();
  }
}

class TreeSelectViewState extends State<TreeSelectView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ///保存所有数据的List
  List<TreeNode> list = [];

  ///保存当前展示数据的List
  List<TreeNode>? expand = [];

  ///保存List的下标的List，用来做标记用
  List<String?> mark = [];

  ///展示搜索结构
  bool showSearch = false;
  List<TreeNode>? keep;

  final _selectedValues = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues!);
    }
    _parseNodes(widget.nodes);
    _expandDefault();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ButtonBarTheme(
        data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
        child: AlertDialog(
          title: widget.title,
          shape: widget.dialogShapeBorder,
          contentPadding: EdgeInsets.fromLTRB(10.0, 0, 10, 10),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SearchBar(widget.nodes, _onSearch),
            Flexible(
                child: SingleChildScrollView(
              child: ListTileTheme(
                contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
                child: ListBody(
                  children: expand!.map(_buildNode).toList(),
                ),
              ),
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

  ///搜索结果
  void _onSearch(List<TreeNode> result) {
    setState(() {
      if (result.isEmpty) {
        //如果为空，代表搜索关键字为空
        showSearch = false;
        expand = keep; //将之前保存的状态还原
      } else {
        if (!showSearch) {
          //如果之前展示的不是搜索的结果，保存状态，为了之后状态还原做准备
          keep = expand;
        }
        showSearch = true; //展示搜索结果
        expand = result;
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  ///如果解析的数据是一个list列表，采用这个方法
  void _parseNodes(List<TreeNode> nodes) {
    for (var dept in nodes) {
      _parseTreeNode(dept);
    }
  }

  ///递归解析原始数据，将dept递归，记录其深度，nodeID和fatherID，将根节点的fatherID置为-1，
  ///保存原始数据为泛型T
  void _parseTreeNode(TreeNode node, {int depth = 0, String? fatherId, TreeNode? parent}) {
    node.depth = depth;
    node.parentId = fatherId;
    node.parent = parent;
    // 找到所有需要展开的项
    if (_selectedValues.contains(node.value)) {
      node.parent?.expand = true;
    }
    list.add(node);

    if (node.hasChildren) {
      for (var child in node.children!) {
        _parseTreeNode(child, depth: depth + 1, fatherId: node.id, parent: node);
      }
    }
  }

  void _expandDefault() {
    var idToList = Map.fromIterable(list, key: (e) => e.id);
    // 在已经需要展开的项中找逐级找父项，并标记为展开
    for (TreeNode? node in list) {
      if (node.expand) {
        do {
          var parentNode = idToList[node!.parentId];
          if (parentNode != null) {
            parentNode.expand = true;
          }
          node = parentNode;
        } while (node != null);
      }
    }
    for (var node in list) {
      if (node.parentId == null) {
        expand!.add(node);
      }
      if (node.expand) {
        _expand(node);
      }
    }
  }

  ///扩展机构树：id代表被点击的机构id
  /// 做法是遍历整个list列表，将直接挂在该机构下面的节点增加到一个临时列表中，
  ///然后将临时列表插入到被点击的机构下面
  void _expand(TreeNode node) {
    if (!node.hasChildren) {
      return;
    }
    //找到插入点
    int index = -1;
    int length = expand!.length;
    for (int i = 0; i < length; i++) {
      if (node.id == expand![i].id) {
        index = i + 1;
        break;
      }
    }
    //插入
    expand!.insertAll(index, node.children!);
  }

  ///收起机构树：id代表被点击的机构id
  /// 做法是遍历整个expand列表，将直接和间接挂在该机构下面的节点标记，
  ///将这些被标记节点删除即可，此处用到的是将没有被标记的节点加入到新的列表中
  void _collect(String? id) {
    //清楚之前的标记
    mark.clear();
    //标记
    _mark(id);
    //重新对expand赋值
    List<TreeNode> tmp = [];
    for (TreeNode node in expand!) {
      if (mark.indexOf(node.id) < 0) {
        tmp.add(node);
      } else {
        node.expand = false;
      }
    }
    expand!.clear();
    expand!.addAll(tmp);
  }

  ///标记，在收起机构树的时候用到
  void _mark(String? id) {
    for (var node in expand!) {
      if (id == node.parentId) {
        mark.add(node.id);
      }
    }
  }

  ///增加根
  void _addRoot() {
    for (var node in list) {
      if (node.parentId == null) {
        expand!.add(node);
      }
    }
  }

  ///构建元素
  Widget _buildNode(TreeNode node) {
    final checked = _selectedValues.contains(node.value);
    return GestureDetector(
        child: Row(children: [
          SizedBox(width: showSearch ? 0 : node.depth! * 10.0),
          if (node.hasChildren)
            Icon(node.expand ? Icons.keyboard_arrow_down_sharp : Icons.keyboard_arrow_right_sharp, size: 24)
          else
            SizedBox(width: 24),
          SizedBox(width: 8),
          Expanded(child: Text(node.title, style: widget.labelStyle)),
          Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                  height: 36.0,
                  width: 36.0,
                  child: Checkbox(
                    value: checked,
                    checkColor: widget.checkBoxCheckColor,
                    activeColor: widget.checkBoxActiveColor,
                    onChanged: (checked) => _onItemCheckedChange(node.value, checked),
                  ))),
        ]),
        onTap: () {
          if (node.expand) {
            //之前是扩展状态，收起列表
            node.expand = false;
            _collect(node.id);
          } else {
            //之前是收起状态，扩展列表
            node.expand = true;
            _expand(node);
          }
          setState(() {});
        });
  }

  void _onItemCheckedChange(dynamic itemValue, bool? checked) {
    setState(() {
      if (checked == true) {
        if (_selectedValues.length >= widget.limit) {
          ToastUtil.error("最多只能选择${widget.limit}项");
        } else {
          _selectedValues.add(itemValue);
        }
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }
}
