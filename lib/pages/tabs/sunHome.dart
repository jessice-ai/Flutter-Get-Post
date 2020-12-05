import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'sunDataSearch.dart';

class sunHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    /**
     *  一般我们会使用 MaterialApp() 作为Flutter的一个根组件使用
     *  常用属性：
     *  home 主页
     *  title 标题
     *  color 颜色
     *  theme 主题
     *  routes 路由
     */
    return MaterialApp(
      home: Scaffold(
        //appBar 导航
        //body 主体
        body: sunHomeContent(),
      ),
      //theme 主体
      theme: ThemeData(primarySwatch: Colors.amber //修改主体颜色
          ),
    );
  }
}

/**
 * StatelessWidget 无状态组件
 * StatefulWidget 有状态组件，点击页面脚本出发页面数据发生变化
 */
//说明：使用TabControllers实现顶部tab切换,必须使用动态组件,也就是 StatefulWiget
class sunHomeContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    //这里不能直接返回组件，因为返回的数据类型是 State<StatefulWidget>
    return sunHomeContentState();
  }
}

class sunHomeContentState extends State with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollController = new ScrollController();
  List _couponCate = [];
  List _couponData = [];
  int _couponCateId = 0; //栏目ID
  int _sunPage = 1;
  bool isLoading = false;
  bool isReflash = false;

  //dispose生命周期函数
  //dispose 当组件销毁时，触发的生命周期函数
  @override
  // ignore: must_call_super
  void dispose() {
    super.dispose();
    _scrollController.dispose(); //销魂滚动控件
    _tabController.dispose(); //把它自己销毁
  }

  //Dio Post实现网络请求 优惠券
  _sunDioPostData({catid: 0}) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var sunDio = Dio();
      Response sunResponse;
      //print("栏目ID:${catid}");
      Map sunJsonData = {"catid": catid, "uid": 1, "page": _sunPage};
      print("POST值: ${sunJsonData}");
      sunResponse = await sunDio.post(
          "http://192.168.9.45:8083/tbcouponapi/index",
          data: sunJsonData);

      // if(catid!=0){
      //    sunResponse =
      //   await sunDio.post("http://192.168.9.45:8083/tbcouponapi/index",data: sunJsonData);
      // }else{
      //    sunResponse =
      //   await sunDio.post("http://192.168.9.45:8083/tbcouponapi/index");
      // }
      // print("返回数据:${sunResponse.data['code']}");

      if (sunResponse.data['code'] == 200) {
        //print(sunResponse.data['data']);
        if(isReflash==true){
          //下拉刷新重置数组
            isReflash == false;
          this._couponData = sunResponse.data['data'];
        }else{
          //上拉加载新数据
          setState(() {
            isLoading = false;
            //this._couponData = sunResponse.data['data'];
            this._couponData.addAll(sunResponse.data['data']);
          });
        }

        print("优惠券有几条数据:${_couponData.length}");
      } else {
        setState(() {
          isLoading = false;
        });
        //没有数据时清空数组
        // setState(() {
        //   this._couponData = [];
        // });
        //_sunToast("网络请求异常! ${sunResponse.data['message']}");
      }
    }
    //print(_couponData);
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:  Center(
        child:  Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  //Dio Post实现网络请求:分类
  _sunDioPostCateData() async {
    var sunDio = Dio();
    Response sunResponse =
        await sunDio.post("http://192.168.9.45:8083/tbcouponapi/cat");
    if (sunResponse.data['code'] == 200) {
      //print(sunResponse.data['data']);
      setState(() {
        this._couponCate = sunResponse.data['data'];
      });

      _tabController = TabController(length: _couponCate.length, vsync: this);
      _tabController.addListener(() {
        //Tab发生变化，Page=1
        this._sunPage = 1;
        //当Tab发生变化，优惠券数组重置
        this._couponData = [];
        //打印选中项索引值
        var index = _tabController.index;
        //print("Jessice:BBBBBBBBB ${index}");
        //print("Jessice :${index}");
        //var MapDataCat = this._couponCate[index];
        //var catid = MapDataCat['id'];
        setState(() {
          this._sunTabIndex = index;
          this._couponCateId = this._couponCate[index]['id'];
          _sunDioPostData(catid: _couponCateId);
          //print("栏目ID:${this._couponCate[index]['id']}");
        });
      });
    } else {
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
  }

  var _sunTabIndex = 0;

  //优惠券结构
  Widget _getData(context, index) {
    var tabIndex = this._sunTabIndex;
    //print("Jessice:A ${tabIndex}");
      if (tabIndex == 0) {
        return Container();
      } else {
        if (_couponData.isNotEmpty) {
          return Container(
            alignment: Alignment.center,
            //Column() 组件会竖向铺，但是不会横向自适应铺满；ListView() 横向自动铺满
            child: ListView(
              shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
              physics: NeverScrollableScrollPhysics(), //禁用滑动事件

              children: <Widget>[
                Image.network(
                  _couponData[index]["small_images"],
                  fit: BoxFit.cover,
                ),
                //设置一个空白的高度，方式1
                // Container(
                //   height: 10,
                // ),
                //设置一个空白的高度，方式1，建议
                SizedBox(
                  height: 10,
                ),
                Text(
                  _couponData[index]["title"],
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1, //字母间隙
                  ),
                ),
              ],
            ),
            //Container 边框
            decoration: BoxDecoration(
                //border: Border.all(color:Colors.black26,width: 1)
                ),
          );
        } else {
          return Container();
        }
      }

    //print("${_couponData[tabIndex]["data"][index]["small_images"]}");
  }

  @override
  void initState() {
    super.initState();

    _sunDioPostData(); //获取优惠券
    _sunDioPostCateData(); //获取栏目
    /**
     * 侦听滚动事件
     */
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        this._sunPage++;
        _sunDioPostData(catid: _couponCateId);
      }
    });
  }

  //下拉刷新，函数
  Future<void> _onRefresh() async {
    //print('执行刷新');
    isReflash = true;
    //刷新数据
    this._sunDioPostData(catid: _couponCateId);
    //给3秒刷新数据时间

    await Future.delayed(Duration(seconds: 3), () {
      //print('refresh');
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    /**
     * 因数据异步远程获取
     * 顾判断是必须做的，否则会报错
     */
    if (this._couponCate.length != 0) {
      return Scaffold(
        appBar: AppBar(
          title: searchInput(),
          backgroundColor: Colors.white, //导航背景颜色
          // title: Text("分类"),
          bottom: TabBar(
            indicatorColor: Colors.red,
            isScrollable: true,
            //多Tab不叠加,滑动展示
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black87,
            controller: this._tabController,
            //注意，必须得加
            labelStyle: TextStyle(fontSize: 16.0),
            indicatorSize: TabBarIndicatorSize.label,
            //指示器大小计算方式，TabBarIndicatorSize.label 跟文 字等宽,TabBarIndicatorSize.tab 跟每个 tab 等宽
            tabs: this._couponCate.map((value) {
              return Tab(
                text: "${value['name']}",
                //icon: Icon(Icons.directions_bike),
              );
            }).toList(),
          ),
          actions: <Widget>[
            new Container(
                child: RaisedButton.icon(
              icon: Icon(
                Icons.search,
              ),
              label: Text("搜索"),
              color: Colors.white, //背景颜色
              onPressed: () {
                showSearch(context: context, delegate: sunDataSearch());
              },
            )),
          ],
        ),
        body: TabBarView(
          controller: this._tabController, //注意，必须得加
          children: this._couponCate.map((e) {
            if (_sunTabIndex == 0) {
              return Container(
                child: Text("首页视图内容"),
              );
            } else {
              //print(_couponData.length);
              if (e["count_coupons"] > 0) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Container(
                      child: GridView.builder(
                    padding: EdgeInsets.all(10),
                    //使用padding 把上下左右留出空白距离
                    //SliverGridDelegateWithFixedCrossAxisCount 这个单词比较长，用的时候拷贝下就好
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10.0, //左右两个之间距离
                      mainAxisSpacing: 5.0, //上下两个之间距离
                      crossAxisCount: 2, //列数2
                      childAspectRatio: 0.75, //宽度与高度的比例，通过这个比例设置相应高度
                    ),
                    itemCount: _couponData.length + 1,
                    //指定循环的数量
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _couponData.length) {
                        return _buildProgressIndicator();
                      }else{
                        return this._getData(context, index);
                      }
                    },
                    controller: _scrollController,
                  )),
                );
              } else {
                return Container(
                  child: Center(
                    child: Text("暂时没有数据..."),
                  ),
                );
              }
            }
          }).toList(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: Center(
            child: Text("数据加载中..."),
          ),
        ),
      );
    }
  }

  _sunToast(String message) {
    Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        //提示信息展示位置
        timeInSecForIos: 10,
        //显示时间，这个只在IOS上有效，android 是默认时间
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget _widget_PopupMenuButton() {
    // 弹出搜索类型选项
    return new PopupMenuButton<int>(
        //icon: Icon(Icons.arrow_drop_up,color: Colors.white,),
        offset: Offset(0, 30),
        padding: EdgeInsets.zero,
        //initialValue: _simpleValue,
        onSelected: on_so_type_MenuSelection,
        child: Container(
          child: Row(
            children: <Widget>[
              Text(
                _list_so_type[so_type],
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[800],
              ),
            ],
          ),
          margin: EdgeInsets.only(left: 8),
        ),
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
                value: 0,
                child: Row(children: [
                  Icon(Icons.favorite_border, color: Colors.deepOrange),
                  SizedBox(
                    width: 8,
                  ),
                  Text('宝贝'),
                ])),
            PopupMenuItem<int>(
                value: 1,
                child: Row(children: [
                  Icon(
                    Icons.person,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text('用户')
                ])),
          ];
        });
  }

  int so_type = 0; // 搜索类型
  on_so_type_MenuSelection(int v) {
    //更新 搜索类型选择 状态
    setState(() {
      so_type = v;
    });
  }

  final List<String> _list_so_type = ["宝贝", "店铺"];

  Widget searchInput() {
    // 搜索框
    return new Container(
      height: 35,
      child: new Row(
        children: <Widget>[
          _widget_PopupMenuButton(),
          new Expanded(
            child: new TextField(
              //autofocus: true,
              decoration: new InputDecoration.collapsed(
                  hintText: "请输入搜索内容...",
                  hintStyle: new TextStyle(color: Colors.grey[700])),
            ),
          )
        ],
      ),
      decoration: new BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(4)),
          color: Colors.grey[300]),
    );
  }
}
