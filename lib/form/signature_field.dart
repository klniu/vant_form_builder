import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:vant_form_builder/theme/button_styles.dart';

class SignatureField extends StatefulWidget {
  final String name;
  final String label;
  final double labelWidth;
  final bool required;
  final FormFieldValidator validator;
  final String defaultSignature; // data uri or url
  final Future Function(String) onConfirm;
  final bool disabled;

  const SignatureField(this.name,
      {Key key,
      this.label,
      this.labelWidth,
      this.required = false,
      this.validator,
      this.defaultSignature,
      this.onConfirm,
      this.disabled = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<SignatureField> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.red,
    exportBackgroundColor: Colors.white,
  );

  String _imageUri;
  static const _dataUriPrefix = "data:image/png;base64,";

  static FormBuilderState of(BuildContext context) => context.findAncestorStateOfType<FormBuilderState>();

  @override
  void initState() {
    if (widget.defaultSignature != null) {
      _imageUri = widget.defaultSignature;
    } else {
      FormBuilderState formBuilderState = of(context);
      if (formBuilderState != null && formBuilderState.initialValue != null) {
        _imageUri = formBuilderState.initialValue[widget.name];
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
        name: widget.name,
        validator: widget.validator,
        initialValue: widget.defaultSignature,
        onReset: () => _controller.clear(),
        enabled: !widget.disabled,
        builder: (FormFieldState<dynamic> field) {
          return InputDecorator(
              decoration: InputDecoration(
                  labelText: widget.label + (widget.required ? " *" : ''),
                  errorText: field.errorText,
                  labelStyle: widget.required ? TextStyle(color: Colors.red) : null),
              child: _buildPicker(field));
        });
  }

  Widget _buildPicker(FormFieldState field) {
    return GestureDetector(
      child: _imageUri == null
          ? Text("点击添加签名",
              textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey))
          : _imageWidget(),
      onTap: () {
        if (widget.disabled) {
          return;
        }
        FocusScope.of(context).requestFocus(new FocusNode());
        _controller.clear();
        Get.dialog(
            Center(
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    decoration: new BoxDecoration(
                        color: Get.theme.scaffoldBackgroundColor,
                        borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
                    constraints: BoxConstraints(maxHeight: 320),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text("手写签名", style: Get.textTheme.subtitle1),
                      SizedBox(height: 10),
                      Column(children: [
                        Signature(
                          controller: _controller,
                          height: 200,
                        ),
                        SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          ElevatedButton(
                              style: ButtonStyles.primary(),
                              child: Text("确定"),
                              onPressed: () async {
                                if (_controller.isNotEmpty) {
                                  var data = await _controller.toPngBytes();
                                  setState(() {
                                    _imageUri = _dataUriPrefix + base64.encode(data);
                                  });
                                  field.didChange(_imageUri);
                                  if (widget.onConfirm != null) {
                                    await widget.onConfirm(_imageUri);
                                  }
                                  Get.back();
                                }
                              }),
                          SizedBox(width: 40),
                          ElevatedButton(onPressed: Get.back, style: ButtonStyles.info(), child: Text("取消"))
                        ])
                      ])
                    ]))),
            barrierDismissible: false);
      },
    );
  }

  Widget _imageWidget() {
    if (_imageUri.startsWith(_dataUriPrefix)) {
      return Image.memory(_base64ImageToByte(_imageUri), height: 30, alignment: Alignment.centerLeft);
    } else if (_imageUri.startsWith("http")) {
      return Image.network(_imageUri, height: 30, alignment: Alignment.centerLeft);
    } else {
      return Text("无效签名");
    }
  }

  Uint8List _base64ImageToByte(String dataUri) {
    if (GetUtils.isNullOrBlank(dataUri) || !dataUri.startsWith("data:image")) return null;
    var index = dataUri.indexOf(",");
    if (index == -1) {
      return null;
    }
    return base64.decode(dataUri.substring(index + 1));
  }
}
