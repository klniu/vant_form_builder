import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vant_kit/widgets/imageWall.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vant_form_builder/model/attachment_type.dart';
import 'package:vant_form_builder/model/attachment.dart';
import 'package:vant_form_builder/util/toast_util.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';

import 'custom_form_field.dart';

class AttachmentPickerField extends StatefulWidget {
  final String name;
  final AttachmentType attachmentType;
  final bool onlyCamera;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final int maxCount;
  final Function(List<Attachment>) onChange;
  final Function(Attachment) onRemove;
  final bool disabled;
  final Future Function(MultipartFile) uploadService;

  /// 最大附件数量
  final List<Attachment> defaultAttachments;

  const AttachmentPickerField(this.name, this.attachmentType, this.uploadService,
      {Key key,
      this.onlyCamera: false,
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.maxCount = 20,
      this.defaultAttachments,
      this.onChange,
      this.onRemove,
      this.disabled = false})
      : super(key: key);

  @override
  _AttachmentPickerFieldState createState() => _AttachmentPickerFieldState();
}

class _AttachmentPickerFieldState extends State<AttachmentPickerField> {
  List<Attachment> _attachments = [];
  List<String> _images;
  bool _uploading = false;
  int uploadCount = 1;

  int get _remainingItemCount => widget.maxCount == null ? null : widget.maxCount - _attachments.length;

  static FormBuilderState of(BuildContext context) => context.findAncestorStateOfType<FormBuilderState>();

