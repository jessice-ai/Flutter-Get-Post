/**
 * 定时器需要引入  dart:async
 */
import 'dart:async';
import 'package:flutter/material.dart';

/**
 * 自定义Dialog组件
 */
class sunMyDialog extends Dialog{
  String suntitle;
  String suncontent;
  sunMyDialog({this.suntitle=null,this.suncontent=null});

  //定时器
  _sunShowTimer(context){
    var timer;
    timer = Timer.periodic(
      Duration(milliseconds: 3000),(t){
        Navigator.pop(context);
        t.cancel(); //取消定时器
    });
  }
  @override
  Widget build(BuildContext context) {

    //定时器,三秒后自动关闭弹出的窗口
    //_sunShowTimer(context);

    return Material(
      type: MaterialType.transparency,  //透明组件
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Align(
                      child: Text("${this.suntitle}"),
                      alignment: Alignment.center,
                    ),
                    Align(
                      //InkWell 可点击的图标
                      child: InkWell(
                        child: Icon(Icons.close),
                        onTap: (){
                          Navigator.pop(context);
                        },
                      ),
                      alignment: Alignment.centerRight,
                    )
                  ],
                ),
              ),
              Divider(),
              Container(
                width: double.infinity, //自动延伸占满外部容器
                padding: EdgeInsets.all(10),
                child: Text("${this.suncontent}"),
              )
            ],
          ),
        )
      ),
    );
  }
}