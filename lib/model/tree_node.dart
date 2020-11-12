import 'package:json_annotation/json_annotation.dart';

part 'tree_node.g.dart';

@JsonSerializable()
class TreeNode<T> {
  String id;
  String parentId;
  List<TreeNode<T>> children;
  String title;
  String key;
  T value;
  int depth;

  bool expand;
  TreeNode<T> parent;

  bool get hasChildren => children != null && children.length > 0;

  TreeNode(this.title, this.value, this.id,
      {this.parentId, this.children, this.key, this.depth}) {
    this.expand = false;
  }

  factory TreeNode.fromJson(Map<String, dynamic> json) => _$TreeNodeFromJson(json);
  Map<String, dynamic> toJson() => _$TreeNodeToJson(this);
}
