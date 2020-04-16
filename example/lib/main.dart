import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:draggable_scrollable_lock_at_top_sheet/draggable_scrollable_lock_at_top_sheet.dart';
import 'package:flutter_sliver_tracker/flutter_sliver_tracker.dart';

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
  int currentPageNumUP = 10;
  int currentPageNumDown = 10;
  int pageSize = 10;
  int pageAmount = 20;
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
              child: Text("这个区域可以出发点击事件 当前页码：$currentPageNumUP / $currentPageNumDown"),
              onPressed: () {
                print("当前页码：$currentPageNumUP");
              },
            ),
          ),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {

                // 计算顶部图片应该保留的空间
                double minChildSize = (constraints.maxHeight - PIC_HEIGHT) / constraints.maxHeight;

                return NotificationListener(
                  onNotification: (Notification notification) {
                    print("notification $notification");
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
                      return currentPageNumUP != 1;
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
                              child: ScrollViewListener(
                                child: CustomScrollView(
                                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                  controller: scrollController,
                                  slivers: <Widget>[
                                    // 下拉加载更多，可以使用别的方式加载更多，这里只做演示。
                                    CupertinoSliverRefreshControl(
                                      onRefresh: () async {
                                        Future.delayed(Duration(seconds: 1), () async {
                                          if (currentPageNumUP > 1) {
                                            currentPageNumUP--;
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
                                            return ListTile(
                                                title: Text(
                                                    'Item $index',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 60
                                                  ),
                                                )
                                            );
                                          },
                                          childCount: items.length
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: SliverScrollListenerDebounce(
                                        notifyOnce: true,
                                        onScrollEnd: (double percent) {
                                          // 加载下一页
                                          Future.delayed(Duration(seconds: 1), () {
                                            if (currentPageNumDown < pageAmount) {
                                              currentPageNumDown++;
                                              for(int i=0; i<pageSize; i++) {
                                                items.add(1);
                                              }
                                              setState(() {

                                              });
                                            } else {
                                              print("到底了");
                                            }
                                          });
                                        },
                                        child: Container(
                                          color: Colors.lightBlue,
                                          height: 100,
                                          child: Center(
                                            child: Text("$currentPageNumDown / $pageAmount",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 60
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
