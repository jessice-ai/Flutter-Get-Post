
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  var sunFlag = true;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("初始化阿里百川"),
              onPressed: () async {
                try {
                  // var waite3s = await FlutterAlibc.openItemDetail(itemID: "12345");
                  // 如果什么都不给
                  var result = await FlutterAlibc.initAlibc(appName: "flutter_app",version: "1.0.0+1");
                  print(result);
                } on Exception {}
              },
            ),
            FlatButton(
              child: Text("登录淘宝"),
              onPressed: () async {
                var result = await FlutterAlibc.loginTaoBao();
                print(
                    "登录淘宝  ${result.data.nick} ${result.data.topAccessToken}");
              },
            ),
            FlatButton(
              child: Text("登出淘宝"),
              onPressed: () {
                FlutterAlibc.loginOut();
              },
            ),
            FlatButton(
              child: Text("淘客登录，二次授权"),
              onPressed: () async {
                var result = await FlutterAlibc.taoKeLogin(
                    url:
                    "https://oauth.taobao.com/authorize?response_type=token&client_id=27646673&state=1212&view=wap",
                    openType: AlibcOpenType.AlibcOpenTypeNative,
                    isNeedCustomNativeFailMode: true,
                    nativeFailMode:
                    AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
                print("access token ${result["accessToken"]}");
              },
            ),
            FlatButton(
              child: Text("唤起淘宝，openByUrl方式"),
              onPressed: () async {
                var result = await FlutterAlibc.openByUrl(
                    url:
                    "https://uland.taobao.com/coupon/edetail?e=0I2EBL%2BTWswGQASttHIRqRXxIesJCFV0jSsDEwaP11URqogtr65NL3IIxArmwXZQtYdj3OrQBBwJkllDQLUC%2B79fwBwwUiqlvyfAqbG%2BQWkG6QT52O7rmXYefz8NXcoYTJnbK5InWzlFfSAQOJJoy8NEaV3mm%2FQSzjZt5gElMznom9kMiklcP0KJ92VgfYGd&traceId=0b0d82cf15669814548736276e3d95&union_lens=lensId:0b0b6466_0c0d_16cd75f7c39_528f&xId=6MboRwsAi2s8Glbqt3lJLAwSlyrPyBLCZ01KOk6QzKCNhw8C6RjXgA1bNbZdKzp30gOqd1J5j1k7ei7HYId1QZ&ut_sk=1.utdid_null_1566981455011.TaoPassword-Outside.taoketop&sp_tk=77+lTU5nMllrdHRqSVLvv6U=",
                    //backUrl: "tbopen27822502:https://h5.m.taobao.com",
                    isNeedCustomNativeFailMode: true,
                    nativeFailMode:
                    AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
                print(result);
              },
            ),
            FlatButton(
              child: Text("唤起淘宝，openItemDetail方式"),
              onPressed: () async {
                var result = await FlutterAlibc.openItemDetail(
                    itemID: "575688730394",
                    schemeType: AlibcSchemeType.AlibcSchemeTaoBao,
                    isNeedCustomNativeFailMode: true,
                    nativeFailMode:
                    AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
                print(result);
              },
            ),
            FlatButton(
              child: Text("打开店铺，openShop方式"),
              onPressed: () async {
                var result = await FlutterAlibc.openShop(shopId: "71955116");
                print(result);
              },
            ),
            FlatButton(
              child: Text("打开购物车，openCart方式"),
              onPressed: () async {
                var result = await FlutterAlibc.openCart();
                print(result);
              },
            ),
            FlatButton(
              child: Text("允许打点"),
              onPressed: () {
                FlutterAlibc.syncForTaoke(true);
              },
            ),
            FlatButton(
              child: Text("使用native Alipay"),
              onPressed: () {
                FlutterAlibc.useAlipayNative(true);
              },
            ),
          ],
        ),
      ),
    );
  }

}

