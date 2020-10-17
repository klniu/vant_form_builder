// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TreeNode _$TreeNodeFromJson(Map<String, dynamic> json) {
  return TreeNode(
    id: json['id'] as String,
    parentId: json['parentId'] as String,
    children: (json['children'] as List)
        ?.map((e) =>
            e == null ? null : TreeNode.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    hasChildren: json['hasChildren'] as bool,
    title: json['title'] as String,
    key: json['key'] as String,
    value: json['value'] as String,
  );
}

Map<String, dynamic> _$TreeNodeToJson(TreeNode instance) => <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'children': instance.children?.map((e) => e?.toJson())?.toList(),
      'hasChildren': instance.hasChildren,
      'title': instance.title,
      'key': instance.key,
      'value': instance.value,
    };
