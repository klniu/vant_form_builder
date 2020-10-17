import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

@JsonSerializable()
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

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}
