import 'package:flutter/material.dart';
import 'package:flutter_alibc/alibc_const_key.dart';
import 'package:flutter_app/pages/tabs/sunDataSearch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:flutter_alibc/flutter_alibc.dart';

class sunCategoriesList extends StatefulWidget {
  final arguments;

  sunCategoriesList({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunCategoriesListSon(arguments: this.arguments);
  }
}

class sunCategoriesListSon extends State with SingleTickerProviderStateMixin {
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  Map arguments;
  int _sunSonCatid = 0;
  int _sunTopCatid;
  bool isLoading = false;
  ScrollController _scrollController = new ScrollController();
  bool isReflash = false;
  int _sunPage = 1;
  String _sunName;
  int _tabSunControllerInt = 0;
  int _sunUserID;
  List _sonCategoryData = [];
  List _sonProductsList = [];
  TabController _tabController;
  int _sunIndex = 0;
  String _dataLoading = "Loading...";
  bool sunLoginStatus = false;
  var _dataLoadingData = "Loading...";

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

  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    _sunTopCatid = this.arguments["catid"];
    _sunSonCatid = this.arguments["soncatid"] != null
        ? this.arguments["soncatid"]
        : 0; //默认进来是全部
    _sunName = this.arguments["name"];
    _tabSunControllerInt = this.arguments["_tabSunControllerInt"];
    initFromCache().then((result) {
      this._sunUserID = result;
      print("用户ID:${result}");
      if (this._sunUserID != null) {
        _getSonCategory();
        _sunGetSonGoodsList();
      }
    });
    /**
     * 侦听滚动事件
     */
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        this._sunPage++;
        this._sunGetSonGoodsList();
      }
    });
  }

  // ignore: must_call_super
  void dispose() {
    super.dispose();
    _scrollController.dispose(); //销魂滚动控件
    _tabController.dispose(); //把它自己销毁
  }

  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    //print("${intValue}");
    if (intValue != "" && intValue != null) {
      return intValue;
    } else {
      //用户登陆
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }

  //获取子分类
  _getSonCategory() async {
    Map sunJsonData = {"catid": this.arguments["catid"], "uid": _sunUserID};
    //print("参数sun:${sunJsonData}");

    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/getcategory",
            // ignore: missing_return
            data: sunJsonData)
        // ignore: missing_return
        .then((value) {
      if (value.data['code'] == 200) {
        if (mounted) {
          setState(() {
            _sonCategoryData = value.data['data'];
          });
        }

        // print("${_sonCategoryData.length}条");
        _tabController =
            TabController(length: _sonCategoryData.length, vsync: this);

        // ignore: unnecessary_statements
        //print("传过来的值:${this.arguments["_tabSunControllerInt"]}");
        if (this._tabSunControllerInt != 0) {
          _tabController.index = this._tabSunControllerInt;
          this._tabSunControllerInt = 0;
        }

        _tabController.addListener(() {
          //Tab发生变化，Page=1
          _dataLoading = "";
          this._sunPage = 1;
          //当Tab发生变化，优惠券数组重置
          this._sonProductsList = [];
          //打印选中项索引值

          var index = _tabController.index;
          if (mounted) {
            setState(() {
              this._sunTabIndex = index;
              _sunSonCatid = _sonCategoryData[index]["id"]; //子栏目ID
            });
          }
          //print("第 ${_sunIndex} 个选项");
          print("第 ${_sonCategoryData[_sunIndex]["name"]} 项,内容");
          _sunGetSonGoodsList();
          // setState(() {
          //   _sunName = _sonCategoryData[_sunIndex]["name"];
          // });
        });
        //print(_sonCategoryData);
      }
    });
  }

  _sunGetUserTaobaoauthPost(String nick, String topAccessToken) async {
    Map sunJsonData = {
      "uid": _sunUserID,
      "nick": nick,
      "topAccessToken": topAccessToken
    };
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/getItb",
            // ignore: missing_return
            data: sunJsonData)
        .then((value) {
      if (value.data["code"] == 200) {
        _sunToast("授权成功!");
      } else {
        _sunToast("授权失败!");
      }
    });
  }

  /// 获取二级栏目下商品信息
  _sunGetSonGoodsList() async {
    if (mounted) {
      setState(() {
        this.sunLoginStatus == false;
        isLoading = true;
        _dataLoadingData = "数据加载中";
      });
    }
    if (isReflash == true) {
      this._sunPage = 1;
    }
    Map sunJsonData = {
      "topcatid": _sunTopCatid,
      "uid": _sunUserID,
      "sunSonCatid": _sunSonCatid,
      "page": _sunPage
    };
    print("参数:${sunJsonData}");

    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/getsongoods",
            // ignore: missing_return
            data: sunJsonData)
        // ignore: missing_return
        .then((value) {
      //print("返回数据:${value}");
      // _sonProductsList = [];
      if (value.data['code'] == 200) {
        if (isReflash == true) {
          //下拉刷新重置数组
          if (mounted) {
            setState(() {
              this._sonProductsList = value.data['data'];
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
              this._sonProductsList.addAll(value.data['data']);
            });
          }
        }
        // setState(() {
        //   _sonProductsList = value.data["data"];
        // });
        //print("dddd ${_sonProductsList}");
      } else {
        if (mounted) {
          setState(() {
            _sunPage--;
            _dataLoadingData = "没有数据";
            _dataLoading = "没有数据";
            isLoading = false;
          });
        }
      }
    });
  }

  sunCategoriesListSon({this.arguments});

  //下拉刷新，函数
  Future<void> _onRefresh() async {
    //print('执行刷新');
    isReflash = true;
    //刷新数据
    this._sunGetSonGoodsList();
    //给3秒刷新数据时间

    await Future.delayed(Duration(seconds: 3), () {
      //print('refresh');
    });
  }

  var _sunTabIndex = 0;

  _sunGetUserTaobaoauth({prourl}) async {
    Map sunJsonData = {"uid": _sunUserID};
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/getUsertb",
            // ignore: missing_return
            data: sunJsonData)
        // ignore: missing_return
        .then((value) async {
      //print("打印${value.data}");
      if (value.data["code"] == 300) {
        //没有授权过
        await FlutterAlibc.initAlibc(appName: "白羽电商导购", version: "1.0.0+1")
            .then((value) async {
          var result = await FlutterAlibc.loginTaoBao();
          // print(
          //     "登录淘宝  ${result.data.nick} ${result.data.topAccessToken}");
          _sunGetUserTaobaoauthPost(
              result.data.nick, result.data.topAccessToken);
        });

        // print("ddddddd-------${value}");
      } else if (value.data["code"] == 400) {
        //用户未登录
        _sunToast("请先登陆!");
      } else if (value.data["code"] == 200) {
        //print(this._sunContentData[0]['url']);
        //有授权过
        await FlutterAlibc.initAlibc(appName: "白羽电商导购", version: "1.0.0+1")
            .then((value) async {
          //print(this._sunContentData[0]['url']);
          var result = await FlutterAlibc.openByUrl(
              url: prourl,
              //backUrl: "tbopen27822502:https://h5.m.taobao.com",
              openType: AlibcOpenType.AlibcOpenTypeAuto,
              isNeedCustomNativeFailMode: true,
              nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
        });

        //print(result);
      } else {
        //其他错误
      }
    });
  }
  int _sunFavoritesStatus = 0;
  //客户收藏宝贝
  _sunFavoritesGoods({contentID = 0}) async {
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"contentID": contentID, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "https://www.shsun.xyz/tbcouponseconday/Cobaby",
        data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      setState(() {
        _sunFavoritesStatus = 1;
      });
    }else if(sunResponse.data['code'] == 300){
      setState(() {
        _sunFavoritesStatus = 0;
      });
    }
    _sunToast("${sunResponse.data['message']}");
  }
  //优惠券结构
  Widget _getData(context, index) {
    var tabIndex = this._sunTabIndex;
    //print("Jessice:A ${tabIndex}");
    if (_sonProductsList.isNotEmpty) {
      var _sunCoPrice = _sonProductsList[index]["zk_final_price"] -
          _sonProductsList[index]["coupon_amount"];
      _sunCoPrice = _sunCoPrice.toStringAsFixed(1);
      var price = _sunCoPrice.toString();
      String xaint;
      String xbint;
      List xaintarr = price.split('.');
      if (xaintarr.length > 1) {
        //print("有小数点:${xaintarr}");
        xaint = xaintarr[0];
        xbint = xaintarr[1];
      } else {
        //print("没有小数点:${xaintarr}");
        xaint = xaintarr[0];
        xbint = "0";
      }
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
                _sonProductsList[index]["pict_url"],
                fit: BoxFit.cover,
              ),
              onTap: () {
                //命名路由传值给详情页
                Navigator.pushNamed(context, '/sunproductcontent',
                    arguments: {"contentId": _sonProductsList[index]["id"]});
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
              _sonProductsList[index]["title"],
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis, //溢出之后显示三个点
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1, //字母间隙
              ),
            ),
            // Padding(padding: EdgeInsets.fromLTRB(0, 3, 0, 0)),
            // Container(
            //   width: 50.0,
            //   padding: EdgeInsets.all(5),
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(5),
            //       border: Border.all(color: Colors.red, width: 1)),
            //   child: Text("券${_sonProductsList[index]["coupon_amount"]}元",
            //       style: TextStyle(
            //         fontSize: 14,
            //         color: Colors.red,
            //         //letterSpacing: 1, //字母间隙
            //       )),
            // ),
            Padding(padding: EdgeInsets.fromLTRB(0, 3, 0, 0)),
            Row(
              children: [
                Expanded(
                  flex:2,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red,
                      //border: Border.all(color: Colors.red, width: 1)
                    ),
                    child: Text("优惠券${_sonProductsList[index]["coupon_amount"]}元",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.yellowAccent,
                          //letterSpacing: 1, //字母间隙
                        )),
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  flex:1,
                  child: InkWell(
                    child: Container(
                      width: 10.0,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.cyan, width: 1)),
                      child: Text(_sonProductsList[index]["Favorites"]==1?"取消":"收藏",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            //letterSpacing: 1, //字母间隙
                          )),
                    ),
                    onTap: (){
                      if(mounted){
                        setState(() {
                          _sonProductsList[index]["Favorites"]=_sonProductsList[index]["Favorites"]==1?2:1;
                        });
                      }
                      _sunFavoritesGoods(contentID: _sonProductsList[index]["id"]);
                    },
                  ),
                )
              ],
            ),

            Row(
              children: [
                Text(
                  "券后 ￥ ",
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontFamily: 'DMSans',
                    //letterSpacing: 1, //字母间隙
                  ),
                ),
                xaint != "0"
                    ? Text(
                        "${xaint}",
                        maxLines: 2,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.bold
                            //letterSpacing: 1, //字母间隙
                            ),
                      )
                    : Center(),
                xbint != "0"
                    ? Column(
                        children: [
                          Padding(padding: EdgeInsets.fromLTRB(0, 3, 0, 0)),
                          Text(
                            ".${xbint}",
                            maxLines: 2,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.bold
                                //letterSpacing: 1, //字母间隙
                                ),
                          )
                        ],
                      )
                    : Center(),
                Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                Text(
                  " ￥",
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'DMSans',
                    color: Colors.grey,
                    //letterSpacing: 1, //字母间隙
                  ),
                ),
                Text(
                  " ${_sonProductsList[index]["reserve_price"]}",
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'DMSans',
                    decoration: TextDecoration.lineThrough, //删除线
                    color: Colors.grey,
                    //letterSpacing: 1, //字母间隙
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              ],
            ),
            Text(
              "已售${_sonProductsList[index]["volume"]}件",
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis, //溢出之后显示三个点
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'DMSans',
                color: Colors.grey,
                //letterSpacing: 1, //字母间隙
              ),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          //border: Border.all(color: Colors.red, width: 1),//边框
                          //border: Border.all(color: Colors.white, width: 1),//边框
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(
                            //圆角
                            Radius.circular(5.0),
                          )
                          //borderRadius: BorderRadius.horizontal(left: Radius.circular(70.0),right: Radius.circular(0.0)), //左侧半圆，右侧不变
                          ),
                      alignment: Alignment.center,
                      child: Text(
                        "分享赚${_sonProductsList[index]["estimated_New"]}元",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          //letterSpacing: 1, //字母间隙
                          //fontWeight: FontWeight.bold, //加粗
                          //fontStyle: FontStyle.italic, //倾斜
                          //decoration: TextDecoration.lineThrough, //删除线
                          //decorationColor:Colors.deepOrange,//删除线颜色
                          //decorationStyle: TextDecorationStyle.dashed, //删除线改成虚线
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/sunshar',
                          arguments: {"contentId": _sonProductsList[index]["id"]});
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(0, 10, 5, 10)),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          //border: Border.all(color: Colors.red, width: 1),//边框
                          //border: Border.all(color: Colors.red, width: 1),//边框
                          borderRadius: BorderRadius.all(
                            //圆角
                            Radius.circular(5.0),
                          )
                          //borderRadius: BorderRadius.horizontal(left: Radius.circular(0.0),right: Radius.circular(70.0)), //左侧半圆，右侧不变
                          ),
                      alignment: Alignment.center,
                      child: Text(
                        "自购得${_sonProductsList[index]["estimated_New"]}元",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          //letterSpacing: 1, //字母间隙
                          //fontWeight: FontWeight.bold, //加粗
                          //fontStyle: FontStyle.italic, //倾斜
                          //decoration: TextDecoration.lineThrough, //删除线
                          //decorationColor:Colors.deepOrange,//删除线颜色
                          //decorationStyle: TextDecorationStyle.dashed, //删除线改成虚线
                        ),
                      ),
                    ),
                    onTap: () async {
                      _sunGetUserTaobaoauth(
                          prourl: _sonProductsList[index]["coupon_share_url"]);
                    },
                  ),
                )
              ],
            )
          ],
        ),
        //Container 边框
        decoration: BoxDecoration(
            //border: Border.all(color:Colors.black26,width: 1)
            ),
      );
    } else {
      return Container(
        child: Center(
          child: Text("${_dataLoading}"),
        ),
      );
    }
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

  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    if (_sonCategoryData.length > 0) {
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("${_sunName}"),
          ),
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
            tabs: this._sonCategoryData.map((value) {
              return Tab(
                text: "${value['name']}",
                //icon: Icon(Icons.directions_bike),
              );
            }).toList(),
          ),
          actions: <Widget>[
            new Container(
                child: FlatButton.icon(
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
          children: this._sonCategoryData.map((e) {
            //print("长度: ${_sonProductsList.length}");
            if (this._sonProductsList.length > 0) {
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
                                      0.53, //宽度与高度的比例，通过这个比例设置相应高度
                                ),
                                itemCount: _sonProductsList.length,
                                //指定循环的数量
                                itemBuilder:
                                    // ignore: missing_return
                                    (BuildContext context, int index) {
                                  return this._getData(context, index);
                                },
                                //controller: _scrollController,
                              ))
                        ],
                      ),
                      //底部加载提示
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 10.0, 0, 40.0),
                          child: Center(
                            child: Text("${_dataLoadingData}"),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Container(
                child: Center(
                  child: Text("${_dataLoadingData}"),
                ),
              );
            }
          }).toList(),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text("${_sunName}"),
          ),
          body: Center(
            child: Text("${_dataLoading}"),
          ));
    }
  }
}
