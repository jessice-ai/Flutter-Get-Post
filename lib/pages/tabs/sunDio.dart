import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class sunDio extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunDioSon();
  }

}

class sunDioSon extends State{

  List _sunList = [];
  //Dio Get实现网络请求
  _sunDioGetData() async{
    var sunDio = Dio();
    Response sunResponse = await sunDio.get("https://pixabay.com/api/?key=17946669-543fe6c4c313739ab33b63515&q=yellow+flowers&image_type=photo&pretty=true");
    //注意这里的sunResponse.data 返回来的数据是Map类型，不是Json字符串，所以不需要再转换
    //print(sunResponse.data);

    //更新值
    setState(() {
      this._sunList = sunResponse.data["hits"];
    });
  }

  //Dio Post实现网络请求
  _sunDioPostData() async{
    /**
     * Map类型数据
     */
    Map sunJsonData = {
      "username":"黄磊",
      "age":23
    };
    var sunDio = Dio();
    Response sunResponse = await sunDio.post("https://pixabay.com/api/?key=17946669-543fe6c4c313739ab33b63515&q=yellow+flowers&image_type=photo&pretty=true",data:sunJsonData);
    print(sunResponse.data);
  }
  final int _CONNECTTIMEOUT = 5000;
  final int _RECEIVETIMEOUT = 3000;
  Map sunJsonDataApi = {
    "typeid":12
  };
  List _sunListPro = [];
  _sunDioPostDataHeader() async{
    var sunDio = Dio();
    Response sunResponse = await sunDio.post("https://find.bjrsyz.com/goods/getbannercoupondata",data:sunJsonDataApi,options: Options(
      //连接时间为5秒
      sendTimeout: _CONNECTTIMEOUT,
      //响应时间为3秒
      receiveTimeout: _RECEIVETIMEOUT,
      //三种类型 默认值是" application/json; 2、charset=utf-8",3、Headers.formUrlEncodedContentType 自动编码请求体
      contentType: Headers.formUrlEncodedContentType,
        //设置请求头
        headers:{
          "device": "LNGNW2ZBYO",
        },
    ),);
    setState(() {
      this._sunListPro = sunResponse.data["data"]["coupon"];
    });
  }
  
  //函数初始化时候执行,这个是在构造函数执行完成之后执行
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sunDioGetData();
    _sunDioPostDataHeader();
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Dio网络请求"),
      ),
      //Dio Get实现网络请求,数据渲染页面,方式一
      // body: this._sunList.length>0?ListView(
      //   children: this._sunList.map((value){
      //     return ListTile(
      //       title: Text("${value['tags']}"),
      //     );
      //   }).toList(),
      // ):Text("数据加载中"),
      //Dio Get实现网络请求,数据渲染页面,方式二
      // body: this._sunList.length>0?ListView.builder(
      //   itemCount: this._sunList.length,
      //   itemBuilder: (context,index){
      //     return ListTile(
      //       title: Text("${this._sunList[index]['tags']}"),
      //     );
      //   },
      // ):Text("数据加载中"),
      body: this._sunListPro.length>0?ListView(
        children: this._sunListPro.map((value){
          return ListTile(
            title: Text("${value['skuname']}"),
          );
        }).toList(),
      ):Text("数据加载中"),
    );

  }
}