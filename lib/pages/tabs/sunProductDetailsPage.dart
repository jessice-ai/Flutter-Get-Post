

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_alibc/alibc_const_key.dart';
import 'package:flutter_alibc/flutter_alibc.dart';


class sunProductDetailsPage extends StatefulWidget {
  final arguments;

  sunProductDetailsPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunProductDetailsPageSon(arguments: this.arguments);
  }
}

class sunProductDetailsPageSon extends State {
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  Map arguments;
  var _contentId;
  int _sunUserID;
  List _sunContentData = [];
  bool sunLoginStatus = false;
  List _sunSmallImage = [];
  int _sunFavoritesStatus = 0;
  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    // ignore: unrelated_type_equality_checks
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
      //print("用户ID:${result}");
      _contentId = this.arguments["contentId"];
      _sunGetGoodsDetail(contentID: _contentId).then((result) {
        //print(result);
        setState(() {
          this._sunContentData = result;
          _sunFavoritesStatus = result[0]['collectionsStatus']; //更新收藏状态
        });
      });
    });
  }

  sunProductDetailsPageSon({this.arguments});

  _sunGetGoodsDetail({contentID = 0}) async {
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"contentID": contentID, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "http://www.shsun.xyz/tbcouponseconday/content",
        data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      return sunResponse.data['data'];
      //print("${this._secondaryCouponCate}");
    } else {
      return [];
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
  }

  _sunGetUserTaobaoauth({itemid}) async{
    Map sunJsonData = {"uid": _sunUserID};
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "http://www.shsun.xyz/tbcouponseconday/getUsertb",
        // ignore: missing_return
        data: sunJsonData).then((value) async {
          print("打印${value.data}");
          if(value.data["code"]==300) {
            //没有授权过
            FlutterAlibc.loginOut();
            await FlutterAlibc.initAlibc(appName: "夜市优惠券",version: "1.0.0+1").then((value) async {
              await FlutterAlibc.loginTaoBao().then((value) async{
                Navigator.pushNamed(context, '/sunTb');
              });
            });
          }else if(value.data["code"]==400){
            //print("用户未登录");
            //用户未登录
            _sunToast("请先登陆!");
          }else if(value.data["code"]==200){

            await FlutterAlibc.initAlibc(appName: "夜市优惠券",version: "1.0.0+1").then((dee) async {
              //print(this._sunContentData[0]['url']);
              //APP内部打开网页
              Map _sunTrackParam = {
                "relationId":value.data["data"]
              };
              //链接客户的渠道关系ID
              var result = await FlutterAlibc.openByUrl(
                  url:this._sunContentData[0]['coupon_share_url']+"&relationId=${value.data["data"]}",
                  //backUrl: "tbopen27822502:https://h5.m.taobao.com",
                  openType : AlibcOpenType.AlibcOpenTypeAuto,
                  isNeedCustomNativeFailMode: true,
                  nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
                  schemeType : AlibcSchemeType.AlibcSchemeTaoBao,
                  //backUrl:"",
              );
              //唤起淘宝APP客户端

              // print(_sunTrackParam);
              // var result = await FlutterAlibc.openItemDetail(
              //   itemID:itemid,	//必须参数
              //   openType : AlibcOpenType.AlibcOpenTypeAuto,
              //   isNeedCustomNativeFailMode : false,
              //   nativeFailMode :    AlibcNativeFailMode.AlibcNativeFailModeNone,
              //   schemeType : AlibcSchemeType.AlibcSchemeTaoBao,
              //   //taokeParams : {},
              //   trackParam : _sunTrackParam, //需要额外追踪的业务数据
              //   backUrl:"",
              // );
              // print(result);
            });
            //print(result);
          }else{
            //其他错误
          }
    });

  }
  _sunGetUserTaobaoauthPost(String nick,String topAccessToken) async {
    Map sunJsonData = {"uid": _sunUserID,"nick":nick,"topAccessToken":topAccessToken};
    print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "http://www.shsun.xyz/tbcouponseconday/getItb",
        // ignore: missing_return
        data: sunJsonData).then((value){
          if(value.data["code"]==200){
            print("${value.data["data"]}");
            _sunToast("授权成功!");
          }else{
            _sunToast("授权失败!");
          }
    });

  }
  //客户收藏宝贝
  _sunFavoritesGoods({contentID = 0}) async {
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"contentID": contentID, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "http://www.shsun.xyz/tbcouponseconday/Cobaby",
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    if (this._sunContentData.length > 0) {
      String small_images = this._sunContentData[0]['small_images'];
      _sunSmallImage = json.decode(small_images);
      //print("${this._sunContentData[0]}");
      //print("${this._sunSmallImage.length} 张图片");
      var _sunCoPrice = _sunContentData[0]["zk_final_price"]-_sunContentData[0]["coupon_amount"];
      return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          //backgroundColor: Colors.white.withOpacity(0.1),
          elevation: 0,
          // title: Text("aaa"),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      child: Swiper(
                        itemBuilder: _swiperBuilder,
                        itemCount: this._sunSmallImage.length,
                        //pagination 控制底部分页器是否显示,注释掉不显示，不注释则显示
                        pagination: SwiperPagination(
                            builder: DotSwiperPaginationBuilder(
                          color: Colors.black54,
                          activeColor: Colors.redAccent,
                        )),
                        //control: new SwiperControl(), //控制左右箭头是否显示,注释掉不显示，不注释则显示
                        scrollDirection: Axis.horizontal,
                        //autoplay: true,
                        onTap: (index) => print('点击了第$index个'),
                      )),
                  Column(
                    children: [
                      //价格栏
                      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Container(
                        height: 46.0,
                        alignment: Alignment.center,
                        //color: Colors.red,
                        child: Container(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0)),
                                    Text("¥",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                            color: Colors
                                                .red //颜色使用Colors组件，设置系统自带的颜色
                                            //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                            )),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(1, 0, 0, 0)),
                                    Text(
                                        "${_sunCoPrice}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            //加粗
                                            fontSize: 24.0,
                                            //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                            color: Colors
                                                .red //颜色使用Colors组件，设置系统自带的颜色
                                            //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                            )),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 0, 0)),
                                    Text("起",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                            color: Colors
                                                .red //颜色使用Colors组件，设置系统自带的颜色
                                            //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                            )),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 0, 0)),
                                    Text(
                                        "¥${this._sunContentData[0]['reserve_price']}",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                          decoration:
                                              TextDecoration.lineThrough, //删除线
                                          //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                        ))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          "已售件${this._sunContentData[0]['volume']}件"),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 10, 0)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //标题栏
                      new Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "${this._sunContentData[0]["title"]}",
                          style: TextStyle(
                            fontSize:
                                16.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                            //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                          ),
                          softWrap: true,
                        ),
                      ),

                      //商品详情
                      Container(
                          child: this._sunSmallImage.length > 0
                              ? ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  children: this._sunSmallImage.map((value) {
                                    return Image.network("${value['url']}");
                                  }).toList())
                              : Text("加载中")),
                      //底部定位
                    ],
                  ),

                ],
              ),
            ),
            //底部固定
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 66.0,
                color: Colors.white,
                child: Container(
                  decoration: ShapeDecoration(
                      //border: Border.all(color:Colors.black26,width: 1), //加边框
                      //四个边框分别对应粗细宽度
                      shape: Border(
                          top: BorderSide(
                              color: Colors.black12,
                              style: BorderStyle.solid,
                              width: 1),
                          bottom: BorderSide(
                              color: Colors.black12,
                              style: BorderStyle.solid,
                              width: 0),
                          right: BorderSide(
                              color: Colors.black12,
                              style: BorderStyle.solid,
                              width: 0),
                          left: BorderSide(
                              color: Colors.black12,
                              style: BorderStyle.solid,
                              width: 0))),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 4, 0, 0)),
                                Icon(
                                  Icons.home,
                                  color: Colors.black,
                                ),
                                Text(
                                  "首页",
                                  style: TextStyle(fontSize: 12.0),
                                )
                              ],
                            ),
                            onTap: () {
                              //命名路由传值跳转到首页
                              Navigator.pushNamed(context, '/sunTags');
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 4, 0, 0)),
                                _sunFavoritesStatus==1?Icon(
                                  Icons.favorite, //实心
                                  //Icons.favorite_border 空心 Icons.favorite 实心
                                  color: Colors.red,
                                ):Icon(
                                  Icons.favorite_border, //空心
                                  //Icons.favorite_border 空心 Icons.favorite 实心
                                  color: Colors.black,
                                )
                                ,
                                Text("收藏", style: TextStyle(fontSize: 12.0))
                              ],
                            ),
                            onTap: () {
                              _sunFavoritesGoods(contentID: _sunContentData[0]["id"]);
                            },
                          ),
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0)),
                        Expanded(
                          flex: 3,
                          child:InkWell(
                            child: Container(
                              height: 38.0,
                              decoration: BoxDecoration(
                                //border: Border.all(color: Colors.red, width: 1),//边框
                                //border: Border.all(color: Colors.white, width: 1),//边框
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(
                                    //圆角
                                    Radius.circular(66.0),
                                  )
                                //borderRadius: BorderRadius.horizontal(left: Radius.circular(70.0),right: Radius.circular(0.0)), //左侧半圆，右侧不变
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "分享赚2元",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  letterSpacing: 2, //字母间隙
                                  //fontWeight: FontWeight.bold, //加粗
                                  //fontStyle: FontStyle.italic, //倾斜
                                  //decoration: TextDecoration.lineThrough, //删除线
                                  //decorationColor:Colors.deepOrange,//删除线颜色
                                  //decorationStyle: TextDecorationStyle.dashed, //删除线改成虚线
                                ),
                              ),
                            ),
                            onTap: (){
                              print("分享得");
                            },
                          ),


                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                        Expanded(
                          flex: 3,
                          child:InkWell(
                            child: Container(
                              height: 38.0,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  //border: Border.all(color: Colors.red, width: 1),//边框
                                  //border: Border.all(color: Colors.red, width: 1),//边框
                                  borderRadius: BorderRadius.all(
                                    //圆角
                                    Radius.circular(70.0),
                                  )
                                //borderRadius: BorderRadius.horizontal(left: Radius.circular(0.0),right: Radius.circular(70.0)), //左侧半圆，右侧不变
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "自购赚2元",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  letterSpacing: 2, //字母间隙
                                  //fontWeight: FontWeight.bold, //加粗
                                  //fontStyle: FontStyle.italic, //倾斜
                                  //decoration: TextDecoration.lineThrough, //删除线
                                  //decorationColor:Colors.deepOrange,//删除线颜色
                                  //decorationStyle: TextDecorationStyle.dashed, //删除线改成虚线
                                ),
                              ),
                            ),
                            onTap: () async {
                              _sunGetUserTaobaoauth(itemid: _sunContentData[0]["item_id"]);
                              // print("自购赚");

                            },
                          ),
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          child: Center(
            child: Text("加载中..."),
          ),
        ),
      );
    }
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return Image.network(
      this._sunSmallImage[index]['url'],
      fit: BoxFit.fill,
    );
  }
  _sunFavorites({goodsid=0}){
    if(goodsid!=0){

    }else{
      _sunToast("ID错误");
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
}

//自定义组件
class iconItemContent extends StatelessWidget {
  double size = 24.0;
  Color color = Colors.red;
  IconData icon;

  //{} 标识可选值
  iconItemContent(this.icon, {this.color, this.size}) {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    //ListView 列表组件
    return Container(
      width: 100,
      height: 100,
      color: this.color,
      child: Center(
        child: Icon(this.icon, size: this.size, color: Colors.white),
      ),
    );
  }
}
