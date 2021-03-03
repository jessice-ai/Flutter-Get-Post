
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/services.dart';
import 'package:flutter_alibc/alibc_const_key.dart';
import 'package:flutter_alibc/flutter_alibc.dart';

class sunPicture extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunPictureSon();
  }

}

class sunPictureSon extends State{
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  var sunFlag = true;
  int _sunPage = 1;
  int _sunUserID;
  bool isLoading = false;
  ScrollController _scrollController = new ScrollController();
  bool sunLoginStatus = false;
  List _sonFavoritesList = [];
  var _sunTabIndex = 0;
  bool isReflash = false;
  String _dataLoading = "Loading...";

  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    //print("${intValue}");
    if (intValue != "" && intValue != null) {
      return intValue;
    }else{
      //用户登陆
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }
  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    initFromCache().then((result) {
      this._sunUserID = result;
      print("用户ID:${result}");
      if (this._sunUserID != null) {
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
  /// 获取收藏商品信息
  _sunGetSonGoodsList() async {
    if (mounted) {
      setState(() {
        this.sunLoginStatus == false;
        isLoading = true;
        this._dataLoading="数据加载中";
      });
    }
    if (isReflash == true) {
      this._sunPage = 1;
    }
    Map sunJsonData = {
      "uid": _sunUserID,
      "page": _sunPage
    };
    print("参数:${sunJsonData}");

    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/CobabyList",
        // ignore: missing_return
        data: sunJsonData)
    // ignore: missing_return
        .then((value) {
      //print("返回数据:${value.data['code']}");
      // _sonProductsList = [];
      if (value.data['code'] == 200) {
        if (isReflash == true) {
          //下拉刷新重置数组
          if (mounted) {
            setState(() {
              this._sonFavoritesList = value.data['data'];
              isLoading = false;
              isReflash = false;
            });
          }
          //print("重置完${isReflash}");
          //print("优惠券数组重置，现在有:${_couponData.length} 条数据");
        }else{
          //上拉加载新数据
          if (mounted) {
            setState(() {
              isLoading = false;
              //isReflash == false;
              this._dataLoading="";
              //this._couponData = sunResponse.data['data'];
              this._sonFavoritesList.addAll(value.data['data']);
            });
          }
        }
        // setState(() {
        //   _sonProductsList = value.data["data"];
        // });
        //print("dddd ${_sonProductsList}");
      }else{
        //_sunToast("没有了");
        if (mounted) {
          setState(() {
            _sunPage--;
            _dataLoading = "没有更多数据";
            isLoading = false;
          });
        }
      }
    });
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
  // ignore: must_call_super
  void dispose() {
    super.dispose();
    _scrollController.dispose(); //销魂滚动控件
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
    if (_sonFavoritesList.isNotEmpty) {
      var _sunCoPrice = _sonFavoritesList[index]["zk_final_price"] -
          _sonFavoritesList[index]["coupon_amount"];
      _sunCoPrice = _sunCoPrice.toStringAsFixed(1);
      var price = _sunCoPrice.toString();
      //print(_sunCoPrice);
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
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        //Column() 组件会竖向铺，但是不会横向自适应铺满；ListView() 横向自动铺满
        child: ListView(
          shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
          physics: NeverScrollableScrollPhysics(), //禁用滑动事件
          children: <Widget>[
            //给图增加水波纹效果，并使用期点击事件
            InkWell(
              child: Image.network(
                _sonFavoritesList[index]["pict_url"],
                fit: BoxFit.cover,
              ),
              onTap: (){
                //命名路由传值给详情页
                Navigator.pushNamed(
                    context,
                    '/sunproductcontent',
                    arguments: {
                      "contentId":_sonFavoritesList[index]["item_id"]
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
              _sonFavoritesList[index]["title"],
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis, //溢出之后显示三个点
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1, //字母间隙
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex:2,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      //color: Colors.red,
                      border: Border.all(color: Colors.red, width: 1)
                    ),
                    child: Text("优惠券${_sonFavoritesList[index]["coupon_amount"]}元",
                        style: TextStyle(
                          fontSize: 12,
                          //color: Colors.yellowAccent,
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
                      child: Text(_sonFavoritesList[index]["Favorites"]==1?"收藏":"已收藏",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            //letterSpacing: 1, //字母间隙
                          )),
                    ),
                    onTap: (){
                      if(mounted){
                        setState(() {
                          _sonFavoritesList[index]["Favorites"]=_sonFavoritesList[index]["Favorites"]==1?2:1;
                        });
                      }
                      _sunFavoritesGoods(contentID: _sonFavoritesList[index]["id"]);
                    },
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  "券后 ￥",
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
                  "${_sonFavoritesList[index]["reserve_price"]}",
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 14,
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
              "已售${_sonFavoritesList[index]["volume"]}件",
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
                        "分享赚${_sonFavoritesList[index]["estimated_New"]}元",
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
                          arguments: {"contentId": _sonFavoritesList[index]["id"]});
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
                        "自购得${_sonFavoritesList[index]["estimated_New"]}元",
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
                          prourl: _sonFavoritesList[index]["coupon_share_url"]);
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
      return Container();
    }
  }
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
    // ignore: missing_return
        .then((value) {
      if (value.data["code"] == 200) {
        _sunToast("授权成功!");
      } else {
        _sunToast("授权失败!");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    //print(_sonFavoritesList.length);
    if(this._sonFavoritesList.length>0){
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("收藏"),
          ),
        ),
        body: RefreshIndicator(
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
                          itemCount: _sonFavoritesList.length,
                          //指定循环的数量
                          itemBuilder:
                              (BuildContext context, int index) {
                            //如果循环到最后一个宝贝，显示加载图标
                                return this._getData(context, index);
                          },
                          //controller: _scrollController,
                        ))
                  ],
                ),//底部加载提示
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 10.0, 0, 40.0),
                    child: Center(
                      child: Text("${_dataLoading}"),
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      );
    }else{
      return Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text("收藏"),
            ),
          ),
          body: Container(
            height: double.infinity,
            child: Center(
              child: Text("${_dataLoading}"),
            ),
          )
      );
    }

