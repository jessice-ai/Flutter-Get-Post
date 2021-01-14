import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_alibc/flutter_alibc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class sunAutoTb extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunAutoTbSon();
  }
}

class sunAutoTbSon extends State {
  int _sunUserID;
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  @override
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    //验证用户登陆状态
    initFromCache().then((result) {
      if(mounted){
        setState(() {
          this._sunUserID = result;
        });
      }
    });
    FlutterAlibc.initAlibc(appName: "夜市优惠券",version: "1.0.0+1");
  }
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
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();

    return Scaffold(
      appBar: AppBar(
        title: Text("授权登陆"),
      ),
      body: this._sunUserID!=null?Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: WebView(
          initialUrl: "https://oauth.taobao.com/authorize?response_type=code&client_id=30174548&redirect_uri=http://www.shsun.xyz/tb/calback&state=${_sunUserID}&view=wap",///初始化url
          javascriptMode: JavascriptMode.unrestricted,///JS执行模式
          onWebViewCreated: (WebViewController webViewController) {///在WebView创建完成后调用，只会被调用一次
            //print("-----------------AAAAAAAAAAAA------------------");
            //_controller.complete(webViewController);
          },
          javascriptChannels: <JavascriptChannel>[///JS和Flutter通信的Channel；
            //_alertJavascriptChannel(context),
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {//路由委托（可以通过在此处拦截url实现JS调用Flutter部分）；
            ///通过拦截url来实现js与flutter交互
            if (request.url.startsWith('http://www.shsun.xyz/tb/calback')) {
              //Fluttertoast.showToast(msg:'JS调用了Flutter By navigationDelegate');
              //print('-----------------BBBBBBBBB------------------ $request}');
              Uri u = Uri.parse(request.url);
              String code = u.queryParameters['code'];
              //print("----------------CCCCCCCCC Code=${code}---------------------");
              //返回上一级
              _sunToast("授权成功!");
              Navigator.of(context).pop();
              return NavigationDecision.navigate;//允许路由替换
              //return NavigationDecision.prevent;//阻止路由替换，不能跳转，因为这是js交互给我们发送的消息
            }
            return NavigationDecision.navigate;///允许路由替换
          },
          onPageFinished: (String url) {///页面加载完成回调
            // setState(() {
            //   _loading = false;
            // });
            //print('Page finished loading: $url');
          },
        ),
      ):Center(
        child: Text("请先登陆"),
      ),
    );
  }
}
