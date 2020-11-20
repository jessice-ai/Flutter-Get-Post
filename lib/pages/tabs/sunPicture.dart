
import 'package:flutter/material.dart';

class sunPicture extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunPictureSon();
  }

}

class sunPictureSon extends State{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Container(
      child: RaisedButton(
        child: Text("图片"),
        textColor: Theme.of(context).bottomAppBarColor, //定义按钮主题
        onPressed: (){
          //命名路由跳转到某个页面
          Navigator.pushNamed(context, '/sinners',arguments:{
            "id":5,
            "title":"图片标题"
          });
        },
      ),
    );
  }

}