  @override
  void initState() {
    if (widget.defaultAttachments != null) {
      _attachments = [...widget.defaultAttachments];
    } else {
      FormBuilderState formBuilderState = of(context);
      if (formBuilderState != null && formBuilderState.initialValue != null) {
        _attachments = formBuilderState.initialValue[widget.name] ?? [];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<Attachment>>(
        name: widget.name,
        validator: widget.validator,
        initialValue: _attachments,
        enabled: !widget.disabled,
        onReset: () {
          setState(() {
            _attachments = widget.defaultAttachments == null ? [] : [...widget.defaultAttachments];
          });
        },
        builder: (FormFieldState<List<Attachment>> field) {
          return CustomFormField(
              label: widget.label,
              labelWidth: widget.labelWidth,
              required: widget.required,
              errorText: field.errorText,
              child: _buildPicker(field));
        });
  }

  Widget _buildPicker(FormFieldState<List<Attachment>> field) {
    if (widget.attachmentType == AttachmentType.Image) {
      _images ??= List.from(_attachments.map((e) => e.url).toList());
      return _buildImagePicker(field);
    } else if (widget.attachmentType == AttachmentType.All) {
      return _buildAllFilePicker(field);
    }
    return Text("");
  }

  Widget _buildImagePicker(FormFieldState<List<Attachment>> field) {
    return Stack(alignment: AlignmentDirectional.centerStart, children: [
      ImageWall(
        images: _images,
        count: widget.maxCount,
        onlyCamera: widget.onlyCamera,
        onUpload: (files) async {
          if (files.isEmpty() || widget.disabled) {
            return null;
          }
          setState(() {
            _uploading = true;
          });
          uploadCount = 0;

          List<Attachment> attachments = [];
          // 从相机来，只有一张照片
          if (files.pickedFile != null) {
            setState(() {
              ++uploadCount;
            });
            img.Image image = img.decodeImage(await File(files.pickedFile.path).readAsBytes());
            // 压缩图片
            if (image.height > 1000) {
              image = img.copyResize(image, height: 1000);
            } else if (image.width > 1000) {
              image = img.copyResize(image, width: 1000);
            }
            MultipartFile multipartFile = MultipartFile.fromBytes(
              img.encodeJpg(image),
              filename: "DCIM_${new DateFormat("yyyyMMddHHmmss").format(DateTime.now())}.jpg",
              contentType: MediaType.parse('image/jpeg'),
            );
            Attachment attachment = await widget.uploadService(multipartFile);
            if (attachment != null) {
              setState(() {
                attachments.add(attachment);
              });
            }
          } else if (files.assets != null && files.assets.length > 0) {
            var assets = files.assets;
            for (var file in assets) {
              setState(() {
                ++uploadCount;
              });
              ByteData byteData;
              // 压缩图片
              if (file.originalHeight > 1000) {
                byteData = await file.getThumbByteData((file.originalWidth / file.originalHeight * 1000).round(), 1000,
                    quality: 90);
              } else if (file.originalWidth > 1000) {
                byteData = await file.getThumbByteData(1000, (file.originalHeight / file.originalWidth * 1000).round(),
                    quality: 90);
              } else {
                byteData = await file.getByteData(quality: 90);
              }
              List<int> imageData = byteData.buffer.asUint8List();
              MultipartFile multipartFile = MultipartFile.fromBytes(imageData, filename: file.name);
              Attachment attachment = await widget.uploadService(multipartFile);
              if (attachment != null) {
                setState(() {
                  attachments.add(attachment);
                });
              }
            }
          }
          field.didChange(attachments);
          if (widget.onChange != null) {
            widget.onChange(attachments);
          }
          setState(() {
            _attachments.addAll(attachments);
            _uploading = false;
          });
          return attachments.map((e) => e.url).toList();
        },
        onRemove: (file) {
          if (widget.disabled) {
            return null;
          }
          var index = _attachments.indexWhere((element) => element.url == file);
          setState(() {
            _attachments.removeAt(index);
          });
          field.didChange(_attachments);
          if (widget.onRemove != null) {
            widget.onRemove(_attachments[index]);
          }
        },
        onChange: (image) {},
      ),
      if (_uploading) _uploadingWidget()
    ]);
  }

  Widget _uploadingWidget() {
    return Container(
        width: 180,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: Text("正在上传，第$uploadCount张...", style: TextStyle(color: Colors.white)));
  }

  Widget _buildAllFilePicker(FormFieldState<List<Attachment>> field) {
    return Stack(alignment: AlignmentDirectional.center, children: [
      if (_uploading) _uploadingWidget(),
      Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (widget.maxCount != null) Text("${_attachments.length}/${widget.maxCount}"),
              InkWell(
                child: const Text("选择文件"),
                onTap: (_remainingItemCount != null && _remainingItemCount <= 0 && !widget.disabled)
                    ? null
                    : () => pickFiles(field),
              ),
            ],
          ),
          SizedBox(height: 3),
          defaultFileViewer(field),
        ],
      ),
    ]);
  }

  Future<void> pickFiles(FormFieldState field) async {
    FilePickerResult result;
    try {
      if (await Permission.storage.request().isGranted) {
        result = await FilePicker.platform.pickFiles(withData: true);
      } else {
        ToastUtil.error("存储权限获取失败");
        throw new Exception("存储权限获取失败");
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _uploading = true;
      });
      for (var file in result.files) {
        MultipartFile multipartFile = MultipartFile.fromBytes(file.bytes, filename: file.name);
        Attachment attachment = await widget.uploadService(multipartFile);
        setState(() => _attachments.add(attachment));
        field.didChange(_attachments);
      }
      setState(() {
        _uploading = false;
      });
    }
  }

  defaultFileViewer(FormFieldState field) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var count = 5;
        var spacing = 10;
        var itemSize = (constraints.biggest.width - (count * spacing)) / count;
        return Wrap(
          // scrollDirection: Axis.horizontal,
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          runSpacing: 10,
          spacing: 10,
          children: List.generate(
            _attachments.length,
            (index) {
              return Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  Container(
                    height: itemSize,
                    width: itemSize,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.insert_drive_file,
                      color: Colors.lightBlue,
                      size: 36,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (!widget.disabled) {
                        removeFileAtIndex(index, field);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.7),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      height: 16,
                      width: 16,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void removeFileAtIndex(int index, FormFieldState field) {
    setState(() {
      _attachments.removeAt(index);
    });
    field.didChange(_attachments);
  }
}
