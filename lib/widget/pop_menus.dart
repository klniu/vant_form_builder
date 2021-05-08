import 'package:flutter/material.dart';
import 'dart:ui' as ui show window;

const Color _bgColor = Color(0xFF2D2D2D);
const double _fontSize = 16.0;
const double _cellHeight = 50.0;
const double _imgWH = 22.0;

typedef _ClickCallBack = void Function(int selectIndex, String selectText);

/// change from https://github.com/iotjin/jh_flutter_demo
class JhPopMenus {
  //显示pop
  static void show(BuildContext context, List<MenuItem> items, {_ClickCallBack? clickCallback}) {
    //Cell
    Widget _buildMenuCell(dataArr) {
      return ListView.builder(
          itemCount: dataArr.length,
          itemExtent: _cellHeight,
          padding: const EdgeInsets.all(0.0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Material(
                color: _bgColor,
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      if (clickCallback != null) {
                        clickCallback(index, items[index].text);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 25),
                        Icon(dataArr[index].iconData, size: _imgWH, color: Colors.white),
                        SizedBox(width: 15),
                        Text(dataArr[index].text, style: TextStyle(color: Colors.white, fontSize: _fontSize)),
                      ],
                    )));
          });
    }

    Widget _menusView(dataArr) {
      var cellH = dataArr.length * _cellHeight;
      var navH = navigationBarHeight;
      return Positioned(
        right: 10,
        top: navH - 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.arrow_drop_up_outlined, size: 28),
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(color: _bgColor, width: 160, height: cellH, child: _buildMenuCell(dataArr)))
          ],
        ),
      );
    }

    Navigator.of(context).push(DialogRouter(_basePopMenus(_menusView(items))));
  }

  //显示带线带背景 pop
  static void showLinePop(BuildContext context, List<MenuItem> items,
      {bool isShowBg = false, _ClickCallBack? clickCallback}) {
    //带线
    Widget _buildMenuLineCell(dataArr) {
      return ListView.separated(
        itemCount: dataArr.length,
        padding: const EdgeInsets.all(0.0),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Material(
              color: _bgColor,
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (clickCallback != null) {
                      clickCallback(index, items[index].text);
                    }
                  },
                  child: Container(
                    height: _cellHeight,
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 25),
                        Image.asset(dataArr[index]['icon'], width: _imgWH, height: _imgWH, color: Colors.white),
                        SizedBox(width: 12),
                        Text(dataArr[index]['text'], style: TextStyle(color: Colors.white, fontSize: _fontSize))
                      ],
                    ),
                  )));
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: .1,
            indent: 50,
            endIndent: 0,
            color: Color(0xFFE6E6E6),
          );
        },
      );
    }

    Widget _menusView(dataArr) {
      var cellH = dataArr.length * _cellHeight;
      var navH = navigationBarHeight;
      if (isShowBg == true) {
        navH = navH - topSafeHeight;
      } else {
        navH = navH - 10;
      }
      return Positioned(
        right: 10,
        top: navH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.arrow_drop_up_outlined, size: 28),
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(color: _bgColor, width: 160, height: cellH, child: _buildMenuLineCell(dataArr)))
          ],
        ),
      );
    }

    if (isShowBg == true) {
      //带背景
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return _basePopMenus(_menusView(items));
          });
    } else {
      Navigator.of(context).push(DialogRouter(_basePopMenus(_menusView(items))));
    }
  }

  static double get navigationBarHeight {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top + kToolbarHeight;
  }

  static double get topSafeHeight {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top;
  }
}

class MenuItem {
  String text;
  IconData? iconData;

  MenuItem(this.text, {this.iconData});
}

class _basePopMenus extends Dialog {
  _basePopMenus(this.child, {
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.pop(context)),
          //内容
          child
        ],
      ),
    );
  }
}

class DialogRouter extends PageRouteBuilder {
  final Widget page;

  DialogRouter(this.page)
      : super(
          opaque: false,
          // 自定义遮罩颜色
          barrierColor: Colors.white10.withAlpha(1),
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
}

class CustomDialog extends Dialog {
  CustomDialog({
    Key? key,
    this.child,
    this.clickBgHidden: false, //点击背景隐藏，默认不隐藏
  }) : super(key: key);

  final Widget? child;
  final bool clickBgHidden;

  @override
  Widget build(BuildContext context) {
    return Material(
        //透明层
        type: MaterialType.transparency,
        child: Stack(
          children: <Widget>[
            InkWell(
              onTap: () {
                if (clickBgHidden == true) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            //内容
            Center(child: child)
//            child
          ],
        ));
  }
}
