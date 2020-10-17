// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return Attachment(
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
}

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'businessId': instance.businessId,
      'originalName': instance.originalName,
      'name': instance.name,
      'fileType': instance.fileType,
      'fileUsage': instance.fileUsage,
      'sort': instance.sort,
      'url': instance.url,
      'usageName': instance.usageName,
    };
