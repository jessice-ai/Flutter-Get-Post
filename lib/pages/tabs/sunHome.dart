import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'sunDataSearch.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class sunHome extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     //throw UnimplementedError();
//     /**
//      *  一般我们会使用 MaterialApp() 作为Flutter的一个根组件使用
//      *  常用属性：
//      *  home 主页
//      *  title 标题
//      *  color 颜色
//      *  theme 主题
//      *  routes 路由
//      */
//     return MaterialApp(
//       home: Scaffold(
//         //appBar 导航
//         //body 主体
//         body: sunHomeContent(),
//       ),
//       //theme 主体
//       theme: ThemeData(primarySwatch: Colors.amber //修改主体颜色
//           ),
//     );
//   }
// }

/**
 * StatelessWidget 无状态组件
 * StatefulWidget 有状态组件，点击页面脚本出发页面数据发生变化
 */
//说明：使用TabControllers实现顶部tab切换,必须使用动态组件,也就是 StatefulWiget
class sunHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    //这里不能直接返回组件，因为返回的数据类型是 State<StatefulWidget>
    return sunHomeContentState();
  }
}

class sunHomeContentState extends State with SingleTickerProviderStateMixin {
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  TabController _tabController;
  ScrollController _scrollController = new ScrollController();
  List _couponCate = [];
  List _couponData = [];
  List _secondaryCouponCate = []; //二级分类
  int _couponCateId = 0; //栏目ID
  int _sunPage = 1;
  bool isLoading = false;
  bool isReflash = false;
  int _sunUserID;
  bool sunLoginStatus = false;

