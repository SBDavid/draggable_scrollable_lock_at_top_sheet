import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:draggable_scrollable_lock_at_top_sheet/draggable_scrollable_lock_at_top_sheet.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // 导航栏颜色
  Color appBarColor = Colors.blue.withOpacity(0);
  // 当前页码
  int currentPageNum = 3;
  int pageSize = 10;
  static const double PIC_HEIGHT = 200;
  // 列表项
  List<int> items;

  @override
  void initState() {
    super.initState();
    items = [1,1,1,1,1,1,1,1,1,1];
  }

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
                      return currentPageNum != 0;
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
