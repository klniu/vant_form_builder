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

  TreeNode(this.title, this.value, this.id, {this.parentId, this.children, this.key, this.depth}) {
    this.expand = false;
  }

  factory TreeNode.fromJson(Map<String, dynamic> json) =>
      TreeNode(json['title'] as String, json['value'] as T, json['id'] as String,
          parentId: json['parentId'] as String,
          children: (json['children'] as List)
              ?.map((e) => e == null ? null : TreeNode.fromJson(e as Map<String, dynamic>))
              ?.toList(),
          key: json['key'] as String,
          depth: json['depth'] as int);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': this.id,
        'parentId': this.parentId,
        'children': this.children?.map((e) => e?.toJson())?.toList(),
        'title': this.title,
        'key': this.key,
        'value': this.value,
        'depth': this.depth
      };
}
