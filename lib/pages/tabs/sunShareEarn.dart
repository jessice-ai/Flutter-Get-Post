import 'package:flutter/material.dart';
import 'package:flutter_alibc/alibc_const_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fluwx/fluwx.dart';
import 'package:flutter_alibc/flutter_alibc.dart';

class sunShareEarn extends StatefulWidget {
  final arguments;

  sunShareEarn({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunShareEarnSon(arguments: this.arguments);
  }
}

class sunShareEarnSon extends State {
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  int _sunUserID;
  var _contentId;
  List _sunContentData = [];
  String _sunWxtitle = "";
  String _thumnail = "";
  Map arguments;
  WeChatScene scene = WeChatScene.SESSION;
  String _sunWxurl = "";
  int mstatus=1;

  sunShareEarnSon({this.arguments});

  String _keyword;
  List _sunSmallImage = [];

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
  _initFluwx() async {
    await registerWxApi(
        appId: "wx648227e6e2238e14",
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: "https://www.shsun.xyz/");
    var result = await isWeChatInstalled;
    //print("is installed $result");
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

      _sunGetGoodsDetail(contentID: _contentId).then((result) {
        //print(result);
        setState(() {
          this._sunContentData = result;
          var dkjf = result[0]["reserve_price"] - result[0]["coupon_amount"];
          var _sunCoPrice =
              result[0]["zk_final_price"] - result[0]["coupon_amount"];
          _sunCoPrice = _sunCoPrice.toStringAsFixed(1);
          _sunSmallImage = json.decode(result[0]['small_images']);
          _keyword =
              "${result[0]["title"]} \n原价 ${result[0]["reserve_price"]} \n抢购价 ${_sunCoPrice} \n淘口令 ${result[0]["password_simple"]}";
          //_keyword += "抢购价 "+result[0]["password_simple"];
        });
      });
    });
  }

  _sunGetGoodsDetail({contentID = 0}) async {
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"contentId": contentID, "uid": _sunUserID};
    print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/ordinance", data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      return sunResponse.data['data'];
      //print("${this._secondaryCouponCate}");
    } else {
      return [];
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
  }

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
            _sunWxtitle = _sunSmallImage[0]["title"];
          });
        }
        _share();
        //print(result);
      } else {
        //其他错误
      }
    });
  }

  void _share() {

    //print(_sunWxurl);
    if(mstatus==1){
      //分享图片,给好友
      scene = WeChatScene.SESSION; //回话
      var model = WeChatShareImageModel(
        WeChatImage.network(_thumnail),
        scene: scene,
      );
      shareToWeChat(model);
    }else if(mstatus==2){
      //分享到朋友圈
      scene = WeChatScene.TIMELINE; //回话
      var model = WeChatShareImageModel(
        WeChatImage.network(_thumnail),
        scene: scene,
      );
      shareToWeChat(model);

    }else if (mstatus==3){
      //分享网页
      // var model = WeChatShareWebPageModel(
      //   _sunWxurl,
      //   title: _sunWxtitle,
      //   thumbnail: WeChatImage.network(_thumnail),
      //   scene: scene,
      // );
      // shareToWeChat(model);
    }

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    if (this._sunContentData.length > 0) {
      print(_sunContentData);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("分享商品"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              flex:2,
              child: Container(
                decoration: BoxDecoration(
                  //背景颜色
                  color: Colors.white,
                  //这个圆角比较怪，记住就行了
                  borderRadius: BorderRadius.all(Radius.circular(15.0)), //圆角
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: Container(
                    width: double.infinity,
                    child: Text("分享赚￥1.98元，分享后不要忘记粘贴淘口令！"),
                  )
                ),
              ),
            ),
            SizedBox(height: 5.0,),
            Expanded(
              flex:8,
              child: Container(
                decoration: BoxDecoration(
                  //背景颜色
                  color: Colors.white,
                  //这个圆角比较怪，记住就行了
                  borderRadius: BorderRadius.all(Radius.circular(15.0)), //圆角
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child:Container(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              //背景颜色
                              color: Colors.white,
                              //这个圆角比较怪，记住就行了
                              borderRadius: BorderRadius.all(Radius.circular(15.0)), //圆角
                            ),
                            child: Container(
                              height: 150,
                              child: ListView(
                                children: this._sunSmallImage.length > 0
                                    ? _sunSmallImage.map((e) {
                                  return Container(
                                    width: 150.0,
                                    height: 150.0,
                                    // color: Colors.red,
                                    child: ListView(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                                          child: Image.network(
                                            "${e["url"]}",
                                            height: 150.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                                    : [Text("")],
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                )
                ),
            ),
            SizedBox(height: 5.0,),
            Expanded(
              flex:10,
              child: Container(
                decoration: BoxDecoration(
                  //背景颜色
                  color: Colors.white,
                  //这个圆角比较怪，记住就行了
                  borderRadius: BorderRadius.all(Radius.circular(15.0)), //圆角
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: [
                                Container(
                                  height: 36.0,
                                  //color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  child: Text(" ",
                                      textDirection: TextDirection.ltr,
                                      //文字从左向右排版，没感觉出这个排版意思
                                      //style 是用 TextStyle来装饰的
                                      style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontWeight: FontWeight.bold,
                                          //加粗
                                          fontSize: 14.0,
                                          //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                          color: Colors
                                              .black //颜色使用Colors组件，设置系统自带的颜色
                                        //decoration: TextDecoration.lineThrough, //删除线
                                        //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度

                                      )),
                                )
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Stack(
                              alignment: AlignmentDirectional.centerEnd,
                              children: [
                                InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      //背景颜色
                                      color: Colors.redAccent,
                                      //边框
                                      // border: Border.all(
                                      //   //color: Colors.blue, //边框颜色
                                      //   width: 1.0, //边框宽度
                                      // ),
                                      //这个圆角比较怪，记住就行了
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(23.0)), //圆角
                                    ),
                                    height: 26.0,
                                    child: Text("复制淘口令",
                                        textDirection: TextDirection.ltr,
                                        //文字从左向右排版，没感觉出这个排版意思
                                        //style 是用 TextStyle来装饰的
                                        style: TextStyle(
                                            fontFamily: 'DMSans',
                                            //fontWeight: FontWeight.bold, //加粗
                                            fontSize: 14.0,
                                            //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                            color: Colors
                                                .white //颜色使用Colors组件，设置系统自带的颜色
                                          //decoration: TextDecoration.lineThrough, //删除线
                                          //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度

                                        )),
                                  ),
                                  onTap: () {
                                    FlutterClipboard.copy(_keyword).then((value) {
                                      _sunToast("复制成功");
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0,),
                      TextField(
                          style: TextStyle(
                            fontSize: 14.0,
                            //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                            height: 1.5, //行高
                          ),
                          keyboardType: TextInputType.text,
                          maxLines: 5,
                          // minLines: 1,
                          decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              //输入框被激活时颜色
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black26, //边框颜色为绿色
                                    // width: 1, //宽度为5
                                  )),
                              // isDense: true,
                              border: const OutlineInputBorder(
                                gapPadding: 0,
                                borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.none,
                                ),
                              ),
                              //输入框默认边框颜色
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orange),
                              )),
                          onChanged: (value) {
                            this._keyword = value;
                          },
                          controller: TextEditingController.fromValue(
                              TextEditingValue(
                                  text:
                                  '${this._keyword == null ? "" : this._keyword}',
                                  //判断keyword是否为空
                                  // 保持光标在最后
                                  selection: TextSelection.fromPosition(
                                      TextPosition(
                                          affinity: TextAffinity.downstream,
                                          offset: '${this._keyword}'.length))))),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.0,),
            Expanded(
              flex:2,
              child: Container(
                decoration: BoxDecoration(
                  //背景颜色
                  color: Colors.white,
                  //这个圆角比较怪，记住就行了
                  borderRadius: BorderRadius.all(Radius.circular(15.0)), //圆角
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child:Container(
                      child: Row(
                        children: [
                          Text("分享至:")
                        ],
                      ),
                    )
                  )
                ),
            ),
            SizedBox(height: 5.0,),
            Expanded(
              flex:4,
              child: Container(
                decoration: BoxDecoration(
                  //背景颜色
                  color: Colors.white,
                  //这个圆角比较怪，记住就行了
                  borderRadius: BorderRadius.all(Radius.circular(15.0)), //圆角
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                    child: Container(
                      child: //分享至周围
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              child: Container(
                                child: Column(
                                  children: [
                                    Expanded(
                                        child: Container(
                                          child: ClipOval(
                                            child: Image.network(
                                              "https://www.shsun.xyz/images/share/a001.png",
                                              // height: 80,  //这里的宽高不是图片的宽高，结合ClipOval使用才有效果，
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text("微信",
                                        style:TextStyle(
                                          //fontWeight: FontWeight.bold, //加粗
                                          fontSize:12.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                          //color:Colors.black26 //颜色使用Colors组件，设置系统自带的颜色
                                          //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                        )
                                    )
                                  ],
                                ),
                              ),
                              onTap: (){
                                this.mstatus = 1;
                                _sunGetUserTaobaoauth(
                                    itemid: _sunContentData[0]["item_id"],status: 1);
                                //_sunWxtitle = "${this._sunContentData[0]["title"]}";

                                // openWeChatApp();
                              },
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              child: Container(
                                child: Column(
                                  children: [
                                    Expanded(
                                        child: Container(
                                          child: ClipOval(
                                            child: Image.network(
                                              "https://www.shsun.xyz/images/share/a002.png",
                                              // height: 80,  //这里的宽高不是图片的宽高，结合ClipOval使用才有效果，
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text("朋友圈",
                                        style:TextStyle(
                                          //fontWeight: FontWeight.bold, //加粗

                                          fontSize:12.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                          //color:Colors.black26 //颜色使用Colors组件，设置系统自带的颜色
                                          //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                        )
                                    )
                                  ],
                                ),
                              ),
                              onTap: (){
                                this.mstatus = 2;
                                _sunGetUserTaobaoauth(
                                    itemid: _sunContentData[0]["item_id"],status: 1);
                              },
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      child: Container(
                                        child: ClipOval(
                                          child: Image.network(
                                            "https://www.shsun.xyz/images/share/a003.png",
                                            // height: 80,  //这里的宽高不是图片的宽高，结合ClipOval使用才有效果，
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                  ),
                                  SizedBox(height: 3.0,),
                                  Text("QQ",
                                      style:TextStyle(
                                        //fontWeight: FontWeight.bold, //加粗

                                        fontSize:12.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                        //color:Colors.black26 //颜色使用Colors组件，设置系统自带的颜色
                                        //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                      )
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      child: Container(
                                        child: ClipOval(
                                          child: Image.network(
                                            "https://www.shsun.xyz/images/share/a004.png",
                                            // height: 80,  //这里的宽高不是图片的宽高，结合ClipOval使用才有效果，
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                  ),
                                  SizedBox(height: 3.0,),
                                  Text("复制",
                                      style:TextStyle(
                                        //fontWeight: FontWeight.bold, //加粗

                                        fontSize:12.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                        //color:Colors.black26 //颜色使用Colors组件，设置系统自带的颜色
                                        //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                      )
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                      child: Container(
                                        child: ClipOval(
                                          child: Image.network(
                                            "https://www.shsun.xyz/images/share/a005.png",
                                            // height: 80,  //这里的宽高不是图片的宽高，结合ClipOval使用才有效果，
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                  ),
                                  SizedBox(height: 3.0,),
                                  Text("其他",
                                      style:TextStyle(
                                        //fontWeight: FontWeight.bold, //加粗
                                        fontSize:12.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                        //color:Colors.black26 //颜色使用Colors组件，设置系统自带的颜色
                                        //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                      )
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
