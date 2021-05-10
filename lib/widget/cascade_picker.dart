import 'package:flutter/material.dart';
import 'package:vant_form_builder/model/tree_node.dart';

/// 级联选择器
/// 使用示例:
/// ```dart
/// CascadePicker的page是ListView，没有约束的情况下它的高度是无限的，
/// 因此需要约束高度。
///
/// final _cascadeController = CascadeController();
///
/// initialPageData: 第一页的数据
/// nextPageData: 下一页的数据，点击当前页的选择项后调用该方法加载下一页
///   - pageCallback: 用于传递下一页的数据给CascadePicker
///   - currentPage: 当前是第几页
///   - selectIndex: 当前选中第几项
/// controller: 控制器，用于获取已选择的数据
/// maxPageNum: 最大页数
///
/// Expand(
///   child: CascadePicker(
///     initialPageData: ['a', 'b', 'c', 'd'],
///     nextPageData: (pageCallback, currentPage, selectIndex) async {
///       pageCallback(['one', 'two', 'three'])
///     },
///     controller: _cascadeController,
///     maxPageNum: 4,
/// )
///
/// InkBox(
///   child: Container(...)
///   onTap: () {
///     /// 判断是否完成选择
///     if (_cascadeController.isCompleted()) {
///       List<String> selectedTitles = _cascadeController.selectedTitles;
///       List<int> selectedIndexes = _cascadeController.selectedIndexes;
///     }
///   }
/// )
/// ```
/// pageData: 下一页的数据
/// currentPage: 当前是第几页,
/// selectIndex: 当前页选中第几项
typedef void NextPageCallback(
    Function(List<TreeNode>?) pageData, TreeNode currentItem, int currentPage, int selectIndex);

class CascadePicker extends StatefulWidget {
  final List<TreeNode> initialPageData;
  final NextPageCallback nextPageData;
  final int maxPageNum;
  final CascadeController controller;
  final double tabHeight;
  final double itemHeight;
  final List<int>? defaultIndices;

  CascadePicker({
    required this.initialPageData,
    required this.nextPageData,
    this.maxPageNum = 3,
    required this.controller,
    this.tabHeight = 40,
    this.itemHeight = 30,
    this.defaultIndices,
  });

  @override
  _CascadePickerState createState() => _CascadePickerState(this.controller);
}

class _CascadePickerState extends State<CascadePicker> with SingleTickerProviderStateMixin {
  static TreeNode _newTabName = TreeNode("请选择", null, null);

  final CascadeController _cascadeController;

  _CascadePickerState(this._cascadeController) {
    _cascadeController._setState(this);
  }

  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Animation<double> _sliderAnimation;
  final _sliderFixMargin = ValueNotifier(0.0);
  double _sliderWidth = 20;

  PageController _pageController = PageController(initialPage: 0);

  GlobalKey _sliderKey = GlobalKey();
  List<GlobalKey> _tabKeys = [];

  /// 选择器数据集合
  List<List<TreeNode>> _pagesData = [];

  /// 已选择的title集合
  List<TreeNode> _selectedTabs = [_newTabName];

  /// 已选择的item index集合
  List<int> _selectedIndexes = [-1];

  /// "请选择"tab宽度，添加新的tab时用到
  double _animTabWidth = 0;

  /// tab添加事件记录，用于隐藏"请选择"tab初始化状态
  bool _isAddTabEvent = false;

  /// tab移动未开始，渲染'请选择'tab时隐藏文本，这时的tab在终点位置
  bool _isAnimateTextHide = false;

  /// 防止_moveSlider重复调用
  bool _isClickAndMoveTab = false;

  /// 当前选择的页面，移动滑块前赋值
  int _currentSelectPage = 0;

  _addTab(int page, int atIndex, TreeNode currentPageItem) {
    _loadNextPageData(page, atIndex, currentPageItem);
  }

