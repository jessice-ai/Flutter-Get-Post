import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/pages/tabs/sunDataSearch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sunCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State with SingleTickerProviderStateMixin {
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  bool sunLoginStatus = false;

  //String nextPage = "https://pixabay.com/api/?key=17946669-543fe6c4c313739ab33b63515&q=yellow+flowers&image_type=photo&pretty=true";

  ScrollController _scrollController = new ScrollController();
  var _catimg = "";
  bool isLoading = false;
  int _sunUserID;
  List names = new List();
  final dio = new Dio();
  List _couponCate = [];
  int _tabindex = 6;
  var _sunTabColors;
  List _secondaryCouponCate = []; //二级分类
  List _sonCate = [];
  TabController _tabController;
  String _sunLoadingData = "Loading...";

  //获取用户登陆数据
  void initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    this._sunUserID = intValue;
    this.sunLoginStatus = true;
    //intValue = 0;
    // ignore: unrelated_type_equality_checks
    if (intValue != "" && intValue != null) {
      this._sunUserID = intValue;
      _sunSecondaryColumn(catid: 6);  //初始化热门推荐
    } else {
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }

  // void _getMoreData() async {
  //   if (!isLoading) {
  //     if(mounted){
  //       setState(() {
  //         isLoading = true;
  //       });
  //     }
  //
  //
  //     final response = await dio.get(nextPage);
  //
  //     //nextPage = response.data['totalHits'];
  //     if(mounted){
  //       setState(() {
  //         isLoading = false;
  //         names.addAll(response.data['hits']);
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    initFromCache();

    //this._getMoreData();
    this._sunDioPostCateData(); //所有分类
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //_getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

//获取二级分类
  _sunSecondaryColumn({catid = 0}) async {
    Map sunJsonData = {"catid": catid, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("http://39.98.92.36/tbcouponseconday/secla",
            // ignore: missing_return
            data: sunJsonData)
        // ignore: missing_return
        .then((value) {
      if (value.data['code'] == 200) {
        //print("数据:${sunResponse.data['data']}");
        if (mounted) {
          setState(() {
            this._secondaryCouponCate = value.data['data'];
          });
        }
        //print("${this._secondaryCouponCate}");
      } else {
        if (mounted) {
          setState(() {
            _sunLoadingData = "暂时没有数据";
            this._secondaryCouponCate = [];
          });
        }
        //_sunToast("${value.data['message']}");
      }
    });
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

  Widget _buildList() {
    return ListView.builder(
//+1 for progressbar
      itemCount: names.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == names.length) {
          return _buildProgressIndicator();
        } else {
          return new ListTile(
            title: Text((names[index]['tags'])),
            onTap: () {
              //print(names[index]);
            },
          );
        }
      },
      controller: _scrollController,
    );
  }

  //下拉刷新，函数
  Future<void> _onRefresh() async {
    //print('执行刷新');
    //刷新数据
    //this._getData();
    //给3秒刷新数据时间
    await Future.delayed(Duration(seconds: 3), () {
      //print('refresh');
    });
  }

  //Dio Post实现网络请求:分类
  _sunDioPostCateData() async {
    var sunDio = Dio();
    Response sunResponse =
        await sunDio.post("http://39.98.92.36/tbcouponapi/cat");
    if (sunResponse.data['code'] == 200) {
      //print(sunResponse.data['data']);
      if (mounted) {
        setState(() {
          this._couponCate = sunResponse.data['data'];
        });
      }
    } else {
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
  }

//优惠券结构
  Widget _getData(context, index) {
    //var tabIndex = this._sunTabIndex;
    //print("Jessice:A ${tabIndex}");
    if (_secondaryCouponCate.isNotEmpty) {
      return Container(
        alignment: Alignment.center,
        //Column() 组件会竖向铺，但是不会横向自适应铺满；ListView() 横向自动铺满
        child: ListView(
          shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
          physics: NeverScrollableScrollPhysics(), //禁用滑动事件

          children: <Widget>[
            Image.network(
              _secondaryCouponCate[index]["small_images"],
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
              "标题",
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

    //print("${_couponData[tabIndex]["data"][index]["small_images"]}");
  }

  //按钮背景颜色
  _sunTabColorsfunc({colors}) {
    if (colors == _tabindex) {
      return Colors.white;
    } else {
      return Colors.black12;
    }
  }

  _getSoncatList({listdata}) {
    // for(var i=0;i<listdata.length;i++){
    //   return Container(
    //     child: Text(listdata["name"]),
    //   );
    // }
    listdata.forEach((element) {
      return Column(
        children: [Text(element["name"])],
      );
    });
  }

  //下拉刷新Body内部内容，效果一
  @override
  Widget build(BuildContext context) {
    //double maxWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("分类"),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  children: this._couponCate.map((value) {
                    return InkWell(
                      child: Column(
                        children: [
                          Container(
                            height: 48.0,
                            alignment: Alignment.center,
                            color: _sunTabColorsfunc(colors: value['id']),
                            child: Text(
                              "${value['name']}",
                            ),
                          ),
                          Divider(
                            height: 1.0,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                      onTap: () {
                        //print("${value['id']}");
                        _sunSecondaryColumn(catid: value['id']);
                        if(mounted){
                          setState(() {
                            _tabindex = value['id'];
                          });
                        }

                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                height: double.infinity, //添加这行，可填充满高度
                child: SingleChildScrollView(
                    child: Container(
                      width: double.maxFinite, //如果要填充高度， 写 height: double.maxFinite
                      //height: double.maxFinite,
                      alignment: Alignment.topLeft,
                      color: Colors.white,
                      child: Column(
                        children: [
                          //Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
                          Container(
                            //height: 800.0,
                            color: Colors.white,
                            width: double.infinity,
                            //color: Colors.blue,
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              spacing: 5, //主轴上子控件的间距
                              runSpacing: 5, //交叉轴上子控件之间的间距
                              children: this._secondaryCouponCate.length > 0
                                  ? this._secondaryCouponCate.map((value) {
                                //print(_secondaryCouponCate);
                                _sonCate = value["son"];
                                //print(_sonCate);
                                return Column(
                                  children: [
                                    Padding(
                                        padding:
                                        EdgeInsets.fromLTRB(10, 0, 0, 20)),
                                    Container(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width, //宽度占满屏幕
                                      child: InkWell(
                                        child: Text("${value["name"]}",
                                            style: TextStyle(
                                              //color: Colors.white,
                                              fontSize: 16,
                                              //fontWeight: FontWeight.bold,
                                            )),
                                        onTap: () {
                                          if (value["name"] != "热门推荐") {
                                            //命名路由传值跳转到栏目列表页
                                            Navigator.pushNamed(
                                                context, '/suncatlist',
                                                arguments: {
                                                  "catid": value["id"],
                                                  "name": value["name"],
                                                  "_tabSunControllerInt": 0
                                                });
                                          }
                                        },
                                      ),
                                      padding:
                                      EdgeInsets.fromLTRB(25, 0, 0, 20),
                                    ),
                                    Wrap(
                                      spacing: 10, //主轴上子控件的间距
                                      //runSpacing: 10, //交叉轴上子控件之间的间距
                                      children: _sonCate.length > 0
                                          ? _sonCate.map((e) {
                                        var index =
                                            _sonCate.indexOf(e) + 1;
                                        if (value["name"] == "热门推荐") {
                                          index = 0;
                                        }
                                        //print(index);
                                        // if(e["cat_image"]!=null){
                                        //   _catimg = e["cat_image"];
                                        // }else{
                                        //   _catimg = "https://img-blog.csdnimg.cn/20201014180756927.png?x-oss-process=image/resize,m_fixed,h_64,w_64";
                                        // }
                                        // print("jessice ${_catimg}");
                                        return Container(
                                          width: 90.0,
                                          height: 140,
                                          alignment: Alignment.center,
                                          // decoration: BoxDecoration(
                                          //   gradient: LinearGradient(colors: [
                                          //     Colors.orangeAccent,
                                          //     Colors.orange,
                                          //     Colors.deepOrange
                                          //   ]),
                                          // ),
                                          child: Column(
                                            children: [
                                              InkWell(
                                                child: Image.network(
                                                  "https://img-blog.csdnimg.cn/20201014180756927.png?x-oss-process=image/resize,m_fixed,h_64,w_64",
                                                  height: 90.0,
                                                  fit: BoxFit.cover,
                                                ),
                                                onTap: () {
                                                  // print(
                                                  //     "栏目ID:${e['pid']}");

                                                  //命名路由传值跳转到栏目列表页
                                                  Navigator.pushNamed(
                                                      context,
                                                      '/suncatlist',
                                                      arguments: {
                                                        "catid": e["pid"],
                                                        "name":
                                                        value["name"],
                                                        "soncatid":
                                                        e["id"],
                                                        "_tabSunControllerInt":
                                                        index
                                                      });
                                                },
                                              ),
                                              Padding(
                                                  padding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 10, 0, 0)),
                                              InkWell(
                                                child: Text(
                                                  "${e["name"]}",
                                                  style: TextStyle(
                                                    //color: Colors.white,
                                                    fontSize: 14,
                                                    //fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onTap: () {
                                                  //命名路由传值跳转到栏目列表页
                                                  Navigator.pushNamed(
                                                      context,
                                                      '/suncatlist',
                                                      arguments: {
                                                        "catid": e["pid"],
                                                        "name":
                                                        value["name"],
                                                        "soncatid":
                                                        e["id"],
                                                        "_tabSunControllerInt":
                                                        index
                                                      });
                                                },
                                              ),

                                              //Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5)),
                                            ],
                                          ),
                                        );
                                      }).toList()
                                          : [], //要显示的子控件集合
                                    )
                                  ],
                                );
                              }).toList()
                                  : [
                                Container(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width, //宽度占满屏幕
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.white,
                                  child: Center(
                                    child: Text("${_sunLoadingData}"),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
      // body: Container(
      //   child: RefreshIndicator(
      //     onRefresh: _onRefresh,
      //     child:_buildList(),
      //   ),
      // ),
      resizeToAvoidBottomPadding: false,
    );
  }
//下拉刷新整个 Scaffold，效果二
// @override
// Widget build(BuildContext context) {
//   return RefreshIndicator(
//     onRefresh: _onRefresh,
//     child: Scaffold(
//       appBar: AppBar(
//         title: const Text("Pagination"),
//       ),
//       body: Container(
//         child: _buildList(),
//       ),
//       resizeToAvoidBottomPadding: false,
//     ),
//   );
//
// }
}