  //dispose生命周期函数
  //dispose 当组件销毁时，触发的生命周期函数
  @override
  // ignore: must_call_super
  void dispose() {
    super.dispose();
    _scrollController.dispose(); //销魂滚动控件
    _tabController.dispose(); //把它自己销毁
  }

//获取用户登陆数据
  void initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    this._sunUserID = intValue;
    this.sunLoginStatus = true;
    //intValue = 0;
    if (intValue != "" && intValue != null) {
      this._sunUserID = intValue;
    }
  }

  //Dio Post实现网络请求 优惠券
  _sunDioPostData({catid: 0}) async {
    //print("ddd ${this.sunLoginStatus}");
    //先处理完读取用户登陆状态值
    if (this.sunLoginStatus == true) {
      if (!isLoading) {
        if (mounted) {
          setState(() {
            this.sunLoginStatus == false;
            isLoading = true;
          });
        }
        var sunDio = Dio();
        Response sunResponse;
        //print("栏目ID:${catid}");
        if (isReflash == true) {
          this._sunPage = 1;
        }
        Map sunJsonData = {
          "catid": catid,
          "uid": this._sunUserID,
          "page": _sunPage
        };
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
        print("返回数据:${sunResponse}");
        print("${isReflash}");
        if (sunResponse.data['code'] == 200) {
          //print(sunResponse.data['data']);
          print("isReflash:${isReflash}");
          if (isReflash == true) {
            //下拉刷新重置数组
            if (mounted) {
              setState(() {
                this._couponData = sunResponse.data['data'];
                isLoading = false;
                isReflash = false;
              });
            }
            //print("重置完${isReflash}");
            //print("优惠券数组重置，现在有:${_couponData.length} 条数据");
          } else {
            //上拉加载新数据
            if (mounted) {
              setState(() {
                isLoading = false;
                //isReflash == false;
                //this._couponData = sunResponse.data['data'];
                this._couponData.addAll(sunResponse.data['data']);
              });
            }
            //print("优惠券数组增加，现在有:${_couponData.length} 条数据");
          }
        } else {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          //_sunToast("${sunResponse.data['message']}");
          //没有数据时清空数组
          // setState(() {
          //   this._couponData = [];
          // });

        }
      }
    }
    //print(_couponData);
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
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
      if (mounted) {
        setState(() {
          this._couponCate = sunResponse.data['data'];
        });
      }

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
        if (mounted) {
          setState(() {
            this._sunTabIndex = index;
            this._couponCateId = this._couponCate[index]['id'];
            _sunDioPostData(catid: _couponCateId);
            _sunSecondaryColumn(catid: _couponCateId); //根据栏目ID,获取二级分类
            //print("栏目ID:${this._couponCate[index]['id']}");
          });
        }
      });
    } else {
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
  }

  _sunSecondaryColumn({catid = 0}) async {
    Map sunJsonData = {"catid": catid, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "http://192.168.9.45:8083/tbcouponseconday/cat",
        data: sunJsonData);
    if (sunResponse.data['code'] == 200) {
      //print("数据:${sunResponse.data['data']}");
      if (mounted) {
        setState(() {
          this._secondaryCouponCate = sunResponse.data['data'];
        });
      }
      //print("${this._secondaryCouponCate}");
    } else {
      if (mounted) {
        setState(() {
          this._secondaryCouponCate = [];
        });
      }
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
              //给图增加水波纹效果，并使用期点击事件
              InkWell(
                child: Image.network(
                  _couponData[index]["pict_url"],
                  fit: BoxFit.cover,
                ),
                onTap: (){
                  //命名路由传值给详情页
                  Navigator.pushNamed(
                      context,
                      '/sunproductcontent',
                      arguments: {
                        "contentId":_couponData[index]["id"]
                      });
                },
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
  }

//二级分类结构
  Widget _getSecondaryColumn(context, index) {
    var tabIndex = this._sunTabIndex;
    //print("Jessice:A ${_secondaryCouponCate[index]}");
    if (tabIndex == 0) {
      return Container();
    } else {
      if (_secondaryCouponCate.isNotEmpty) {
        return Container(
          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
          alignment: Alignment.center,
          //Column() 组件会竖向铺，但是不会横向自适应铺满；ListView() 横向自动铺满
          child: ListView(
            shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
            physics: NeverScrollableScrollPhysics(), //禁用滑动事件
            children: <Widget>[
              Container(
                height: 20.0,
                child: Image.network(
                  _secondaryCouponCate[index]["cat_image"],
                  fit: BoxFit.cover,
                ),
              ),
              //设置一个空白的高度，方式1
              // Container(
              //   height: 10,
              // ),
              //设置一个空白的高度，方式1，建议
              SizedBox(
                height: 5,
              ),
              Container(
                height: 50.0,
                child: Text(
                  _secondaryCouponCate[index]["name"],
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1, //字母间隙
                  ),
                ),
              )
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
    initFromCache(); //验证用户是否登陆
    // TODO: implement build
    //throw UnimplementedError();
    /**
     * 因数据异步远程获取
     * 顾判断是必须做的，否则会报错
     */
    //print("${this._couponCate}");
    if (this._couponCate.length != 0) {
      return Scaffold(
        appBar: AppBar(
          //title: searchInput(),
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
              label: Text("搜索"),
              color: Colors.white, //背景颜色
              onPressed: () {
                showSearch(context: context, delegate: sunDataSearch());
              },
              icon: Icon(
                Icons.search,
              ),
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
              //print(_secondaryCouponCate.length);
              if (e["count_coupons"] > 0) {
                //SingleChildScrollView 可滚动
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              color: Colors.white,
                              child: this._secondaryCouponCate.length > 0
                                  ? GridView.count(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 10),
                                      //指定循环的数量
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      crossAxisCount: 5,
                                      childAspectRatio: 1,
                                      children: this
                                                  ._secondaryCouponCate
                                                  .length >
                                              0
                                          ? this._secondaryCouponCate.map((e) {
                                              return SingleChildScrollView(
                                                child: Container(
                                                  color: Colors.white,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Column(
                                                        children: [
                                                          InkWell(
                                                            child:
                                                                Image.network(
                                                              e["cat_image"],
                                                              height: 50.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            onTap: (){
                                                              //命名路由传值跳转到栏目列表页
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/suncatlist',
                                                                  arguments: {
                                                                    "catid":
                                                                    e["id"],
                                                                    "name": e[
                                                                    "name"]
                                                                  });
                                                            },
                                                          ),
                                                          ListTile(
                                                            //leading: Icon(icon),
                                                            title: Transform
                                                                .translate(
                                                              offset: Offset(
                                                                  0, -17),
                                                              child: Text(
                                                                  e["name"],
                                                                  style: TextStyle(
                                                                      fontSize: 11.0,
                                                                      //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                                                      color: Colors.black87 //颜色使用Colors组件，设置系统自带的颜色
                                                                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                                                      )),
                                                            ),
                                                            onTap: () {
                                                              //print("栏目ID:${e["id"]}");
                                                              //命名路由传值给栏目列表页
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/suncatlist',
                                                                  arguments: {
                                                                    "catid":
                                                                        e["id"],
                                                                    "name": e[
                                                                        "name"]
                                                                  });
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList()
                                          : [],
                                    )
                                  : Container(),
                            ),
                            //Divider(height: 1.0,color: Colors.black12,), //线条
                            Container(
                                color: Colors.white,
                                //height: 600.0,
                                width: double.infinity,
                                //强制container撑满整个屏幕
                                alignment: Alignment.center,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(10),
                                  //使用padding 把上下左右留出空白距离
                                  //SliverGridDelegateWithFixedCrossAxisCount 这个单词比较长，用的时候拷贝下就好
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 10.0, //左右两个之间距离
                                    mainAxisSpacing: 5.0, //上下两个之间距离
                                    crossAxisCount: 2, //列数2
                                    childAspectRatio:
                                        0.75, //宽度与高度的比例，通过这个比例设置相应高度
                                  ),
                                  itemCount: _couponData.length + 1,
                                  //指定循环的数量
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    //如果循环到最后一个宝贝，显示加载图标
                                    if (index == _couponData.length) {
                                      return _buildProgressIndicator();
                                    } else {
                                      return this._getData(context, index);
                                    }
                                  },
                                  //controller: _scrollController,
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
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
        gravity: ToastGravity.CENTER,
        //提示信息展示位置
        timeInSecForIos: 3,
        //显示时间，这个只在IOS上有效，android 是默认时间
        backgroundColor: Colors.black,
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
        //onSelected: on_so_type_MenuSelection,
        child: Container(
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search,
                color: Colors.grey[800],
              ),
              // Text(
              //   _list_so_type[so_type],
              //   style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              // ),
            ],
          ),
          margin: EdgeInsets.only(left: 8),
        ),
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<int>>[
            // PopupMenuItem<int>(
            //     value: 0,
            //     child: Row(children: [
            //       Icon(Icons.favorite_border, color: Colors.deepOrange),
            //       SizedBox(
            //         width: 8,
            //       ),
            //       Text('宝贝'),
            //     ])),
            // PopupMenuItem<int>(
            //     value: 1,
            //     child: Row(children: [
            //       Icon(
            //         Icons.person,
            //         color: Colors.green,
            //       ),
            //       SizedBox(
            //         width: 8,
            //       ),
            //       Text('用户')
            //     ])),
          ];
        });
  }

  int so_type = 0; // 搜索类型
  on_so_type_MenuSelection(int v) {
    //更新 搜索类型选择 状态
    if (mounted) {
      setState(() {
        so_type = v;
      });
    }
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
              onTap: () {
                showSearch(context: context, delegate: sunDataSearch());
              },
              //autofocus: true,
              decoration: new InputDecoration.collapsed(
                  hintText: " 请输入搜索内容...",
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