  _loadNextPageData(int page, int atIndex, TreeNode currentPageItem, {bool isUpdatePage = false}) {
    widget.nextPageData((data) {
      final nextPageDataIsEmpty = data == null || data.isEmpty;
      if (!nextPageDataIsEmpty) {
        /// 下一页有数据，更新本页数据或添加新的页面
        setState(() {
          if (isUpdatePage) {
            /// 更新下一页
            _pagesData[page] = data!;
            _selectedTabs[page] = _newTabName;
            _selectedIndexes[page] = -1;

            /// 清空下下页以后的所有页面和tab数据
            _pagesData.removeRange(page + 1, _pagesData.length);
            _selectedIndexes.removeRange(page + 1, _selectedIndexes.length);
            _selectedTabs.removeRange(page + 1, _selectedTabs.length);
          } else {
            /// 添加新的页面
            _isAnimateTextHide = true;
            _isAddTabEvent = true;
            _pagesData.add(data!);
            _selectedTabs.add(_newTabName);
            _selectedIndexes.add(-1);
          }
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            _moveSlider(page, isAdd: true);
          });
        });
      } else {
        /// 如果下一页数据为空，那么更新本页数据
        final currentPage = page - 1;
        setState(() {
          _selectedTabs[currentPage] = currentPageItem;
          _selectedIndexes[currentPage] = atIndex;

          /// 下一页数据为空，清空下一页以后的所有页面和tab数据
          _pagesData.removeRange(page, _pagesData.length);
          _selectedIndexes.removeRange(page, _selectedIndexes.length);
          _selectedTabs.removeRange(page, _selectedTabs.length);
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            // 调整滑块位置
            _moveSlider(currentPage);
          });
        });
      }
    }, currentPageItem, page, atIndex);
  }

  _moveSlider(int page, {bool movePage = true, bool isAdd = false}) {
    if (movePage && _currentSelectPage != page) {
      /// 上一次选择的页面和本次选择的页面不同时，移动tab标签，
      /// 移动时先把_isClickAndMoveTab设为true，防止滑动PageView
      /// 时_moveSlider重复调用。
      _isClickAndMoveTab = true;
    }
    _isAddTabEvent = isAdd;
    _currentSelectPage = page;

    if (_controller.isAnimating) {
      _controller.stop();
    }
    RenderBox slider = _sliderKey.currentContext!.findRenderObject() as RenderBox;
    Offset sliderPosition = slider.localToGlobal(Offset.zero);
    RenderBox currentTabBox = _tabKeys[page].currentContext!.findRenderObject() as RenderBox;
    Offset currentTabPosition = currentTabBox.localToGlobal(Offset.zero);

    _animTabWidth = currentTabBox.size.width;

    final begin = sliderPosition.dx - _sliderFixMargin.value;
    final end = currentTabPosition.dx + (currentTabBox.size.width - _sliderWidth) / 2 - _sliderFixMargin.value;
    _sliderAnimation = Tween<double>(begin: begin, end: end).animate(_curvedAnimation);
    _controller.value = 0;
    _controller.forward();
    if (movePage) {
      _pageController.animateToPage(page, curve: Curves.linear, duration: Duration(milliseconds: 500));
    }
  }

  /// 注意：tab渲染完成才开始动画，即调用moveSlider，这个方法会在动画执行期间多次调用
  Widget _animateTab(Widget tab) {
    return Transform.translate(
      offset: Offset(Tween<double>(begin: _isAddTabEvent ? -_animTabWidth : 0, end: 0).evaluate(_curvedAnimation), 0),
      child: Opacity(

          /// 动画未开始前隐藏文本
          opacity: _isAnimateTextHide ? 0 : 1,
          child: tab),
    );
  }

  List<Widget> _tabWidgets() {
    List<Widget> widgets = [];
    _tabKeys.clear();
    for (int i = 0; i < _pagesData.length; i++) {
      GlobalKey key = GlobalKey();
      _tabKeys.add(key);
      final tab = GestureDetector(
        child: Container(
          key: key,
          height: widget.tabHeight,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / _pagesData.length - 10),
            child: Text(
              _selectedTabs[i].title,
              style: _currentSelectPage == i
                  ? Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).accentColor)
                  : Theme.of(context).textTheme.bodyText2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        onTap: () {
          _moveSlider(i);
        },
      );
      if (i == _pagesData.length - 1 && _selectedTabs[i] == _newTabName) {
        widgets.add(_animateTab(tab));
        _isAnimateTextHide = false;
      } else {
        widgets.add(tab);
      }
    }
    return widgets;
  }

  /// 选择项
  Widget _pageItemWidget(int index, int page, TreeNode item) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: widget.itemHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            item == _selectedTabs[page]
                ? Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(Icons.check_circle,
                        size: Theme.of(context).textTheme.bodyText2!.fontSize, color: Theme.of(context).accentColor),
                  )
                : SizedBox(width: 3.0 + Theme.of(context).textTheme.bodyText2!.fontSize!.toDouble()),
            Text(item.title,
                style: item == _selectedTabs[page]
                    ? Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).accentColor)
                    : Theme.of(context).textTheme.bodyText2)
          ],
        ),
      ),
      onTap: () {
        if (page == widget.maxPageNum - 1) {
          /// 当前页是最后一页
          setState(() {
            _selectedTabs[page] = item;
            _selectedIndexes[page] = index;

            /// 调整滑块位置
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              _moveSlider(page);
            });
          });
        } else if (_tabKeys.length >= widget.maxPageNum || page < _tabKeys.length - 1) {
          if (index == _selectedIndexes[page]) {
            /// 选择相同的item
            _moveSlider(page + 1);
          } else {
            /// 选择不同的item，更新tab renderBox
            setState(() {
              _selectedTabs[page] = item;
              _selectedIndexes[page] = index;
//              _selectedIndexes.removeRange(page + 1, _selectedIndexes.length);
            });
            _loadNextPageData(page + 1, index, item, isUpdatePage: true);
          }
        } else {
          /// 添加新tab页面
          /// page == _tabKeys.length - 1 && _tabKeys.length == widget.maxPageNum
          _selectedTabs[page] = item;
          _selectedIndexes[page] = index;
          _addTab(page + 1, index, item);
        }
      },
    );
  }

  Widget _pageWidget(int page) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _pagesData[page].length,
      itemBuilder: (context, index) => _pageItemWidget(index, page, _pagesData[page][index]),
