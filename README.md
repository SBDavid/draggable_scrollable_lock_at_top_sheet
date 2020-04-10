# draggable_scrollable_lock_at_top_sheet

增强版flutter DraggableScrollableSheet，增强点：
- 滚动区域可以锁定在maxChildSize位置，例如下载加载上一页的时候。
- 可拖拽扩大，原始的版本是能在ScrollView上执行拖拽，增强后可以在任意位置上拖拽。

## 运行Demo
<img src="https://raw.githubusercontent.com/SBDavid/draggable_scrollable_lock_at_top_sheet/master/gif/demo.gif" width="270" height="480" alt="图片名称">

- 克隆代码到本地: git clone git@github.com:SBDavid/draggable_scrollable_lock_at_top_sheet.git
- 切换工作路径: cd draggable_scrollable_lock_at_top_sheet/example/
- 启动模拟器
- 运行: flutter run

## 使用文档
### 1. 安装

```yaml
dependencies:
  draggable_scrollable_lock_at_top_sheet: ^1.0.0
```

### 2. 引用插件
```dart
import 'package:draggable_scrollable_lock_at_top_sheet/draggable_scrollable_lock_at_top_sheet.dart';
```

### 3. 使用组件

在原始的`DraggableScrollableSheet`的基础增加了`shouldLockAtTop`接口，用于判断是否需要锁定在顶部。

```dart
class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: RaisedButton(
              child: Text("这个区域可以出发点击事件 当前页码：$currentPageNum"),
              onPressed: () {
                print("当前页码：$currentPageNum");
              },
            ),
          ),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {

                // 计算顶部图片应该保留的空间
                double minChildSize = (constraints.maxHeight - PIC_HEIGHT) / constraints.maxHeight;

                return NotificationListener(
                  onNotification: (Notification notification) {
                    if (notification is DraggableScrollableLockAtTopNotification) {
                      // 调整appbar颜色
                      appBarColor = appBarColor.withAlpha(((notification.extent-notification.minExtent)/(notification.maxExtent - notification.minExtent) * 255).ceil());
                      setState(() {

                      });
                    }
                    return false;
                  },
                  child: DraggableScrollableSheetLockAtTop(
                    minChildSize: minChildSize,
                    maxChildSize: 1,
                    initialChildSize: minChildSize,
                    // 判断是否加载到第一页
                    shouldLockAtTop: () {
                      return true;
                    },
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Column(
                        children: <Widget>[
                          Container(
                            color: Colors.red,
                            height: 80,
                            width: double.infinity,
                            child: Text("这里可以拖动，滑动到最上会触发锁定，刷新到第一页可以解锁，滑动红色区域也可以解锁"),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.indigo,
                              child: CustomScrollView(
                                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                controller: scrollController,
                                slivers: <Widget>[
                                  // 下拉加载更多，可以使用别的方式加载更多，这里只做演示。
                                  CupertinoSliverRefreshControl(
                                    onRefresh: () async {
                                      Future.delayed(Duration(seconds: 1), () async {
                                        if (currentPageNum > 0) {
                                          currentPageNum--;
                                          for(int i=0; i<pageSize; i++) {
                                            items.insert(0, 1);
                                          }
                                        }
                                        setState(() {

                                        });
                                      });
                                    },
                                  ),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                          return ListTile(title: Text('Item $index'));
                                        },
                                        childCount: items.length
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                );
              }
          )
        ],
      )
    );
  }
}

```