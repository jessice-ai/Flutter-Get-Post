import 'package:flutter/material.dart';
import 'package:flutter_alibc/alibc_const_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:flutter_alibc/flutter_alibc.dart';

class sunMy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return FirstScreenSon();
  }
}

class FirstScreenSon extends State with SingleTickerProviderStateMixin {
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
  String _dataLoading = "数据加载中";
  Map _sonDataU = {};

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

  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    initFromCache().then((result) {
      this._sunUserID = result;
      print("用户ID:${result}");
      if (this._sunUserID != null) {
        _sunGetSonGoodsList();
        _sunGetUserData();
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
  _sunGetUserData()async{
    Map sunJsonData = {"uid": _sunUserID};
    print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/udata",
        // ignore: missing_return
        data: sunJsonData).then((value){
        if(mounted){
          setState(() {
            _sonDataU = value.data["data"];
          });
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

  /// APP会员中心推荐优惠券
  _sunGetSonGoodsList() async {
    if (mounted) {
      setState(() {
        this.sunLoginStatus == false;
        isLoading = true;
        this._dataLoading = "数据加载中";
      });
    }
    if (isReflash == true) {
      this._sunPage = 1;
    }
    Map sunJsonData = {"uid": _sunUserID, "page": _sunPage};
    print("参数:${sunJsonData}");

    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/getucou",
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
        } else {
          //上拉加载新数据
          if (mounted) {
            setState(() {
              isLoading = false;
              //isReflash == false;
              //this._couponData = sunResponse.data['data'];
              this._sonFavoritesList.addAll(value.data['data']);
            });
          }
        }
        // setState(() {
        //   _sonProductsList = value.data["data"];
        // });
        //print("dddd ${_sonProductsList}");
      } else {
        //_sunToast("没有了");
        if (mounted) {
          setState(() {
            _sunPage--;
            _dataLoading = "我是有底线的";
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
    this._sunGetUserData();
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
                _sonFavoritesList[index]["pict_url"],
                fit: BoxFit.cover,
              ),
              onTap: () {
                //命名路由传值给详情页
                Navigator.pushNamed(context, '/sunproductcontent',
                    arguments: {"contentId": _sonFavoritesList[index]["item_id"]});
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
                      child: Text(_sonFavoritesList[index]["Favorites"]==1?"已收藏":"收藏",
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
    // return Container(
    //   color: Colors.teal.withAlpha(200),
    //   child: Center(child: Text("Click on FAB to Open Drawer",style: TextStyle(fontSize: 20,color: Colors.white),),),
    // );
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("个人中心"),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.teal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 100.0,
                            height: 100.0,
                            //装饰背景
                            decoration: BoxDecoration(
                                //背景颜色设置为蓝色
                                //color: Colors.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        "https://www.shsun.xyz/images/logo.jpg"),
                                    fit: BoxFit.cover)),
                            //alignment:Alignment.center, //设置图片在Container容器中的位置
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "个人信息",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      )),

                  //预估收益
                  _sonDataU.length>0?
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 60.0,
                            child: ListView(
                              children: [
                                Container(
                                  height: 30.0,
                                  child: Center(
                                    child: Text("总收益"),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red,
                                    //border: Border.all(color: Colors.red, width: 1)
                                  ),
                                  child: Text("${_sonDataU["Allrevenue"]}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.yellowAccent,
                                        //letterSpacing: 1, //字母间隙
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ), //设置行间距
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 60.0,
                            child: ListView(
                              children: [
                                Container(
                                  height: 30.0,
                                  child: Center(
                                    child: Text("本月收益"),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red,
                                    //border: Border.all(color: Colors.red, width: 1)
                                  ),
                                  child: Text("${_sonDataU["MouthThisdata"]}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.yellowAccent,
                                        //letterSpacing: 1, //字母间隙
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ), //设置行间距
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 60.0,
                            child: ListView(
                              children: [
                                Container(
                                  height: 30.0,
                                  child: Center(
                                    child: Text("上月收益"),
                                  ),
                                ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.red,
                                  //border: Border.all(color: Colors.red, width: 1)
                                ),
                                child: Text("${_sonDataU["LastThisdata"]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.yellowAccent,
                                      //letterSpacing: 1, //字母间隙
                                    )),
                              ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ):Container(),
                  //基本信息
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            // ListTile(
                            //   onTap: (){
                            //     debugPrint("Tapped Profile");
                            //   },
                            //   leading: Icon(Icons.person),
                            //   title: Text(
                            //     "Your Profile",
                            //   ),
                            // ),
                            // Divider(
                            //   height: 1,
                            //   color: Colors.grey,
                            // ),
                            ListTile(
                              // onTap: () {
                              //   //命名路由跳转到某个页面
                              //   Navigator.pushNamed(context, '/sunRecord');
                              // },
                              //leading: Icon(Icons.add_comment_rounded),
                              title: Text("每月22号,预估总收益自动转入可提现额度",style: TextStyle(fontSize: 12.0,color: Colors.red)),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            _sonDataU.length>0?
                            ListTile(
                              leading: Icon(Icons.account_balance_wallet),
                              title: Row(
                                children: [
                                  Text("可提现额度:"),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                                    child: Text(
                                      "${_sonDataU["available_quota"]}",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  Text("元"),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  FlatButton(
                                      color: Colors.redAccent,
                                      textColor: Colors.white,
                                      child: Text("提现"),
                                      //侦听点击事件
                                      onPressed: (){
                                        if(double.parse(_sonDataU["available_quota"])<10){
                                          _sunToast("可提现额度最低10元人民币");
                                          return;
                                        }
                                        _sunGetAlipay();//获取用户支付宝信息
                                      }
                                  )
                                ],
                              ),
                            ):Container(),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            ListTile(
                              onTap: () {
                                //命名路由跳转到某个页面
                                Navigator.pushNamed(context, '/sunRecord');
                              },
                              leading: Icon(Icons.account_balance_outlined),
                              title: Text("提现记录"),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            ListTile(
                              onTap: () {
                                //命名路由跳转到某个页面
                                Navigator.pushNamed(context, '/sunBreakdown');
                              },
                              leading: Icon(Icons.list),
                              title: Text("收入明细"),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            ListTile(
                              onTap: () {
                                //命名路由跳转到某个页面
                                Navigator.pushNamed(context, '/sunTeam');
                                //debugPrint("我的团队");
                              },
                              leading: Icon(Icons.category),
                              title: Text("我的团队"),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            ListTile(
                              onTap: () {
                                //命名路由跳转到某个页面
                                Navigator.pushNamed(context, '/sunRecei');
                              },
                              leading: Icon(Icons.payment),
                              title: Text("收款账号"),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            ListTile(
                              onTap: () {
                                debugPrint("规则说明");
                              },
                              leading: Icon(Icons.notifications),
                              title: Text("规则说明"),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            ListTile(
                              onTap: () {
                                //命名路由跳转到某个页面
                                Navigator.pushNamed(context, '/setting');
                              },
                              leading: Icon(Icons.settings),
                              title: Text("设置"),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),

                          ],
                        ),
                      ),
                      //猜你喜欢
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 25.0, 0, 10.0),
                        child: Center(
                          child: Text("猜你喜欢"),
                        ),
                      ),
                      //Divider(height: 1.0,color: Colors.black12,), //线条
                      Container(
                          color: Colors.white,
                          //height: 600.0,
                          width: double.infinity,
                          //强制container撑满整个屏幕
                          alignment: Alignment.center,
                          child: this._sonFavoritesList.length>0?GridView.builder(
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
                              childAspectRatio: 0.53, //宽度与高度的比例，通过这个比例设置相应高度
                            ),
                            itemCount: _sonFavoritesList.length,
                            //指定循环的数量
                            itemBuilder: (BuildContext context, int index) {
                              //如果循环到最后一个宝贝，显示加载图标
                              return this._getData(context, index);
                            },
                            //controller: _scrollController,
                          ):Container(),
                      )
                    ],
                  ), //底部加载提示
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
        ),
      );

  }
  //获取用户支付宝信息
  _sunGetAlipay() async {
    Map sunJsonData = {"uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/getAlipay",
        // ignore: missing_return
        data: sunJsonData)
    // ignore: missing_return
        .then((value) {
      if (value.data['code'] == 200) {
        var alipay_name = value.data['data']["alipay_name"];
        var alipay_account = value.data['data']["alipay_account"];
        if(alipay_name=="" || alipay_name==null || alipay_account=="" || alipay_account==null){
          _sunToast("请填写收款账号");
          //命名路由跳转到某个页面
          Navigator.pushNamed(context, '/sunRecei');
        }
        _sunPutAlipay();

      }
    });
  }
  //提现记录登记
  _sunPutAlipay()async{
    Map sunJsonData = {"uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/insertrecord",
        // ignore: missing_return
        data: sunJsonData).then((value){
      if (value.data['code'] == 200) {
        if(mounted){
          setState(() {
            _sonDataU["available_quota"] = "0";
          });
        }
        _sunToast("提现成功!");
        //命名路由跳转到某个页面
        Navigator.pushNamed(context, '/sunRecord'); //跳转到提现记录列表
      }else{
        _sunToast("提现失败!");
      }
    });
  }
}
