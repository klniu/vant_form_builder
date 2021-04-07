import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

//照片墙
class ImageWall extends StatefulWidget {
  // 图片文件数组
  final List<String> images;

  // 是否可以多选图片
  final bool multiple;

  /// 图片是否仅支持摄像头拍摄
  final bool onlyCamera;

  // 单行的图片数量
  final int length;

  // 最多可以选择的图片张数
  final int count;

  // 图片预览样式
  final BoxFit imageFit;

  // 自定义 button
  final Widget uploadBtn;

  // 上传后返回全部图片信息
  final Function(List<String> newImages) onChange;

  // 监听图片上传
  final Future<List<String>> Function(ImageFiles files) onUpload;

  // 删除图片后的回调
  final Function(String removedUrl) onRemove;

  const ImageWall({
    Key key,
    this.multiple: false,
    this.onlyCamera: false,
    this.length: 4,
    this.count: 9,
    this.images,
    this.uploadBtn,
    this.imageFit: BoxFit.cover,
    @required this.onChange,
    @required this.onUpload,
    this.onRemove,
  }) : super(key: key);

  @override
  _ImageWall createState() => _ImageWall();
}

class _ImageWall extends State<ImageWall> {
  List<String> images = [];
  double space = 10.0;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Wrap(
          direction: Axis.horizontal,
          spacing: space,
          runSpacing: space,
          children: buildImages(),
        ));
  }

  List<Widget> buildImages() {
    List<Widget> widgets = [];
    images = widget.images ?? [];
    for (int i = 0; i < images.length; i++) {
      widgets.add(_buildImageItem(i));
    }
    if (widget.count == null || images.length < widget.count) {
      widgets.add(_buildAddImageButton());
    }
    return widgets;
  }

  Widget _buildImageItem(int index) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        ClipRRect(
            child: Image.network(
              images[index],
              fit: widget.imageFit,
              width: 80.0,
              height: 80.0,
            ),
            borderRadius: BorderRadius.circular(4.0)),
        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(999.0),
            child: Icon(Icons.cancel, color: Colors.grey, size: 16.0),
            onTap: () {
              String removedUrl;
              setState(() {
                removedUrl = images.removeAt(index);
              });
              widget.onChange(images);
              if (widget.onRemove != null) {
                widget.onRemove(removedUrl);
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildAddImageButton() {
    Widget btn = Container(
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0)),
      child: Icon(Icons.add, color: Colors.grey, size: 18.0),
    );

    return InkWell(
      child: widget.uploadBtn ?? btn,
      onTap: () async {
        ImageFiles imageFiles = ImageFiles();
        try {
          if (widget.onlyCamera) {
            var result = await pickImageFromCamera();
            if (result == null) {
              return;
            }
            imageFiles.pickedFile = result;
          } else {
            List<Asset> resultList = await MultiImagePicker.pickImages(
              maxImages: widget.multiple ? widget.count - images.length : 1,
              enableCamera: true,
              cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
              materialOptions: MaterialOptions(
                  startInAllView: true,
                  useDetailsView: true,
                  selectCircleStrokeColor: "#000000",
                  actionBarColor: "#000000"),
            );
            imageFiles.assets = resultList;
          }
        } on Exception catch (e) {
          print(e.toString());
        }
        List<String> urls = await widget.onUpload(imageFiles);
        if (urls == null || urls.isEmpty) {
          return;
        }
        setState(() {
          images.addAll(urls);
        });
        widget.onChange(images);
      },
    );
  }

  Future<PickedFile> pickImageFromCamera() async {
    return await picker.getImage(source: ImageSource.camera);
  }
}

class ImageFiles {
  List<Asset> assets;
  PickedFile pickedFile;

  bool isEmpty() {
    return (assets == null || assets.length == 0) && pickedFile == null;
  }
}