//      separatorBuilder: (context, index) => Divider(height: 0.3, thickness: 0.3, color: Color(0xffdddddd), indent: 15, endIndent: 15,),
    );
  }

  @override
  void initState() {
    super.initState();
    _pagesData.add(widget.initialPageData);
    // 初始化默认索引及当前选定值，并在界面跳转到具体的位置
    if (widget.defaultIndices != null) {
      _selectedTabs = [];
      widget.defaultIndices!.asMap().entries.forEach((element) {
        var currentItem = _pagesData[element.key][element.value];
        // 加载下一个数据并添加到列表
        widget.nextPageData((data) {
          if (data != null && data.isNotEmpty) {
            _pagesData.add(data);
          }
        }, currentItem, element.key, element.value);
        // 将最后列的请选择修改为实际值
        _selectedTabs.add(currentItem);
        // 扩展所有列，但最后一列没有下级数据的更新当前列
        // _loadNextPageData(element.key, element.value, currentItem, isUpdatePage: element.key == widget
        //     .defaultIndices!.length - 1);
      });
      // 重新生成索引值
      _selectedIndexes = [...widget.defaultIndices!];
    }

    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.ease)..addStatusListener((state) {});

    _sliderAnimation = Tween<double>(begin: 0, end: 10).animate(_curvedAnimation);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      RenderBox tabBox = _tabKeys.first.currentContext!.findRenderObject() as RenderBox;
      _sliderFixMargin.value = (tabBox.size.width - _sliderWidth) / 2;

      // 如果有默认值，跳转到最后一列
      if (widget.defaultIndices != null && widget.defaultIndices!.isNotEmpty) {
        _moveSlider(_pagesData.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _sliderAnimation,
          builder: (context, child) => Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: _tabWidgets(),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _sliderFixMargin,
                builder: (_, margin, __) => Positioned(
                  left: (margin as double) + _sliderAnimation.value,
                  child: Container(
                    key: _sliderKey,
                    width: _sliderWidth,
                    height: 2,
                    decoration:
                        BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            itemCount: _pagesData.length,
            controller: _pageController,
            itemBuilder: (context, index) => _pageWidget(index),
            onPageChanged: (position) {
              if (!_isClickAndMoveTab) {
                _moveSlider(position, movePage: false);
              }
              if (_currentSelectPage == position) {
                _isClickAndMoveTab = false;
              }
            },
          ),
        )
      ],
    );
  }
}

class CascadeController {
  late _CascadePickerState _state;

  _setState(_CascadePickerState state) {
    _state = state;
  }

  List<TreeNode> get selectedItems => _state._selectedTabs;

  List<int> get selectedIndexes => _state._selectedIndexes;

  bool isCompleted() => !_state._selectedTabs.contains(_CascadePickerState._newTabName);
}
