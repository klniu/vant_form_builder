import 'package:json_annotation/json_annotation.dart';

part 'tree_node.g.dart';

@JsonSerializable()
class TreeNode {
  String id;
  String parentId;
  List<TreeNode> children;
  bool hasChildren;
  String title;
  String key;
  String value;

  TreeNode({this.id, this.parentId, this.children, this.hasChildren, this.title, this.key, this.value});

  factory TreeNode.fromJson(Map<String, dynamic> json) => _$TreeNodeFromJson(json);
  Map<String, dynamic> toJson() => _$TreeNodeToJson(this);
}
