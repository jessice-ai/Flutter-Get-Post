import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class sunNews extends StatefulWidget{
  Map arguments;
  sunNews({Key key,this.arguments}) : super(key:key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunNewsSon(arguments:this.arguments);
  }
}

class sunNewsSon extends State{
  List _sunList = [];
  Map arguments;
  sunNewsSon({this.arguments});
  int _news;
  //服务器端请求数据
  _sunGetData() async {
    var ApiUrl = "https://pixabay.com/api/?key=17946669-543fe6c4c313739ab33b63515&q=yellow+flowers&image_type=photo&pretty=true";
    var result = await http.get(ApiUrl);
    if(result.statusCode == 200){
      Map sunData = json.decode(result.body);  //把返回的json字符串类型数据，转化为Map类型
      //print(sunData['total']);
      //print(sunData['totalHits']);
      //更新界面
      setState(() {
        this._sunList = sunData['hits'];
      });
    }else{
      //打印错误码
      print(result.statusCode);
    }
  }
  //向服务器端提交数据
  _sunPostData() async{
    var ApiUrl = "https://pixabay.com/api/?key=17946669-543fe6c4c313739ab33b63515&q=yellow+flowers&image_type=photo&pretty=true";
    //{"name":"黄磊","age":23}这个是Map类型数据
    var result = await http.post(ApiUrl,body: {"name":"黄磊","age":23});
    if(result.statusCode == 200){
      Map sunData = json.decode(result.body);  //把返回的json字符串类型数据，转化为Map类型
      //print(sunData); //打印服务器端返回的数据
    }else{
      //打印错误码
      print(result.statusCode);
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();

    //异步获取远程数据
    _sunGetData();
    return Scaffold(
      //appBar 导航
      appBar: AppBar(
        title: Text(
            "新闻 ${arguments!=null ?  arguments['id'] : 0} "
        ),
      ),
      //body 主体
      //循环数据方式一
      body: this._sunList.length>0?ListView(
          children: this._sunList.map((value){
            return ListTile(
              title: Text("${value['tags']}"),
            );
          }).toList() ,
      ):Text("数据加载中"),
      //循环数据方式二
      // body: this._sunList.length>0?ListView.builder(
      //   itemCount: this._sunList.length,
      //   itemBuilder: (context,index){
      //     return ListTile(
      //       title: Text("${this._sunList[index]["tags"]}"),
      //     );
      //   },
      // ):Text("数据加载中"),
    );
  }

}