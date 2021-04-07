import 'package:get/get.dart';
import 'package:vant_form_builder/model/tree_node.dart';
import 'package:vant_form_builder/widget/picker.dart';

class DataConverter {
  /// TreeNode转换为Picker的option PickerItem
  static List<PickerItem> treeNode2PickerItem(List<TreeNode> nodes) {
    List<PickerItem> items = new List();
    if (nodes == null || nodes.length == 0) {
      return items;
    }
    for (var node in nodes) {
      if (node.children != null && node.children.length > 0) {
        items.add(PickerItem(node.title, child: treeNode2PickerItem(node.children)));
      } else {
        items.add(PickerItem(node.title));
      }
    }
    return items;
  }

  /// 获取PickerItem树的高度
  static int getPickerItemDeep(List<PickerItem> items) {
    if (items == null || items.length == 0) {
      return 0;
    }
    var heights = items.map((e) => getPickerItemDeep(e.child) + 1).toList();
    heights.sort();
    return heights.last;
  }

  /// 获取值在TreeNode列表值中的索引
  static DefaultTreeNode getIndexInTreeNodesByValue(String value, List<TreeNode> nodes) {
    if (nodes == null || nodes.length == 0 || value.isBlank) {
      return null;
    }
    for (int i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node.value == value) {
        return DefaultTreeNode([i], value, node.title);
      } else if (node.children != null && node.children.length > 0) {
        var childResult = getIndexInTreeNodesByValue(value, node.children);
        if (childResult != null){
          childResult.index.insert(0, i);
          return childResult;
        }
      }
    }
    return null;
  }
}

// 在TreeNodes中默认的TreeNode
class DefaultTreeNode {
  List<int> index;
  String value;
  String text;

  DefaultTreeNode(this.index, this.value, this.text);
}

