class Attachment {
  String id;
  String tenantId;
  String businessId;
  String originalName;
  String name;
  String fileType;
  String fileUsage;
  int sort;
  String url;
  String usageName;

  Attachment(
      {this.id,
      this.tenantId,
      this.businessId,
      this.originalName,
      this.name,
      this.fileType,
      this.fileUsage,
      this.sort,
      this.url,
      this.usageName});

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
  id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      businessId: json['businessId'] as String,
      originalName: json['originalName'] as String,
      name: json['name'] as String,
      fileType: json['fileType'] as String,
      fileUsage: json['fileUsage'] as String,
      sort: json['sort'] as int,
      url: json['url'] as String,
      usageName: json['usageName'] as String,
  );

  Map<String, dynamic> toJson() =>
      <String, dynamic>{
        'id': this.id,
        'tenantId': this.tenantId,
        'businessId': this.businessId,
        'originalName': this.originalName,
        'name': this.name,
        'fileType': this.fileType,
        'fileUsage': this.fileUsage,
        'sort': this.sort,
        'url': this.url,
        'usageName': this.usageName,
      };
}
