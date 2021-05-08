import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:vant_form_builder/model/attachment.dart';

class ImageDetailSwiper extends StatelessWidget {
  final List<Attachment> attachments;

  const ImageDetailSwiper(this.attachments, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(children: [_buildSwipe(), SizedBox(width: 10), Text("共${attachments.length}张"), Spacer()]),
      onTap: () {
        showDialog(context: context, useSafeArea: false, builder: (BuildContext context) => _buildSwipe(modal: true));
      },
    );
  }

  Widget _buildSwipe({bool modal = false}) {
    return Container(
        padding: EdgeInsets.all(modal ? 0 : 5),
        width: modal ? double.infinity : 64,
        height: modal ? double.infinity : 64,
        child: LiquidSwipe(
            enableLoop: !modal,
            pages: attachments.map<Widget>((a) => Center(child: Image.network(a.url!, fit: BoxFit.fill))).toList()));
  }
}
