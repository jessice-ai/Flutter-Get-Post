
import 'package:flutter/material.dart';


class sunSetting extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunSettingSon();
  }

}

class sunSettingSon extends State{

  @override
  Widget build(BuildContext context) {

    // TODO: implement build


    //throw UnimplementedError();
    return Container(
      child: Column(
        children: [
          RaisedButton(
            child: Text("跳转到新闻页面"),
            textColor: Theme.of(context).bottomAppBarColor, //定义按钮主题
            onPressed: (){
              //命名路由跳转到某个页面
              Navigator.pushNamed(context, '/sinners',arguments:{
                "id":5,
                "title":"新闻标题"
              });
            },
          )
        ],
      ),
    );
  }

}
