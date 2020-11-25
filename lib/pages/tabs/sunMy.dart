import 'package:flutter/material.dart';

class sunMy extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunMySon();
  }

}

class sunMySon extends State{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
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