    // return Container(
    //   child: Padding(
    //     padding: EdgeInsets.all(20),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         FlatButton(
    //           child: Text("初始化阿里百川"),
    //           onPressed: () async {
    //             try {
    //               // var waite3s = await FlutterAlibc.openItemDetail(itemID: "12345");
    //               // 如果什么都不给
    //               var result = await FlutterAlibc.initAlibc(appName: "flutter_app",version: "1.0.0+1");
    //               print(result);
    //             } on Exception {}
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("登录淘宝"),
    //           onPressed: () async {
    //             var result = await FlutterAlibc.loginTaoBao();
    //             print(
    //                 "登录淘宝  ${result.data.nick} ${result.data.topAccessToken}");
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("登出淘宝"),
    //           onPressed: () {
    //             FlutterAlibc.loginOut();
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("淘客登录，二次授权"),
    //           onPressed: () async {
    //             var result = await FlutterAlibc.taoKeLogin(
    //                 url:
    //                 "https://oauth.taobao.com/authorize?response_type=token&client_id=27646673&state=1212&view=wap",
    //                 openType: AlibcOpenType.AlibcOpenTypeNative,
    //                 isNeedCustomNativeFailMode: true,
    //                 nativeFailMode:
    //                 AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
    //             print("access token ${result["accessToken"]}");
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("唤起淘宝，openByUrl方式"),
    //           onPressed: () async {
    //             var result = await FlutterAlibc.openByUrl(
    //                 url:
    //                 "https://uland.taobao.com/coupon/edetail?e=0I2EBL%2BTWswGQASttHIRqRXxIesJCFV0jSsDEwaP11URqogtr65NL3IIxArmwXZQtYdj3OrQBBwJkllDQLUC%2B79fwBwwUiqlvyfAqbG%2BQWkG6QT52O7rmXYefz8NXcoYTJnbK5InWzlFfSAQOJJoy8NEaV3mm%2FQSzjZt5gElMznom9kMiklcP0KJ92VgfYGd&traceId=0b0d82cf15669814548736276e3d95&union_lens=lensId:0b0b6466_0c0d_16cd75f7c39_528f&xId=6MboRwsAi2s8Glbqt3lJLAwSlyrPyBLCZ01KOk6QzKCNhw8C6RjXgA1bNbZdKzp30gOqd1J5j1k7ei7HYId1QZ&ut_sk=1.utdid_null_1566981455011.TaoPassword-Outside.taoketop&sp_tk=77+lTU5nMllrdHRqSVLvv6U=",
    //                 //backUrl: "tbopen27822502:https://h5.m.taobao.com",
    //                 isNeedCustomNativeFailMode: true,
    //                 nativeFailMode:
    //                 AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
    //             print(result);
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("唤起淘宝，openItemDetail方式"),
    //           onPressed: () async {
    //             var result = await FlutterAlibc.openItemDetail(
    //                 itemID: "575688730394",
    //                 schemeType: AlibcSchemeType.AlibcSchemeTaoBao,
    //                 isNeedCustomNativeFailMode: true,
    //                 nativeFailMode:
    //                 AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
    //             print(result);
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("打开店铺，openShop方式"),
    //           onPressed: () async {
    //             var result = await FlutterAlibc.openShop(shopId: "71955116");
    //             print(result);
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("打开购物车，openCart方式"),
    //           onPressed: () async {
    //             var result = await FlutterAlibc.openCart();
    //             print(result);
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("允许打点"),
    //           onPressed: () {
    //             FlutterAlibc.syncForTaoke(true);
    //           },
    //         ),
    //         FlatButton(
    //           child: Text("使用native Alipay"),
    //           onPressed: () {
    //             FlutterAlibc.useAlipayNative(true);
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

