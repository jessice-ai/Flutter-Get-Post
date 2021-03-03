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
import 'package:fluwx/fluwx.dart';




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
  ScrollController _scrollController = new ScrollController();
  Map arguments;
  var _contentId;
  int _sunUserID;
  int _sunPage = 1;
  List _sunContentData = [];
  bool sunLoginStatus = false;
  List _sunSmallImage = [];
  var _sunTabIndex = 0;
  bool isLoading = false;
  bool isReflash = false;
  int _sunFavoritesStatus = 0;
  String _sunWxurl = "";
  String _sunWxtitle = "";
  String _thumnail = "";
  int is_isset=1; //商品是否存在
  String _dataLoading = "Loading...";
  List _sonFavoritesList = [];

  /// WeChatScene.TIMELINE 分享到朋友圈
  /// WeChatScene.FAVORITE 添加到收藏
  /// WeChatScene.SESSION 回话

  WeChatScene scene = WeChatScene.SESSION;

  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    // ignore: unrelated_type_equality_checks
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
    _initFluwx();

    //验证用户登陆状态
    initFromCache().then((result) async {
      this._sunUserID = result;
      //print("用户ID:${result}");
      _contentId = this.arguments["contentId"];
      //print("aaaaaaaa-----${_contentId}");
      _sunGetSonGoodsList();
      _sunGetGoodsDetail(contentID: _contentId).then((result)  {
        //print(result);
        if(result[0]['is_isset']==2){
          //商品不存在
          if(mounted){
            setState(() {
              this.is_isset=2;
            });
          }
        }else{
          //商品存在
          setState(() {
            this._sunContentData = result;
            _sunFavoritesStatus = result[0]['collectionsStatus']; //更新收藏状态
          });
        }

      });

    });
    /**
     * 侦听滚动事件
     */
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        this._sunPage++;
        this._sunGetSonGoodsList();
        //print("aaa");
      }
    });
  }

  _initFluwx() async {
    await registerWxApi(
        appId: "wx648227e6e2238e14",
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: "https://www.shsun.xyz/");
    var result = await isWeChatInstalled;
    //print("is installed $result");
  }
  sunProductDetailsPageSon({this.arguments});

  _sunGetGoodsDetail({contentID = 0}) async {
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"item_id": contentID, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "https://www.shsun.xyz/tbcouponseconday/content",
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

  _sunGetUserTaobaoauth({itemid,status}) async {
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
        FlutterAlibc.loginOut();
        await FlutterAlibc.initAlibc(appName: "夜市优惠券", version: "1.0.0+1")
            .then((value) async {
          await FlutterAlibc.loginTaoBao().then((value) async {
            Navigator.pushNamed(context, '/sunTb');
          });
        });
      } else if (value.data["code"] == 400) {
        //print("用户未登录");
        //用户未登录
        _sunToast("请先登陆!");
      } else if (value.data["code"] == 200) {
        _sunSmallImage = json.decode(this._sunContentData[0]['small_images']);
        if(mounted){
          setState(() {
            _sunWxurl = this._sunContentData[0]['coupon_share_url'] +
                "&relationId=${value.data["data"]}";
            _thumnail = _sunSmallImage[0]["url"];
          });
        }
        if(status==2){
          //自购赚
          await FlutterAlibc.initAlibc(appName: "夜市优惠券", version: "1.0.0+1")
              .then((dee) async {
            //print(this._sunContentData[0]['url']);
            //APP内部打开网页
            Map _sunTrackParam = {"relationId": value.data["data"]};
            //链接客户的渠道关系ID
            var result = await FlutterAlibc.openByUrl(
              url: this._sunContentData[0]['coupon_share_url'] +
                  "&relationId=${value.data["data"]}",
              //backUrl: "tbopen27822502:https://h5.m.taobao.com",
              openType: AlibcOpenType.AlibcOpenTypeAuto,
              isNeedCustomNativeFailMode: true,
              nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeNone,
              schemeType: AlibcSchemeType.AlibcSchemeTaoBao,
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
        }else if(status==1){
          //分享得
          _share();
        }

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
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/getItb",
            // ignore: missing_return
            data: sunJsonData)
        // ignore: missing_return
        .then((value) {
      if (value.data["code"] == 200) {
        //print("${value.data["data"]}");
        _sunToast("授权成功!");
      } else {
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
        "https://www.shsun.xyz/tbcouponseconday/Cobaby",
        data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      setState(() {
        _sunFavoritesStatus = 1;
      });
    } else if (sunResponse.data['code'] == 300) {
      setState(() {
        _sunFavoritesStatus = 0;
      });
    }
    _sunToast("${sunResponse.data['message']}");
  }

  void _share() {
    int mstatus=2;
    //print(_sunWxurl);
    if(mstatus==1){
      //分享网页
      var model = WeChatShareWebPageModel(
        _sunWxurl,
        title: _sunWxtitle,
        thumbnail: WeChatImage.network(_thumnail),
        scene: scene,
      );
      shareToWeChat(model);
    }else if(mstatus==2){
      //分享图片
      var model = WeChatShareImageModel(
          WeChatImage.network(_thumnail),
        title: _sunWxtitle,
        description: "",
        scene: scene,
      );
      var model2 = WeChatShareImageModel(
        WeChatImage.network(_thumnail),
        title: _sunWxtitle,
        description: "",
        scene: scene,
      );
      shareToWeChat(model);
      shareToWeChat(model2);

    }

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
    //print("参数:${sunJsonData}");

    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/gsund",
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
  _sunGetUserTaobaoauthsun({prourl}) async {
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
                      _sunGetUserTaobaoauthsun(
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
  // ignore: must_call_super
  void dispose() {
    super.dispose();
    _scrollController.dispose(); //销魂滚动控件
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    if(this.is_isset==1){
      if (this._sunContentData.length > 0) {

        String small_images = this._sunContentData[0]['small_images'];
        _sunSmallImage = json.decode(small_images);
        //print("${this._sunContentData[0]}");
        //print("${this._sunSmallImage.length} 张图片");
        var _sunCoPrice = _sunContentData[0]["zk_final_price"] -
            _sunContentData[0]["coupon_amount"];
        _sunCoPrice = _sunCoPrice.toStringAsFixed(1);
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
                controller: _scrollController,
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
                                      Text("${_sunCoPrice}",
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
                    SizedBox(
                      height: 20.0,
                    ),
                    //猜你喜欢
                    Container(
                      child: Center(
                        child: Text("相似宝贝"),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                      child: Container(
                        color: Colors.white,
                        //height: 600.0,
                        width: double.infinity,
                        //强制container撑满整个屏幕
                        alignment: Alignment.center,
                        child: this._sonFavoritesList.length>0?GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          //padding: EdgeInsets.all(10),
                          //使用padding 把上下左右留出空白距离
                          //SliverGridDelegateWithFixedCrossAxisCount 这个单词比较长，用的时候拷贝下就好
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10.0, //左右两个之间距离
                            //mainAxisSpacing: 5.0, //上下两个之间距离
                            crossAxisCount: 2, //列数2
                            childAspectRatio: 0.53, //宽度与高度的比例，通过这个比例设置相应高度
                          ),
                          itemCount: _sonFavoritesList.length,
                          //指定循环的数量
                          itemBuilder: (BuildContext context, int index) {
                            //如果循环到最后一个宝贝，显示加载图标
                            return this._getData(context, index);
                          },
                          // controller: _scrollController,
                        ):Container(),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 10.0, 0, 40.0),
                        child: Center(
                          child: Text("${_dataLoading}"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 10.0),
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
                      EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
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
                                  _sunFavoritesStatus == 1
                                      ? Icon(
                                    Icons.favorite, //实心
                                    //Icons.favorite_border 空心 Icons.favorite 实心
                                    color: Colors.red,
                                  )
                                      : Icon(
                                    Icons.favorite_border, //空心
                                    //Icons.favorite_border 空心 Icons.favorite 实心
                                    color: Colors.black,
                                  ),
                                  Text("收藏", style: TextStyle(fontSize: 12.0))
                                ],
                              ),
                              onTap: () {
                                _sunFavoritesGoods(
                                    contentID: _sunContentData[0]["id"]);
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0)),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              child: Container(
                                height: 36.0,
                                decoration: BoxDecoration(
                                  //border: Border.all(color: Colors.red, width: 1),//边框
                                  //border: Border.all(color: Colors.white, width: 1),//边框
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.all(
                                      //圆角
                                      Radius.circular(10.0),
                                    )
                                  //borderRadius: BorderRadius.horizontal(left: Radius.circular(70.0),right: Radius.circular(0.0)), //左侧半圆，右侧不变
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "分享赚${_sunContentData[0]["estimated_New"]}元",
                                  style: TextStyle(
                                    fontSize: 14.0,
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
                              onTap: () {
                                Navigator.pushNamed(context, '/sunshar',
                                    arguments: {"contentId": _sunContentData[0]["id"]});
                                // _sunGetUserTaobaoauth(
                                //     itemid: _sunContentData[0]["item_id"],status: 1);
                                // _sunWxtitle = "${this._sunContentData[0]["title"]}";
                                //openWeChatApp();
                                //print("分享得");
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              child: Container(
                                height: 36.0,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    //border: Border.all(color: Colors.red, width: 1),//边框
                                    //border: Border.all(color: Colors.red, width: 1),//边框
                                    borderRadius: BorderRadius.all(
                                      //圆角
                                      Radius.circular(10.0),
                                    )
                                  //borderRadius: BorderRadius.horizontal(left: Radius.circular(0.0),right: Radius.circular(70.0)), //左侧半圆，右侧不变
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "自购得${_sunContentData[0]["estimated_New"]}元",
                                  style: TextStyle(
                                    fontSize: 14.0,
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
                                _sunGetUserTaobaoauth(
                                    itemid: _sunContentData[0]["item_id"],status: 2);
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
    }else{
      //商品不存在
      return Scaffold(
        body: Container(
          child: Center(
            child: Text("商品已被删除！"),
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

  _sunFavorites({goodsid = 0}) {
    if (goodsid != 0) {
    } else {
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
