import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sunMy extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunMySon();
  }

}

class sunMySon extends State{
  //获取数据
  void initFromCache() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var sunEmail = prefs.getString("sunEmail");
    var sunPhone =  prefs.getString("sunPhone");
    var sunNickname = prefs.getString("sunNickname");
    var sunAvailable_quota =  prefs.getString("sunAvailable_quota");
    var sunId =  prefs.getInt("sunId");

    print("持久化数据邮箱-:${sunEmail}");
    print("持久化数据手机:${sunPhone}");
    print("持久化数据昵称:${sunNickname}");
    print("持久化数据额度:${sunAvailable_quota}");
    print("持久化数据uid:${sunId}");

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    initFromCache();
    return Container(
      child: Column(
        children: [
          RaisedButton(
            child: Text("注册"),
            onPressed: (){
              //命名路由跳转到某个页面
              Navigator.pushNamed(context, '/sunRegister');
            },
            color: Theme.of(context).accentColor, //颜色主题
            textTheme: ButtonTextTheme.primary, //文本主题
          ),
          RaisedButton(
            child: Text("登陆"),
            onPressed: (){
              //命名路由跳转到某个页面
              Navigator.pushNamed(context, '/sunLogin');
            },
            color: Theme.of(context).accentColor, //颜色主题
            textTheme: ButtonTextTheme.primary, //文本主题
          )
        ],
      ),

    );
  }

}