import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:vant_form_builder/model/attachment.dart';

class ImageDetailSwiper extends StatefulWidget {
  final List<Attachment> attachments;

  const ImageDetailSwiper(this.attachments, {Key? key}) : super(key: key);

  @override
  _ImageDetailSwiperState createState() => _ImageDetailSwiperState();
}

class _ImageDetailSwiperState extends State<ImageDetailSwiper> {
  int currentIndex = 0;
  bool isDialog = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(children: [_buildSwipe(), SizedBox(width: 10), Text("共${widget.attachments.length}张"), Spacer()]),
      onTap: () {
        this.isDialog = true;
        showDialog(context: context, useSafeArea: false, builder: (BuildContext context) => _buildSwipe(modal: true));
      },
    );
  }

  Widget _buildSwipe({bool modal = false}) {
    var imageWidget = Container(
        color: modal ? Colors.black : Colors.transparent,
        width: modal ? double.infinity : 64,
        height: modal ? double.infinity : 64,
        child: ExtendedImageGesturePageView.builder(
          itemBuilder: (BuildContext context, int index) {
            var item = widget.attachments[index].url!;
            Widget image = ExtendedImage.network(
              item,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
            );
            if (index == currentIndex) {
              return Hero(
                tag: item + index.toString(),
                child: image,
              );
            } else {
              return image;
            }
          },
          itemCount: widget.attachments.length,
          onPageChanged: (int index) {
            currentIndex = index;
          },
          controller: PageController(
            initialPage: currentIndex,
          ),
          scrollDirection: Axis.horizontal,
        ));
    return modal
        ? GestureDetector(
            child: imageWidget,
            onTap: () {
              if (modal && this.isDialog) {
                Navigator.of(context).pop();
              }
            })
        : imageWidget;
  }
}
