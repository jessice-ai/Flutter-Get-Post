import 'package:flutter/material.dart';
import 'package:flutter_app/pages/components/sunMyDialog.dart';

class sunHome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunHomeSon();
  }

}

class sunHomeSon extends State{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, //横轴
      mainAxisAlignment: MainAxisAlignment.center,  //纵轴
      children: <Widget>[
        ///向无状态组件，StatelessWidget 传递参数
        //按钮一
        RaisedButton(
          child: Text("向无状态组件，StatelessWidget 传递参数"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/goods',arguments:{
              "id":123,
              "title":"商品"
            });
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        SizedBox(height: 30,),

        ///向有状态组件，StatefulWidget 传递参数
        RaisedButton(
          child: Text("向有状态组件，StatefulWidget 传递参数"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/sunNews',arguments:{
              "id":123,
              "title":"新闻"
            });
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        SizedBox(height: 30,),
        ///向有状态组件，StatefulWidget 传递参数
        RaisedButton(
          child: Text("跳转到Form表单"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/sform');
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        SizedBox(height: 30,),
        ///向有状态组件，StatefulWidget 传递参数
        RaisedButton(
          child: Text("跳转到时间页面一"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/sdata');
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        RaisedButton(
          child: Text("跳转到时间页面二"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/sunCupert');
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        RaisedButton(
          child: Text("Dialog"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/sunlog');
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        RaisedButton(
          child: Text("Toast"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/sunoast');
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        RaisedButton(
          child: Text("自定义Dialog组件"),
          onPressed: (){
                showDialog(context: context,builder: (context){
                  return sunMyDialog(
                    suntitle: "标题",
                    suncontent: "内容",
                  );
                });
            },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),
        RaisedButton(
          child: Text("Dio实现网络请求"),
          onPressed: (){
            //命名路由跳转到某个页面
            Navigator.pushNamed(context, '/sundio');
          },
          color: Theme.of(context).accentColor, //颜色主题
          textTheme: ButtonTextTheme.primary, //文本主题
        ),


        // SizedBox(height: 20.0,),
        // RaisedButton(
        //   child: Text("跳转到宝贝页面"),
        //   onPressed: (){
        //     //基本路由跳转到某个页面
        //     Navigator.of(context).push(
        //         MaterialPageRoute(
        //           // ignore: missing_return
        //             builder: (context){
        //               return sunGoodsList(sunCount: 55,titlet: "aaa",);
        //             }
        //           //页面控件
        //         )
        //     );
        //   },
        //   color: Theme.of(context).accentColor, //颜色主题
        //   textTheme: ButtonTextTheme.primary, //文本主题
        //
        // )
      ],
    );
  }

}